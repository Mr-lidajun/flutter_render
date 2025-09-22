import 'dart:async';

import 'package:flutter/material.dart';

// ---->[08/10]----

/*

三、探索 GlobalKey 的价值
可能很多人听别人说 GlobalKey 很重，又不知道为什么，所以用起来畏首畏尾的。一个东西如何，不是靠别人说他怎么怎么样，而是要看它实际做了什么。说一个对象很重，无非三个原因：
其一: 该类中持有很大的数据
其二: 该类可能引起其他类持有很大的数据
其三: 该类可能触发一些复杂逻辑

4.GlobalKey 功能的实现原理
如下，一开始触发 currentContext 方法，调用的是 _currentElement ，从这里再一次说明 ：我们接触的BuildContext 本质就是 Element 对象。

可以看到，目前一共有 12 个 GlobalKey ，如下红框中是我们保持图片需要用到的 GlobalKey。

最后一个重要的问题，这个 key 时什么时候被加入 _globalKeyRegistry 中的。 如下，BuildOwner 有个 _registerGlobalKey 方法，传入 GlobalKey 和 Element 对象，将入 _globalKeyRegistry 映射中。

---->[BuildOwner#_registerGlobalKey]----
void _registerGlobalKey(GlobalKey key, Element element) {
  _globalKeyRegistry[key] = element;
}

而这个方法在 Flutter 框架中有且仅有一处使用场景，就在 Element#mount 中。也就是说在元素认父亲时，如果自身持有组件的的 key 是 GlobalKey ，就加入到 BuildOwner#_globalKeyRegistry 映射中 。就这么粗暴，就这么简单。
---->[Element#mount]----
@mustCallSuper
void mount(Element? parent, Object? newSlot) {
  _parent = parent;
  _slot = newSlot;
  _lifecycleState = _ElementLifecycle.active;
  _depth = _parent != null ? _parent!.depth + 1 : 1;
  if (parent != null) {
    _owner = parent.owner;
  }
  final Key? key = widget.key;
  if (key is GlobalKey) {
    owner!._registerGlobalKey(key, this); //<--- 添加
  }
  _updateInheritance();
}

4. 为什么说 GlobalKey 很重？
万恶之源应该是在这里吧， GlobalKey 在自我描述中的真情告白。其实 很重 这个词并不太确切，relatively 翻译为 相对地 比较好。

而且注意一个单词 Reparenting ，不知道有多少人一眼看成 preparing (准备)。这个单词是 re + parent + ing ，可理解为 重新认定父级 ；
术语叫 重排根目录 ，根据源码和语境，这里的 根 不是根元素节点，应该是更新元素的父级。所以说这个 relatively expensive 也是在某个场景下才会出现的。

另外 as this operation will trigger 说明，是这项操作会触发些什么，触发的逻辑就应该是 GlobalKey 相对比较重的原因。下面再来学个单词 descendants ，表示 后代;子节点 。
也就是说，这个操作会触发该元素及其所有子节点持有的 State 对象的 deactivate 方法。然后强制所有依赖于 InheritedWidget 的小部件重建。
* InheritedWidget : 恩？到我出场了？
* 旁白：还没，你先待会。

如果真的是 很重 ，应该用 very expensive 来表述，Flutter 框架中只有一处是 very expensive 。
* SingleChildScrollView 内心独白：为什么受伤的总是我。

言归正传，如果想查看在 Flutter 框架中 GlobalKey 在什么地方起作用，应该怎么办？最简单的一个方式就是搜索。如下 key is GlobalKey 一共有 7 处场景，其中四个在 assert 断言中，只在 debug 中起作用，所以不用管。

另外有两个分别在 mount 和 unmount 中，用于维护 _globalKeyRegistry 的映射关系。这样七个去掉六个，还是下最后一个。
---->[Element#unmount]----
if (key is GlobalKey) {
  owner!._unregisterGlobalKey(key, this);
}
---->[Element#mount]----
if (key is GlobalKey) {
  owner!._registerGlobalKey(key, this);
}

它就是 Element#inflateWidget 方法，这个 Flutter 框架中最核心的方法之一。Widget 在此实现人生价值、Element 在此滴血认亲、RenderObject 在此诞生认父的神圣领域。同样也是 GlobalKey 实现价值的场所。
---->[Element#inflateWidget]----
Element inflateWidget(Widget newWidget, Object? newSlot) {
  try {
    final Key? key = newWidget.key;
    if (key is GlobalKey) {
      final Element? newChild = _retakeInactiveElement(key, newWidget);

下面是 inflateWidget 方法对 GlobalKey 的描述，其中说到：如果给定的组件有一个 GlobalKey ，并且这个 GlobalKey 和一个元素建立映射关系。这个方法会重新激活这个元素，而非创建新元素。
从中似乎并没有看到在说 GlobalKey 的坏话，这表示相比于 创建新元素 来说 复用 也不是什么坏事。
If the given widget has a global key and an element already exists that
has a widget with that global key, this function will [reuse that element]
(potentially grafting it from another location in the tree or reactivating
it from the list of inactive elements) [rather than creating a new element].

还是用代码说话，看看如果是 GlobalKey ，其中会发生什么事。首先，会通过 _retakeInactiveElement 获取 Element 对象。这个方法名很明显，是 重新拿来非激活态的元素。
---->[Element#inflateWidget]----
Element inflateWidget(Widget newWidget, Object? newSlot) {
  final bool isTimelineTracked = !kReleaseMode && _isProfileBuildsEnabledFor(newWidget);
    try {
      final Key? key = newWidget.key;
      if (key is GlobalKey) {
        final Element? newChild = _retakeInactiveElement(key, newWidget);
        if (newChild != null) {
          try {
            newChild._activateWithParent(this, newSlot);
          } catch (_) {
            ...
          }
          final Element? updatedChild = updateChild(newChild, newWidget, newSlot);
          return updatedChild!;
        }
      }
      final Element newChild = newWidget.createElement();
      newChild.mount(this, newSlot);

      return newChild;
    } finally {
      if (isTimelineTracked) {
        FlutterTimeline.finishSync();
      }
    }
}

_retakeInactiveElement 方法中，会取 GlobalKey 映射的 Element 作为返回值，如果有这个元素，会在此执行父级节点的 forgetChild 和 deactivateChild 方法，解除 父 -> 子 的关系。
---->[Element#_retakeInactiveElement]----
Element? _retakeInactiveElement(GlobalKey key, Widget newWidget) {
  final Element? element = key._currentElement;//tag1
  if (element == null) {
    return null;
  }
  if (!Widget.canUpdate(element.widget, newWidget)) {
    return null;
  }
  final Element? parent = element._parent;
  if (parent != null) {
    parent.forgetChild(element); //tag2
    parent.deactivateChild(element); //tag3
  }
  owner!._inactiveElements.remove(element);
  return element;
}

在接下来的 _activateWithParent 中，以当前元素重新建立 子 -> 父 的关系。在 inflateWidget 出栈后，会为当前元素的 _child 赋值为返回值。建立 父 -> 子 的关系，这就是 inflateWidget 时组件有 GlobalKey 的逻辑。
---->[Element#_activateWithParent]----
void _activateWithParent(Element parent, Object? newSlot) {
  assert(_lifecycleState == _ElementLifecycle.inactive);
  _parent = parent; //tag1
  _owner = parent.owner;
  _updateDepth(_parent!.depth);
  _updateBuildScopeRecursively();
  _activateRecursively(this);
  attachRenderObject(newSlot); //tag2
  assert(_lifecycleState == _ElementLifecycle.active);
}

注意一点，在元素树第一次成树时，GlobalKey 中肯定还未建立映射关系，所以 inflateWidget 中的 key is GlobalKey 并没有任何影响。如下 【08/10】 ，中为 SizedBox 添加 GlobalKey ，调试时效果如下， newChild 为 null ，表示 GlobalKey 并不影响元素成树的逻辑。
---->[Element#inflateWidget]----
Element inflateWidget(Widget newWidget, Object? newSlot) {
  try {
    final Key? key = newWidget.key;
    if (key is GlobalKey) {
      final Element? newChild = _retakeInactiveElement(key, newWidget);
      if (newChild != null) {
        assert(newChild._parent == null);

也就是说，GlobalKey 的作用是在元素节点更新时，且触发 inflateWidget 时，才会起作用。但是一般的元素节点更新并不会触发 inflateWidget 方法。
更新子元素节点时，需要突破两次屏障，才可能通过 inflateWidget 重新生成元素。比如新旧组件的类型发生变化，或者更新时 child 为 null 时。
---->[Element#updateChild]----
Element? updateChild(Element? child, Widget? newWidget, Object? newSlot) {
  ...
  final Element newChild;
  if (child != null) {
    bool hasSameSuperclass = true;

    if (hasSameSuperclass && child.widget == newWidget) { //tag1
      if (child.slot != newSlot) {
        updateSlotForChild(child, newSlot);
      }
      newChild = child;
    } else if (hasSameSuperclass && Widget.canUpdate(child.widget, newWidget)) { //tag2
      if (child.slot != newSlot) {
        updateSlotForChild(child, newSlot);
      }
      final bool isTimelineTracked = !kReleaseMode && _isProfileBuildsEnabledFor(newWidget);
      if (isTimelineTracked) {
        Map<String, String>? debugTimelineArguments;
        FlutterTimeline.startSync('${newWidget.runtimeType}', arguments: debugTimelineArguments);
      }
      child.update(newWidget);
      if (isTimelineTracked) {
        FlutterTimeline.finishSync();
      }
      newChild = child;
    } else {
      deactivateChild(child);
      newChild = inflateWidget(newWidget, newSlot); //tag3
    }
  } else {
    newChild = inflateWidget(newWidget, newSlot);
  }
  return newChild;
}

所以总的来看，这个 Reparenting 的操作并不是很常见的操作。而且在 inflateWidget 中会复用旧的元素子树，相比于重建元素子树来说感觉也差不到哪去。在子元素节点脱离父级和重新添加到树上，确实会造成子树状态类的回调事件，感觉也无可厚非。
Reparenting an [Element] using a global key is <<relatively expensive>>, as
this operation will trigger a call to [State.deactivate] on the associated
[State] and all of its descendants; then force all widgets that depends
on an [InheritedWidget] to rebuild.

源码中也对 GlobalKey 的使用场景做出了介绍，当你真的需要获取某个 BuildContext 或 State 时，用 GlobalKey 是完全没有问题的。
所以了解 GlobalKey 本质后，才敢大胆的取用它，不必要疑神疑鬼，以为用了有多少性能负担似的。如果你对 GlobalKey 在源码中的作用有什么见解，欢迎讨论。

这样，关于 Key 的探索就告一段落，此时真个Flutter 框架大厦的根基已经基本建立。 渲染类型 元素和 组合类型 元素是 Flutter 中的两大派系，现在我们还差最后一块拼图 ProxyElement ，就可以对 Flutter 的元素有完备的认知。

Flutter 中每个 Element 的实现类，都对应着一个 Widget 族群。打个比方，Element 是各大河流，而 Widget 就是依靠河流而形成的各个文明，每种文明会有自己的特点，而且每种文明的不同地域也会衍生出不同的民族、部落，它们也会有自己独特的文化特征。
这就是文明的多样性，Widget 也是这样，其多样性无疑是非常丰富的，但我们可以通过 Element 的分类，对 Widget 进行一个恰当体系归纳。

最后一块 ProxyElement 拼图，也就意味着最后一块 ProxyWidget 拼图，就可以对 Flutter 的组件体系有完备的认知。

*/

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey _globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), _update);
  }

  Color _color = Colors.red;

  void _update() {
    setState(() {
      _color = Colors.blue;
    });
    // setState(() {
    //   _color = Colors.blue;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      child: SizedBox(
        key: _globalKey,
        width: 100,
        height: 100,
        child: ColoredBox(color: _color),
      ),
    );
  }
}
