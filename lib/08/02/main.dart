import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

// ---->[08/02]----

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
  List<Widget> tiles = [RandomColorBox(), RandomColorBox()];

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
