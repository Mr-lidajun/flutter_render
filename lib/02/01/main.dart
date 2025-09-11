import 'package:flutter/material.dart';

// ---->[02/01]----

/*
一、根元素挂载方法触发
上回说到，在根组件实例化完成后，执行 attachToRenderTree 方法，在 Tag2 处完成了根元素 的实例化。现在即将来到 BuildOwner#buildScope 中一探究竟。

*/

void main() {
  runApp(const ColoredBox(color: Colors.red));
}