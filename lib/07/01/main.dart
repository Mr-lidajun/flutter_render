import 'dart:async';

import 'package:flutter/material.dart';

// ---->[07/01]----

/*
一、界面变化的本质是什么
上面一节，我们将 MyApp 变为 StatefulWidget ，通过调试分析了 State 状态类的方方面面。上一节的案例在运行后，三棵树如下。本章我们将探索界面变化时，本质上是什么的改变，我们又有什么途径触发变化。

1. 场景介绍
此时 ColoredBox 的颜色是红色，所以创建的 _RenderColoredBox 渲染对象持有的颜色也是红色。

界面上之所以能够显示红色，是因为 _RenderColoredBox 渲染对象在屏幕上画了一块红色。也就是说，渲染对象的绘制决定了 界面的显示 。 那界面的变化，本质上是渲染对象绘制了不同的东西。

现在如果想让下面的红块变成绿块，本质上来说，只要改变 _RenderColoredBox 对象的颜色值，重新绘制即可。那问题来了，如何更新 _RenderColoredBox 对象的颜色值呢？常识告诉我们，只要得到 _RenderColoredBox 对象，重新设置 color 属性即可。

但问题来了，渲染对象被封装在框架内部，我们很难拿到。既然我们拿不到渲染对象，那就去找持有渲染对象的人，那Flutter 框架中谁持有渲染对象呢？思考三秒，请大声说出它的名字。

2. 变色测试
现在来个小测试，通过定时器，在 3s 后将红色变为蓝色，我们来看这整个过程发生了什么事。其中可以肯定的是 _RenderColoredBox 对象的颜色被修改了，而且触发了重绘。带着疑问，现在出发，测试源码于 【07/01】。

3. 探索 State # setState 方法
刚进入 Flutter 时，我们就知道 setState 可以从新构建界面。比如，上面在 _update 方法中触发了 setState ，且回调中将颜色值改成蓝色。

对于 setState 的认知，首先要明确它是 State 类的成员方法，请不要再说什么让组件触发 setState 这种言论。如果连一个方法的归属类都分不清，就不用谈什么对它的理解了。另外，setState 中需要传入一个回调函数，其实除去断言之外，State#setState 中就做了两件事 执行回调 和 元素触发 markNeedsBuild 方法。
---->[State#setState]----
@protected
void setState(VoidCallback fn) {
   	// 略断言
    final Object? result = fn() as dynamic;
  	// 略断言
    _element!.markNeedsBuild();
}

刚入门时，可能会有人疑惑，使用方式下面的 A 、B 效果都一样，有什么区别吗？最好该使用哪种方式？它们的区别在于： 方式 B 的变量修改逻辑在 setState 方法中通过回调触发，其上会有一些 断言，会保证更新当前 State 生命周期的正确性。而断言是只是在 debug 模式时起作用，所以本质上两种方式没有什么区别。
---->[方式 A]----
_color = Colors.blue;
setState(() {
});

---->[方式 B]----
setState(() {
  _color = Colors.blue;
});
不过源码中状态类对于数据的更新都是通过 方式 B ，写在回调之内的，建议向源码看齐。

所以对 State#setState 的理解非常简单，核心就是触发持有的 _element 对象的 markNeedsBuild 方法。也就是说之所以界面上色块会从红变蓝，本质上是 StatefulElement 的作用。

这时可以再来思考一下 Flutter 框架的设计思想，为什么他要提供一个 State 类呢？从源码中可以看出 State 的一切行为，一切功能，通过 Element 都可以实现。为什么不直接把 StatefulElement 暴露出去，这样使用者直接通过 element.markNeedsBuild 就可以触发重构，很直截了当。

这就涉及到 封装 的思想。打个比方，对于电视机来说，没有外壳其实也能看电视。只要把开关处的电线搭上，就能打开。这不是很直截了当吗，为什么要费工夫和材料设计按钮开关和外壳？道理是一样的，通过封装，对内部实现细节进行隐藏，让用户只能接触到可暴露的接口，比如开关按钮，调台按钮。

对于框架设计也是一样，内部的实现细节全部暴露给使用者是很愚蠢的。 State 其实就相当于 电视机外壳 ，电视的内部本质上是渲染树和元素树。 而 State#setState 就相当于 调台按钮 ，如果你只是一个看电视的，那自然不必在意电视机的内部原理。但很不幸，其实你的角色一直以来就是一个修电视的。

二、探索 Element 节点更新
1. Element#markNeedsBuild
markNeedsBuild 方法是定义在元素顶层抽象 Element 类中的，全部代码如下。可以看出在这里，如果元素的 dirty 为 true 就会返回；这是一个小细节，可以避免已经是脏的元素，被 scheduleBuildFor 。打个比方，如果连续触发两次 setState ，那第二次的触发会在 4441 行返回，这就是避免不必要元素重构的第一道保障。

反之会将 _dirty 标为 true ，表示当前元素已经脏了。然后触发 owner 的 scheduleBuildFor ，将 this 元素作为入参。

2. BuildOwner#scheduleBuildFor
owner 对象类型为 BuildOwner ，是用于管理元素节点的类，其中会维护一个 _dirtyElements ，用于收集脏元素。下面的 scheduleBuildFor 方法中，在 2487 会将该元素加
---->[BuildOwner]----
final List<Element> _dirtyElements = <Element>[];

另外 2465 行也有个小细节，如果元素的 _inDirtyList 属性为 true ，表示其已经在脏元素表中了，会直接返回。和上面的 dirty 判断一样，这就是避免不必要元素重构的第二道保障。

值得注意的是：2485 行执行 onBuildScheduled 方法，触发的是 WidgetsBinding#_handleBuildScheduled 。也就是说在之前什么时候， 肯定把 owner 的 onBuildScheduled 赋值成了该方法。这个暂且按下，在后面介绍 BuildOwner 的时候再细说。

下面将触发 ensureVisualUpdate 方法，其中触发 scheduleFrame 方法。

3. BuildOwner#buildScope
如下，之后会触发 _drawFrame 重新绘制帧，进而触发 BuildOwner 的 buildScope 方法。

此时 BuildOwner 对象中持有的 _dirtyElements 有一个元素，就是那个因 setState 被加入 脏元素表 的那个 StatefulElement 。如下所示：

首先，会对脏元素列表进行排序；然后遍历 脏元素列表 ，其中的元素执行 rebuild 方法。

Element 的 rebuild 方法，在前面我们也已经见识过了，其中会触发 performRebuild 。然后通过 StatefulElement#build 方法，触发 State#build 对组件的重新构建。

到这，你就应该明白为什么 State#setState 会触发 build 方法了。如下所示，此时会创建新的组件，这时的 _color 已经变成蓝色。

新组件构建完毕之后，会触发轮回之门 updateChild 方法。只不过此时的 _child 已经有值了，所以和之前构建组件树时的逻辑是不同的，此处是真正的 更新子元素 操作。

4.Element#updateChild
下面是子级非空时，触发更的 第一层 保障：如果新旧两个 widget 满足 == 时，会直接让 newChild = child ，不执行任何其他操作。这道屏障，可以保证一些 widget 信息没有变化，却被更新的元素，不会执行不必要的更新操作。

这里新旧两个组件很明显是不同的，会走接下来的 第二层 保障。通过 Widget.canUpdate 静态方法，来判断是否需要执行更新操作，从计算器中可以看出，此时是 true。

下面看一下允许更新的条件：运行时类型相同 且 两组件的 key 相同，由于这里两组件运行时类型都是 Align ，而且 key 都为 null ，所以是运行执行更新的。

接下来会触发节点的 child 元素的更新逻辑 update，再强调一下，是 child 元素执行更新。此时的 child 是什么，可以好好思考一下。

当前的元素树如下，接下来将会执行的是红框所示元素节点的 update 方法。

5.元素子树的更新
元素触发更新时，会先执行父类的 update 方法。在 Element#update 方法中，将 _widget 成员设置为 newWidget ，也就是现在的新组件。

RenderObjectElement 一族元素会额外触发 _performRebuild 方法，用来更新渲染节点。

其中，组件执行了一个非常重要的方法 updateRenderObject，这就是渲染对象能够更新的关键点。

当前元素持有的组件是 Align ，所以会执行 Align#updateRenderObject ，通过新的组件对这里的渲染对象进行更新。

可以看出，对于这时的更新操作而言，无论是元素节点还是渲染节点都没有重新创建对象。只是对原树节点的属性进行重新设置而已，并没有什么复杂的操作。
所以没有必要担心每次更新，所有的树都会重建。另外，对于渲染对象重设属性而言，还有一道屏障，可以保证当新旧属性相同时，不作处理，直接返回。

同样，接下来也会更新该元素的子级，逻辑和前面是一致的。

最终会在 ColoredBox#updateRenderObject 方法中，对 _RenderColoredBox 的 color 值进行重新设置。这就回答了最开始的问题，渲染对象的属性是何时被修改的。

所以我们要明白， setState 的本质是什么，是元素节点的更新。而元素节点更新时，理解什么在变，什么不变，是非常重要的。变化的是 Widget ，
而元素树、渲染树中的节点仍是之前的对象，只是对渲染对象的属性进行重新设置而已。而且属性相等时的返回，也保证了渲染对象属性更新时不会有什么不必要的操作。

只要是界面发生了任何变动，本质上都是元素节点的更新，无论是 provider 、flutter_bloc 、***X 、redux 都不会对违背这一本质产，通过它们触发节点更新的根源，都是对某一元素节点进行了更新。

*/

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Color _color = Colors.red;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), _update);
  }

  void _update() {
    setState(() {
      _color = Colors.blue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      child: SizedBox(
        width: 100,
        height: 100,
        child: ColoredBox(color: _color),
      ),
    );
  }
}
