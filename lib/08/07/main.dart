import 'dart:math';

import 'package:flutter/material.dart';

// ---->[08/07]----

/*

3. 认识 LocalKey 一族之 UniqueKey
Key 的族系非常简单，就两个分支 LocalKey 和 GlobalKey 。我们知道 key 的作用就是为 Widget 确认唯一的身份，可以在多子组件更新中被识别，这就是 LocalKey 的作用。
所以 LocalKey 保证的是 相同父级 组件的身份唯一性。而 GlobalKey 是整个应用中，组件的身份唯一。

有人可能会问，不就是个身份标识吗，为什么 LocalKey 要分这么多种? 两个字 场景 。就像去楼下超市买瓶饮料，选择步行；去外省游玩选择开车；到月球散步选择做宇宙飞船。不同的工具有其使用的场景和局限性，不是因为它存在所以存在，而是因为需要它才存在。

首先看 UniqueKey ，其实它就是一个什么都没有的对象，每次实例化都是一个不同的对象。这就能保证该对象的 唯一性 。由于不持有任何数据，UniqueKey 是最轻量的。

下面来看看 UniqueKey 有什么局限性。在 【08/07】 的代码中，添加了 UniqueKey ，大家可以想想会发生什么？

如下，选中 A 、C ，在移除第一个数据时，可以发现 C 的状态被重置了。通过日志可以发现，四个组件对应的状态类都重新执行了 initState 。可能让人费劲，为什么全部状态会重新初始化，因为 State 的初始化发生于元素的 mount 时期，这就说明对应的 Element 节点被重新创建了。

其实原因很简单，oldKeyedChildren 中记录的是上一波 key 和元素的对应关系。而此时的 UniqueKey 在 build 方法中重新实例化，自然是在 oldKeyedChildren 映射中取不出元素节点，故为子元素oldChild 此时为null 。

接下来在 5845 行中执行 updateChild 方法 ，如果 child 为 null ，会触发 inflateWidget 重建元素。接下来 inflateWidget 中会发生什么，就不用我多说了吧，前面都说烂了。

所以 UniqueKey 只适合于那种把组件作为成员变量的场景。 在 build 中不会重新实例化组件， UniqueKey 自然也不会变化。但如果组件需要在 build 中根据数据进行构建，那 UniqueKey 就不堪重负了。此时有请 ValueKey 出场。

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
            data.map((e) => CheckableItem(key: UniqueKey(), name: e)).toList(),
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
