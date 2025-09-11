import 'dart:async';

import 'package:flutter/material.dart';

// ---->[01/02]----

/*
一、探索 runApp 方法做了什么
自从第一次运作 Flutter 代码，有个方法就一直陪伴着你，而你应该没有思考过这个方法到底干了什么。既然本册要探索 Flutter 框架的渲染机制，自然要从这个梦的起点开始说起： runApp 方法。

2、认识 Timer.run 方法
在正式说 runApp 方法之前，先来个小铺垫，认识一个 Timer.run 的静态方法。首先，该静态方法入参是一个无参无返回值的函数。简单来说，就是一个任务函数。

其次，入参的任务是异步执行的。如下可以看出 2 在 3 后面打印。
---->[01/02/timer_test1.dart]---
import 'dart:async';

main(){
  print('1=======TAG1=======');
  Timer.run(() {
    print('2==== Timer.run');
  });
  print('3=======TAG2=======');
}



*/

main() {
  print('1=======TAG1=======');
  Foo()
    ..scheduleAttachRootWidget()
    ..scheduleWarmUpFrame();
  print('5=======TAG2=======');
}

class Foo {
  void scheduleAttachRootWidget() {
    Timer.run(() {
      print('2====scheduleAttachRootWidget');
    });
  }

  void scheduleWarmUpFrame() {
    Timer.run(() {
      print('3====scheduleWarmUpFrame do1');
    });

    Timer.run(() {
      print('4====scheduleWarmUpFrame do2');
    });
  }
}
