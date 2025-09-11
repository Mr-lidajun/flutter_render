import 'package:flutter/material.dart';

// ---->[01/01]----

/*
一、探索 runApp 方法做了什么
自从第一次运作 Flutter 代码，有个方法就一直陪伴着你，而你应该没有思考过这个方法到底干了什么。既然本册要探索 Flutter 框架的渲染机制，自然要从这个梦的起点开始说起： runApp 方法。

1. 初看 runApp 方法
当在 runApp 中传入了一个红色的 ColoredBox 组件，如下所示，屏幕就会呈现红色，我们的探索将从这里开始启程：

对 runApp 方法 的认知：首先，它是定义在框架的 widgets 包 binding.dart 文件中的一个 全局方法 。其次，它的入参是一个 Widget 对象，且无返回值。
---->[src/widgets/binding.dart]----
void runApp(Widget app) {
  // 暂略...
}

所以这个方法会通过入参组件做一些事，导致了屏幕渲染出内容，那它到底做了什么事呢？有了疑问是好事，它会作为一条线索，引导探索进程：我们可以追寻着这个 app 组件对象，去探索在它身上发生了什么事。

*/

void main() {
  runApp(const ColoredBox(color: Colors.red));
}