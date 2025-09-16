import 'package:flutter/material.dart';

// ---->[05/01]----

/*

一、从玩积木开始说起
现在先摒弃你对 Widget 的一切认知，先来玩个游戏。如下，我们有可以使用任意个 A 、B 、C 组件去构建东西。其中小圆圈处可以连接任意的组件或不连接组件，其中 A 和 B 只能连接一个组件， C 可以连接 6 个。

1. 只使用最原始组件的弊端
比如我们先构建一个手指，如下所示，这是一个三级结构，可以通过两个 A 一个 B 进行构建。

图示如下：通过 A 、B 、A 组件形成了一个手指。我们为了方便描述，将这个结构关系通过如下的文字进行定义：
A child-> B child->  A

将结构关系通过规则进行定义，这样可以方便理解，也便于传播。比如别人想构建一个手指，只需要发给他发一串文字就行了，他按照规则进行组装即可。比如现在我将刚才构建的手指，装配到 C 的 2 槽点 ，可以通过文字表示为 ：
C(
2: A child-> B child->  A,
)

同理，将刚才构建的手指模块，装配到 C 的 3、4、5 槽点 ，可以通过文字表示为 ：
C(
2: A child-> B child->  A,
3: A child-> B child->  A,
4: A child-> B child->  A,
5: A child-> B child->  A,
)
其实到这里就可以看出一些弊端，四个手指的结构都是相同的。如果只是通过 A 、B 进行表述，就会显得很啰嗦。我们为什么将 A child-> B child-> A 结构封装一下，简化表述呢？

2. 组件的封装
现在把整个手指结构看成一个新的组件 D ，等价于把 A child-> B child-> A 用 D 来表述。也就是说，我们语义上指的 D ，是使用 A、B、A 构成的新组件，D 的价值，就是对某一特定结构的封装。
这样就可以非常方便地使用 D 对现在结构进行表述。
C( 2: D, 3: D, 4: D, 5: D,)

另外，通过封装，我们也可以指定 D 的参数决定不同的装配表现，比如 two 时，表示内部只有两个组件。
这样，对于一个一个手掌的装配，就可以通过如下的字符进行表示：

其实，我们也可以将手掌内部的构造细节进行封装，通过 Hand 组件进行表述。这样在有使用到手掌时，可以直接拿来用，这就是组合、封装的妙处。

二、StatelessWidget 全方位解读
对于 Flutter 来说，Widget 的组合也是如此，如果只是使用 RenderObjectWidget 通过子级关系进行构建界面，将会导致结构非常复杂，而且难以复用。StatelessWidget 和 StatefulWidget 两个组件的诞生，就是为了解决这个的问题，通过其他已有组件在 build 方法中完成构建逻辑，封装成一个更通用的新组件，方便表示和复用。
1、 通过 StatelessWidget 进行封装
如下所示，我们将 Align-> ColoredBox -> SizedBox 这个结构封装为 MyApp 组件。就像上面通过对三个单体结构封装为手指 D 组件一样，其中 build 方法就是 MyApp 组件的构建逻辑。

现在有一个非常值得探讨的问题：StatelessWidget#build 方法，在 Flutter 框架中是何时何地怎么触发的？其中回调的 BuildContext 对象究竟是什么？

2.探索 StatelessWidget 的 build 方法触发时机
想了解一个回调的触发事件，是非常简单的，打个断点调试一下，一目了然。如下所示，我们可以从根元素的触发 inflateWidget 方法开始看起。

因为此时 runApp 方法的入参是 MyApp ，也就是说 inflateWidget 中将会执行 MyApp 组件的 createElement 方法创建 Element 对象。但是 MyApp 并没有实现这个方法，这说明该抽象方法肯定是在父类中实现的。、

可以看到 StatelessWidget 中实现了 createElement 方法，创建并返回一个 StatelessElement 的元素。其中 this 作为构造入参，将会在 Element 的构造中用于初始化 _widget 成员。

然后创建的元素会执行 mount 方法，挂载到元素树上。其中 StatelessElement 未覆写 mount 方法，所以会走父类 ComponentElement 的 mount 方法。

3. ComponentElement 的挂载逻辑
我们前面说过 Element 分为两大家族，其中 RenderObjectElement 一族持有 渲染对象 ，在 mount 时会创建渲染对象，并将其关联到渲染树中。而 ComponentElement 一族不持有 渲染对象 ，所以在 mount 时的逻辑也会有所不同。

如下，在 super#mount 执行完后，ComponentElement#mount 会触发 _firstBuild 方法。

此时的元素树如下所示，现在重点看一下 _firstBuild 方法中做了什么事。

在 _firstBuild 中，只是触发了 rebuild 方法：

在 rebuild 中，一堆断言，只是执行了 performRebuild 方法：

在 performRebuild 方法中会触发本类中的 build 方法，返回一个 Widget 对象为局部变量 built 赋值。

这里的 build 是 ComponentElement 中的抽象方法，StatelessElement 对它的实现是通过自身持有的 widget 对象调用 build 方法。这短短的一句话，蕴含着非常多的信息，这里元素持有的 widget 就是 MyApp 组件，也就是说，接下来会触发 MyApp 的 build 方法返回组件。

好了，这就是 StatelessWidget 触发 build 方法的全部流程。其中需要注意的是：这里的 build 触发时入参是 this ，也就是说我们平时继承自 StatelessWidget 覆写的 build 方法，其中的 BuildContext 本质上就是：该组件在框架中创建的元素对象。

下面再通过图示，走一下整体的流程，可以从 _firstBuild 开始，在脑子里回想一下 StatelessWidget#build 的触发流程。

4. ComponentElement 如何实现元素树衔接的
大家可以停下来思考一下：通过 MyApp 创建完 Widget 之后又会发生什么呢？元素树之后又是如何一步步形成的呢？

没错，有了子级组件，接下来就会进入轮回大门 updateChild 方法，之后的事就和前几章介绍的一样了。可以发现， ComponentElement 在 mount 时并没有为渲染树添加节点，因为 ComponentElement 不和渲染对象打交道，只是进行组合而已。

所以 元素树 和 渲染树 并非一一对应的关系：元素树中 ComponentElement 类型的节点不会对应渲染节点；只有 RenderObjectElement 类型的元素节点才会持有 渲染节点。另外，对于 组件树 而言，MyApp 和 Align 逻辑上没有很强的 父子关系 ，只是一种构建关系，为了便于统一表达，一般也将其视为 父子关系 。

你现在可以打开 Container 的源码，就会发现：它作为 StatelessWidget 的派生类，本质上就是对如下 八个 单子组件的功能封装。

就像上面说的，把装配的细节封装起来，形成更易表达和复用的 新组件 。

比如下面所示，当需要的属性很多时，使用Container 就会非常简洁，语义上来说也更加直观。如果没有 StatelessWidget 这类的组合型组件，通过右侧的单子组件也可以实现功能，但过于麻烦。所以，组合型的组件目的就是为了办三件事：方便 、方便 、还是 *** 方便 。

有人会问，组合型的组件有哪些，可以这么说，除了 RenderObjectWidget 一族的组件，其余的组件全是组合型的组件。包括 StatelessWidget 、StatefulWidget 还有 ParentDataWidget 、InheritedWidget 这类的 ProxyWidget 。这在本质上都是由 Element 的衍生所决定的。

下一章我们将全面分析 State 类在 Flutter 框架中的作用，探索它所处的地位。下一篇，探索继续 ~
*/

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const Align(
      child: ColoredBox(
        color: Colors.red,
        child: SizedBox(width: 100, height: 100),
      ),
    );
  }
}
