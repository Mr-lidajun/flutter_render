import 'package:flutter/material.dart';

// ---->[04/01]----

/*

通过本章对 多子元素 和 多子渲染对象 数据结构的探索，现在已经认清了 元素树 和 渲染树 在框架中最真实的组织结构。了解完单子和多子节点之后，其实你就可以理解所有的结构，因为大结构都是通过小结构构成的，任何小结构都是有 单子 、多子 、叶子 构成的。

*/

void main() {
  runApp(
    Column(
      children: [
        SizedBox(width: 60, height: 60, child: ColoredBox(color: Colors.red)),
        SizedBox(
          width: 40,
          height: 40,
          child: ColoredBox(color: Colors.yellow),
        ),
        SizedBox(width: 20, height: 20, child: ColoredBox(color: Colors.blue)),
      ],
    ),
  );
}
