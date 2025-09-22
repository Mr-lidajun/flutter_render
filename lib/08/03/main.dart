import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

// ---->[08/03]----

/*
一、测试案例介绍
Flutter 官方有一个介绍 Key 用处的视频，就是那个交换颜色的案例，可能很多朋友看这个案例 get 不到其中想说明什么。个人感觉虽然这个案例能解释 Key 的作用，但并不是个很好的例子，这里我先就带大家分析一下。

1.出场人物介绍
通过 RandomColor#getColor 可以获取随机色。

主人公 RandomColorBox ，在其状态类的 initState 中为颜色设置一个随机色。

2. 舞台及诉求介绍
两个主角诞生时附着一种随机色，作为成员变量盛放在 tiles 列表中。构建时放入 Row 中横向排列，点击按钮时，调换 tiles 列表中的两个人物的位置，希望两者位置互换。

3. 核心矛盾
无法完成交换。代码见 【08/01】

这时，根据前面的知识，你应该有解释这个矛盾出现的能力，你可以先尝试根据源码，自己去分析一下。

4.场景优化
由于 MaterialApp 和 Scaffold 内部集成了很多组件，这会导致调试分析时比较复杂。为了方便揭示核心矛盾，更清晰的认识本质问题，这里把无关的东西剔除。仍通过 Timer 来触发更新，代码见 【08/02】

另外 Row 换为 Column ，因为 Row 需要上级通过文字方向，移除 MaterialApp 会有问题。需要包裹 Directionality 组件，所以使用 Column 最方便。

这时候可以自己尝试一下画出当前的三颗树 。

目前三棵树结构如下所示，此时就是问：红框中的两颗子树交换，为什么视图树不会发送变化。本质上来说，就是在问：此时，组件信息变化，为什么对应的渲染对象颜色无法被重新配置。为了方便表述，我把 B 处组件加深了：

二、源码调试分析
1. 探索为什么此时没有变色
此时调试时，先查看A、B 对应的颜色，分别为 0xffdc73e6 和 0xffa57852 。当 A 、B 交换，执行 setState 时，此时 Column 中的孩子，确实已经变成了 [B,A] 。因为是 PositionedTiles 对应的状态类触发的 setState ，所以触发的是其下元素节点的更新。

其实这个现象理解起来还是非常容易的，因为 元素树 并未交换。如下是第一个子元素触发更新时，状态类触发 build 的场景，因为 myColor 是状态类的成员，而状态类被元素持有。所以即使 A、B 组件被交换， 无法波及到状态类中的演策，此时第一个颜色仍是 0xffdc73e6 。

接下来，由于第一个 ColoredBox 颜色未变，所以为第一个 _RenderColoredBox 渲染对象设置颜色时，仍是 0xffdc73e6 。这就是为什么没有变色的根本原因。

2. 为什么添加 Key 可以实现交换
这里只要添加 key 即可完成正确的交换，代码见 【08/03】。下面我们从源码中看一下这是为什么。
List<Widget> tiles = [
  RandomColorBox(key: UniqueKey()),
  RandomColorBox(key: UniqueKey()),
];

RenderObjectElement 的 updateChildren 中有新旧的组件列表，如下所示：
在 RenderObjectElement#updateChildren 时，在遍历子元素时，会根据 canUpdate 进行校验，如果可以返回 false 会跳出循环。如果允许更新，就会直接走 5787 行 updateChild 进行更新，这样就会出现上面的问题，组件变化了，但元素树未改变。

这里由于新旧组件的 key 不同，updateChildren 就会返回 fasle ，此处被 break 。所以接下来一定会对元素树进行处理。

之后通过 oldKeyedChildren 记录 Key 和 Element 的映射关系，比如此时 key 的地址是 #d0c0d ，在 5816 行后，会为 oldKeyedChildren 添加一组映射关系。
Map<Key, Element>? oldKeyedChildren;

第二个也是如此，也就是说 oldKeyedChildren 会维护旧子元素和 key 的映射关系。

接下来就是最关键的一步，用新组件的 key 在 oldKeyedChildren 映射中取值。这里的 #dcd61 取到的是 oldKeyedChildren 中的第二个元素。

这样 oldChild.widget 和 newWidget 就保持一致了，可以允许更新。

然后就会通过 正确的元素去更新 正确的组件 ，其中 Key 的作用非常明显，就是作为唯一身份标志。接下来的事自然不必多说，由于这里使用的是 第二个元素 去更新 第一个组件的 颜色，所以颜色会变化。另一个元素同理。

接下来，会更新 newChildren 列表，如下，此时原来的第二元素会被设为第一个。

同样，当遍历完第二个元素时，newChildren 列表中的元素如下，完成了对旧列表的交换。

然后，元素树中对应的子元素也会发生交换。大家可以结合上面的整个流程，品味一下，key 在其中的作用。

二、关于这个案例的引申
其实我个人并不是很喜欢这个案例，总感觉它是为了 解决问题 而 制造问题，来强行解说 key 的作用。上面作为一个理解 key 的小引子也不错，下面我们开始真正探索 key 的作用。

1. 状态类的私有成员
组件的目的是为了通过 配置信息 来决定显示，而案例中的两个组件并无法标识两者的不同。

就比如两个双胞胎女孩，长得一模一样。她们会给自己的男友一个颜色。然后主持人依次询问女孩，然后对应的男友报出颜色，主持人画在纸上，如下最终的显示是 蓝 + 橙。

*/

void main() {
  runApp(PositionedTiles());
}

class PositionedTiles extends StatefulWidget {
  const PositionedTiles({super.key});

  @override
  State<PositionedTiles> createState() => PositionedTilesState();
}

class PositionedTilesState extends State<PositionedTiles> {
  List<Widget> tiles = [
    RandomColorBox(key: UniqueKey()),
    RandomColorBox(key: UniqueKey()),
  ];

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), swapTiles);
  }

  void swapTiles() {
    print('====do swapTiles==========');
    setState(() {
      tiles.insert(1, tiles.removeAt(0));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: tiles);
  }
}

class RandomColorBox extends StatefulWidget {
  const RandomColorBox({super.key});

  @override
  State<RandomColorBox> createState() => RandomColorBoxState();
}

class RandomColorBoxState extends State<RandomColorBox> {
  late Color myColor;

  @override
  void initState() {
    super.initState();
    myColor = RandomColor.getColor();
    print("$this, initState: $myColor");
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: myColor,
      child: const SizedBox(width: 70, height: 70),
    );
  }
}

class RandomColor {
  static final Random _random = Random();

  static Color getColor() {
    return Color.fromRGBO(
      _random.nextInt(256),
      _random.nextInt(256),
      _random.nextInt(256),
      1,
    );
  }
}
