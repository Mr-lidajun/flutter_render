import 'dart:math';

import 'package:flutter/material.dart';

// ---->[08/06]----

/*

2. 更通俗的案例
官方给的案例不太贴合实际，下面我给个更直观的案例。 key 解决的核心问题是： 在组件位置变化时，元素无法感知的问题。 根源上来说，问题的起于是 状态私有属性 。

先看下面有问题的案例 【08/06】，其中勾选的状态在 State 内部维护。现在勾选 A ，点击 移除首位 ，将数据中的第一个移除。此时可以看出 B 莫名其妙被选中了。

简单说下代码，CheckableItem 可以传入一个名字，其中数据来源于 data 。

CheckableItem 的状态类中维护着私有变量 _checked 决定 Checkbox 的显示。如果明白前面颜色无法交换的原理，这里应该也不难理解。
因为在数据移除后，目前只有四个子组件，而对应的元素树无法感知，第一个子组件中 State 的 _checked 仍是 true 。这就是为什么移除第一个数据后， B 被选中的原因。

*/

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  List<String> data = ['A', 'B', 'C', 'D', 'E'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: Row(
        children:
            data.map((e) => CheckableItem(name: e)).toList(),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      actions: [
        IconButton(onPressed: reset, icon: const Icon(Icons.refresh)),
        TextButton(
          onPressed: removeFirst,
          child: const Text(
            'Remove first',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  void reset() {
    setState(() {
      data = ['A', 'B', 'C', 'D', 'E'];
    });
  }

  void removeFirst() {
    setState(() {
      data.removeAt(0);
      print("data = $data");
    });
  }
}

class CheckableItem extends StatefulWidget {
  final String name;

  const CheckableItem({super.key, required this.name});

  @override
  State<CheckableItem> createState() => CheckableItemState();
}

class CheckableItemState extends State<CheckableItem> {
  bool _checked = false;

  Widget buildCheckbox() {
    return Checkbox(
      value: _checked,
      onChanged: (bool? value) {
        setState(() {
          _checked = value ?? false;
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();
    print('initState');
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      height: 70,
      child: Center(
        child: Row(
          children: [
            buildCheckbox(),
            Text(
              widget.name,
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
          ],
        ),
      ),
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
