import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ---->[07/08]----

/*
三、关于更新的效率问题
通过上面分析我知道，当某个节点更新时，其子树都会触发更新。所以更新的复杂程度是和树深有关系的，理论上来说子树节点越少更新越快。理论上来说，通过单独抽离组件，我们可以精确的对某个节点进行提取，单独更新；或通过 ValueListenableBuilder 精确地对某一节点进行更新。

1.不要空谈效率
但我们要清楚地是，节点的更新只是在做 设置属性 的工作，而且也有几道屏障来确保不会做无用的设置。所以当你想要精确控制某一节点的更新时，要先考量一下，我这么做是否会影响代码的阅读。

2. 元素节点的更新效率分析
在直觉上来说，更新 1 个节点和更新 100 个节点，肯定选前者。 但是如果场景切换一下，你每秒能赚 1 个亿，你还会计较买个东西花 1 块钱还是 100 块吗？

如下的测试中，执行 10 亿次累加，耗时大约 7 秒，累加中包括计数器增加、sum 值累加、i 值判断三个步骤。 也就是说，赋值、比较的语句，在一秒之内可以执行 数亿 次。
而元素节点的更新，只是为渲染对象设置属性而已，都是些基本的语句，所以没有必要为了少刷 几个节 点而费尽心机。


*/

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('HomePage')),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(onPressed: _do, child: Text('10 亿次对象创建')),
          ElevatedButton(onPressed: _do2, child: Text('10 亿累加计算')),
        ],
      ),
    );
  }

  void _do() {
    int count = 1000000000; // 10 亿
    int start = DateTime.now().millisecondsSinceEpoch;
    for (int i = 0; i < count; i++) {
      Point(i, i);
    }
    int end = DateTime.now().millisecondsSinceEpoch;
    print('${((end - start) / 1000).toStringAsFixed(4)} s');
  }

  void _do2() {
    int count = 1000000000; // 10 亿
    int start = DateTime.now().millisecondsSinceEpoch;
    int sum = 0;
    for (int i = 0; i < count; i++) {
      sum += i;
    }
    int end = DateTime.now().millisecondsSinceEpoch;
    print('${((end - start) / 1000).toStringAsFixed(4)} s');
    // print(sum);
  }
}

class Point {
  int x;
  int y;

  Point(this.x, this.y);
}
