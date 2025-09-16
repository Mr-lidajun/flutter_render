import 'dart:async';

import 'package:flutter/material.dart';

// ---->[07/03]----

/*
三、关于更新的效率问题
通过上面分析我知道，当某个节点更新时，其子树都会触发更新。所以更新的复杂程度是和树深有关系的，理论上来说子树节点越少更新越快。理论上来说，通过单独抽离组件，我们可以精确的对某个节点进行提取，单独更新；或通过 ValueListenableBuilder 精确地对某一节点进行更新。

1.不要空谈效率
但我们要清楚地是，节点的更新只是在做 设置属性 的工作，而且也有几道屏障来确保不会做无用的设置。所以当你想要精确控制某一节点的更新时，要先考量一下，我这么做是否会影响代码的阅读。

2. 元素节点的更新效率分析
在直觉上来说，更新 1 个节点和更新 100 个节点，肯定选前者。 但是如果场景切换一下，你每秒能赚 1 个亿，你还会计较买个东西花 1 块钱还是 100 块吗？

如下的测试中，执行 10 亿次累加，耗时大约 7 秒，累加中包括计数器增加、sum 值累加、i 值判断三个步骤。 也就是说，赋值、比较的语句，在一秒之内可以执行 数亿 次。
而元素节点的更新，只是为渲染对象设置属性而已，都是些基本的语句，所以没有必要为了少刷 几个节 点而费尽心机。

3. 万事把握 度 是最重要的
但这并不代表你可以放飞自我，满屏 setState ，不计后果的铺张浪费，勤俭节约是我们的传统美德。但勤俭，也并不等于一毛不拔，为了一块钱，跑十站路，不是勤俭。下面我们来进行一些测试，思路是通过一个 3s 间隔轮训的 Timer 触发更新，对比不同情况下 build 的耗时情况。 *注* : 性能查看请在 --profile 模式下进行。

如下，是通过 ValueListenableBuilder 局部更新一个节点时，一帧中的构建时间，build 耗时 0.1 ms 。测试代码 【07/02】。

如下，是通过 setState 局部更新一个节点时，一帧中的构建时间，build 耗时也是 0.1 ms 。测试代码 【07/03】。可以看到对于几个节点的优化几乎没有什么影响，但用了 ValueListenableBuilder 代码会更复杂一些。

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
  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 3), _update);
  }

  Color _color = Colors.red;
  int _count = 0;

  void _update(Timer timer) {
    if (_count > 10) {
      timer.cancel();
      _count = 0;
      return;
    }
    _count++;
    setState(() {
      _color = _color == Colors.blue ? Colors.red : Colors.blue;
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
