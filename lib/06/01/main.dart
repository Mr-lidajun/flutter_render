import 'package:flutter/material.dart';

// ---->[06/01]----

/*

我发现很多人喜欢把 StatefulWidget 和 State 两个概念混在一起理解。比如说，StatefulWidget 的生命周期，在 StatefulWidget 的 initState 中初始化数据，用StatefulWidget 的 setState 触发更新等表述。其实 StatefulWidget 和 State 是两个不同的东西，不能把它们两个混为一谈。

在本文的探索之前，先问自己下面三个问题，稍微思考一会：
1. State 状态类是何时被实例化的?
2. State 状态类中有哪些成员对象? 它和 Widget 、Element 有什么关系？
3. State 状态类的各个回调是在何时触发的?

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
  Widget build(BuildContext context) {
    return const Align(
      child: SizedBox(
        width: 100,
        height: 100,
        child: ColoredBox(color: Colors.red),
      ),
    );
  }
}
