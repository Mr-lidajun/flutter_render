import 'package:flutter/material.dart';

// ---->[10/01]----

/*
一、Element 与 Widget 的关系
从前面一路走来，通过源码中可以看出， Element 与 Widget 的关系只有两条：
```dart
[1]. Widget 对象通过 createElement 方法创建 Element 对象。
[2]. Element 对象会持有创建它的 Widget 对象。
```

*/

void main() {
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Widget text = Text('hello');
    return Row(children: [text, text]);
  }
}
