import 'package:flutter/material.dart';
import 'package:flutter_render/09/03/ColorProvider.dart';

// ---->[09/03]----

/*
一、认识 ProxyWidget 与 ProxyElement 一族
可能一看到 Proxy ，很多人本能的感觉非常高大上，感觉很难的样子。估计是挨过 代理模式 的不少毒打，其实代理这个概念非常简单，一句话可以很贴切的表示代理是干嘛的。
```
我们不生产水,我们只是大自然的搬运工。
```
言外之意，我们只是大自然的代理，对水进行加工而已。

3. Directionality 是如何实现功能的
Directionality 的核心代码就下面几行，从 textDirection 成员的注释上也能看出它是为子树准备的。其中数据是通过上下文 context 拿到的，我们说过，在 Flutter 中只要看到 contenxt ，其运行时类型一定是元素。
关键方法是 dependOnInheritedWidgetOfExactType ，翻译一下就是：通过确切的类型寻找 InheritedWidget 。

其实跟进去看一下，就知道这个方法干什么了。如下，是在 Element 类对该方法的实现，其中入参泛型必须是 InheritedWidget 的子类型。另外，有个重大发现：每个 Element 对象都会维护 _inheritedWidgets 私有成员。它是一个类型 Type 和 InheritedElement 元素的映射。
---->[Element 成员声明]----
Map<Type, InheritedElement>? _inheritedWidgets;
bool _hadUnsatisfiedDependencies = false;

首先会通过 T 类型在映射中取值，获取方法 InheritedElement 元素对象，由于是 Map 所以记录的是最后一次 该类型对应的元素。比如说上层有两个 Directionality ，由于映射的特性，第一个会被第二个覆盖，记录的是第二个。也就是说，会获取当前元素上层 首个类型为 T 类型对应的的元素节点，这也是为什么叫 ancestor 的原因。

如果 ancestor 非空，会执行 dependOnInheritedElement 方法，返回组件。注意这个方法最终返回的是 T 类型的 组件 。

在该方法中，会维护 _dependencies 成员，它是一个 InheritedElement 类型的集合，也是 Element 中的成员。另外，此处会执行 updateDependencies 方法，注意此时入参中的 this 是 Row 对应的多子元素。最后返回的是 ancestor 持有的 widget 。其实这里就完成了 元素跨节点获取数据 的功能，也是 provider 之重要的功能之一。
---->[Element 成员声明]----
Set<InheritedElement>? _dependencies;

updateDependencies 是 InheritedElement 中的方法，其中维护了 _dependents 映射，用于记录依赖该元素的 元素 。可以理解为 InheritedElement 是债主， _dependents 就是记债的小本子，updateDependencies 方法就是把欠债的那个元素记录一下。
---->[InheritedElement]----
final Map<Element, Object?> _dependents = HashMap<Element, Object?>();

这就是获取 Directionality 组件存储数据的全过程。可以看出明面上是组件的功能，但本质上还是通过元素实现的。所以 InheritedElement 才是黑科技的真正实现者，但世人只知 InheritedWidget 的强大。

三、探索 InheritedElement 元素
InheritedWidget 只是台面上的小人物，InheritedElement 才是幕后的大佬。要彻底弄明白 Inherited 的原理，我们必须对 InheritedElement 有一个清晰的认知。

1. 探索 InheritedElement 类
如下所示 InheritedElement 就比较复杂一些，其中最重要的成员就是 _dependents 映射。

对应方法来说，getDependencies 就是根据 _dependents 取值；setDependencies 是为 _dependents 设置值；updateDependencies 调用 setDependencies ，只存储键 ( 即元素) ，值为 null 。这三个方法都很好理解。

2. 通知欠债者(订阅者)
其实这就是一个非常典型的观察者模式，一种 发布-订阅 的模式。notifyClients 是 ProxyElement 抽象出来的方法，本意上 ProxyElement 承担的就是一个 发布者 的角色，它会收集 订阅者，并通过 notifyClients 通知订阅者。
如下，InheritedElement 对 notifyClients 的实现中，会遍历 _dependents 中的 keys ，也就是元素列表，执行该元素的 didChangeDependencies 方法，这些你应该可以豁然开朗：State#didChangeDependencies 会在什么时候触发了吧！

问题来了，什么时候会执行 notifyClients 呢，其实在本章一开始介绍 ProxyElement 就已经标出来了。如下 tag1 、tag2 所示，在 ProxyElement 执行 update 方法时，notifyClients 会被触发。
---->[ProxyElement]----
@override
void update(ProxyWidget newWidget) {
  super.update(newWidget);
  updated(oldWidget); // tag1
  _dirty = true;
  rebuild();
}

@protected
void updated(covariant ProxyWidget oldWidget) {
  notifyClients(oldWidget); // tag2
}

@protected
void notifyClients(covariant ProxyWidget oldWidget); // tag3

另外注意一点，InheritedElement 对 updated 方法进行了覆写，其中只有 widget.updateShouldNotify 为 true ，才会执行父级的 updated 方法。也就是说对于 InheritedElement 而言， notifyClients 的触发，需要持有的组件满足 updateShouldNotify 的判断。
---->[InheritedElement]----
@override
void updated(InheritedWidget oldWidget) {
  if (widget.updateShouldNotify(oldWidget))
    super.updated(oldWidget);
}

一般而言 updateShouldNotify 方法中就是对比新旧组件持有的数据是否相等。
---->[Directionality]----
@override
bool updateShouldNotify(Directionality oldWidget) => textDirection != oldWidget.textDirection;

3. 理解 State#didChangeDependencies
另外对于 InheritedElement 的 _dependents 映射添加元素的时机了。上面已经介绍了，就是在某个组件中使用该 InheritedWidget 实现类获取数据，触发 dependOnInheritedWidgetOfExactType 方法时。在 InheritedElement#notifyClients 中，会触发所有订阅元素的 didChangeDependencies 。

我们前面介绍了，State 就是 StatefulElement 的一面镜子，反映出元素的生命周期，将其暴露给使用层。对于 State#didChangeDependencies 的理解，本质上就是对 StatefulElement#didChangeDependencies 的理解。如下就是 State#didChangeDependencies 触发的时机。

在 StatefulElement 定义了 _didChangeDependencies 的标识，默认为 false ，在 didChangeDependencies 时，该标识会置为 true 。当 performRebuild 执行时，如果该标识为 true ，就会触发 State#didChangeDependencies ，然后将该标识置为 fasle 。

---->[StatefulElement]----
bool _didChangeDependencies = false;

@override
void didChangeDependencies() {
  super.didChangeDependencies();
  _didChangeDependencies = true;
}

@override
void performRebuild() {
  if (_didChangeDependencies) {
    state.didChangeDependencies(); // 触发 State#didChangeDependencies
    _didChangeDependencies = false;
  }
  super.performRebuild();
}

比如现在举个例子，模仿 Directionality ，自定义一个 ColorProvider 像子树提供 颜色 。代码见 【09/03】

如下，在 _StfAState 中，由于使用了 ColorProvider.maybeOf(context) 获取颜色，所以状态类对应的元素会被注册到 ColorProvider 对应元素的 _dependents 中。一旦 ColorProvider 中的 color 发生变化，就会触发通知，_StfAState 的 didChangeDependencies 就会被回调。

到这里原理已经很清楚了，其实大家最想知道的是: 这有什么用。 下面是 State#didChangeDependencies 中的源码介绍。第一点，在 didChangeDependencies 可以安全的调用 dependOnInheritedWidgetOfExactType 方法。

也就是说在 initState 中，不能用来获取 InheritedWidget 存储的数据。否则会出异常：

在 didChangeDependencies 中就可以安全调用：

比如 _WillPopScopeState 中，在 didChangeDependencies 中使用 ModalRoute.of 获取对象。

但并非 InheritedWidget 只能在 didChangeDependencies 获取，更多时候为了方便使用，会在 build 中直接获取，比如下面的 ScaffoldState#build 方法。

另外一点说的非常清楚， didChangeDependencies 很少在子类中进行覆写，因为 didChangeDependencies 之后总会触发 build 方法。如果有些繁重的任务是依赖于 InheritedWidget 中存储数据的话，每次 build 时触发这个任务就会太昂贵。就有必要在 didChangeDependencies 中进行，这种场景也非常少见。

一般来说 InheritedWidget 就是为了传递数据而已，就是简单的沿树查找数据。如果可以预见某个 Stateful 组件会被频繁更新，而且需要依赖某些 InheritedWidget 获取数据。这时覆写 didChangeDependencies 方法也是一个不错的优化，避免了频繁的沿树查询工作。

这里给一个思考题，为什么 State#initState 触发后，设计者会让 State#didChangeDependencies 接着触发一次。这个问题想明白了，你就参悟透了。

*/

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _red = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: toggle,
        child: const Icon(Icons.refresh),
      ),
      body: Center(
        child: ColorProvider(
          color: _red ? Colors.red : Colors.blue,
          child: const StfA(),
        ),
      ),
    );
  }

  void toggle() {
    setState(() {
      _red = !_red;
    });
  }
}

class StfA extends StatefulWidget {
  const StfA({super.key});

  @override
  State<StfA> createState() => _StfAState();
}

class _StfAState extends State<StfA> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Color? color = ColorProvider.maybeOf(context);
    print("Color=$color");
    print('========didChangeDependencies===========');
  }

  @override
  Widget build(BuildContext context) {
    Color? color = ColorProvider.maybeOf(context);
    print('========build===========');
    return Container(width: 200, height: 200, color: color);
  }
}
