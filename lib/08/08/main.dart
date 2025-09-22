import 'dart:math';

import 'package:flutter/material.dart';

// ---->[08/08]----

/*

4. 认识 LocalKey 一族之 ValueKey 和 ObjectKey
说 ValueKey 之前先看一下 Key ，首先 Key 是一个抽象类，本身不可以实例化。但在代码中你仍可以传入字符串，通过 Key 构造方法实例化对象，这是为什么呢？
Key('toly')

如下的 factory 关键字，表示 Key 有个工厂构造方法，返回的真实类型就是 String 类型的 ValueKey 。也就是说本质上。
Key('toly')  等价于
ValueKey<String>('toly')

前者是一个简单的书写形式，如果标识不是 String 类型的，可以使用 ValueKey 传入特点的类型。

如下， 【08/08】 中，使用 ValueKey 将名称作为值，这里的泛型可以省略，但加上表意会更清楚。
children: data
          .map(
            (e) => CheckableItem(
              // key: Key(e),
              key: ValueKey(e),
              name: e,
            ),
          ).toList(),

这样，就可以避免状态的丢使。可以结合多子组件的更新原理，思考一下 ValueKey 产生功效的本质原因。

是因为 == 号的覆写，使得两个 key 的相等取决于其 value 的值。所以在 oldKeyedChildren 中可以根据 key 取出元素节点。另外 ObjectKey 和 ValueKey 在代码实现中本质是一样的，只不过是写法的差异。
你也完全可以自定义自己的 Key ，其实就是继承一些 Key ，持有数据，重写 == 而已，没什么很高深的东西。

到这里，你应该能体会出，为什么 Dismissible 组件要求使用者必须提供 Key 了吧。
const Dismissible({
  required Key super.key,
  required this.child,

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
            data
                .map(
                  (e) => CheckableItem(
                    // key: Key(e),
                    key: ValueKey(e),
                    name: e,
                  ),
                )
                .toList(),
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
