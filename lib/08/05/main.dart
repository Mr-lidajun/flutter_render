import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

// ---->[08/05]----

/*

如果你因为这个就认为 StatefulWidget 比 StatelessWidget 差，那 StatefulWidget 可就太冤枉了，也只能说明你对 key 和 State 的理解太过肤浅。
因为这场比试根本不在一个赛道上，如果你让组件持有 color ，继承自StatefulWidget 也能互换颜色。 【08/05】

上面无法交换的本质是：颜色属性被 State 私有了，而 Element 无法感知组件的变化。这个案例可能会导致一些看不到要点的人，以为 StatefulWidget 容易出问题，从而抱有什么偏见，从而对于 key 的使用更加不明所以。

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
  final Color color = RandomColor.getColor();

  RandomColorBox({super.key});

  @override
  State<RandomColorBox> createState() => RandomColorBoxState();
}

class RandomColorBoxState extends State<RandomColorBox> {
  @override
  void initState() {
    super.initState();
    print("$this, initState: ${widget.color}");
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: widget.color,
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
