import 'package:flutter/material.dart';

// ---->[04/02]----

/*

比如下面的组件，就是探索单子时的树和本节探索双子的树联合而成的树形结构。所有本质上来说，通过 单子、双子 和 叶子 组件，我们就能完成任何的显示效果。可是这样会有一个问题，这样的嵌套过于复杂，而且语义也不是很明确，并不适合阅读。

这就像是一本书从头到尾没有分段一样，虽然表意上没有什么问题，但是确实很不友好。于是在 Flutter 框架中提供了 组合型组件 的概念，它们可以通过已有的组件，来构建一定的结构进行封装，简化使用。下一篇我们将进入另一片领域，跟随我的脚步，一起探索吧 ~

*/

void main() {
  runApp(
    Align(
      child: ColoredBox(
        color: Colors.red,
        child: SizedBox(
          width: 100,
          height: 200,
          child: Column(
            children: const [
              SizedBox(
                width: 60,
                height: 60,
                child: ColoredBox(color: Colors.red),
              ),
              SizedBox(
                width: 40,
                height: 40,
                child: ColoredBox(color: Colors.yellow),
              ),
              SizedBox(
                width: 20,
                height: 20,
                child: ColoredBox(color: Colors.blue),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
