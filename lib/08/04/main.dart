import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

// ---->[08/04]----

/*
此时，大家可以思考一下，为什么如果 RandomColorBox 是 StatelessWidget ，即使不加 key ，也不会出现无法交换颜色的情况？ 【08/04】

因为对于 StatelessElement 而言是没有中间商赚差价的。在更新时，元素持有的 _widget 会被更新，也就是说目前第一个元素持有的 _widget 已经变成 B 了。

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
    RandomColorBox(),
    RandomColorBox(),
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

class RandomColorBox extends StatelessWidget {
  RandomColorBox({super.key});

  final Color myColor = UniqueColorGenerator.getColor();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: myColor,
      child: const SizedBox(width: 70, height: 70),
    );
  }
}

class UniqueColorGenerator {
  static Color getColor() {
    return Color.fromRGBO(
      Random().nextInt(256),
      Random().nextInt(256),
      Random().nextInt(256),
      1,
    );
  }
}
