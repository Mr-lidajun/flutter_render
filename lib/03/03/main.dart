import 'package:flutter/material.dart';

// ---->[03/03]----

/*

3. 当 ColoredBox 有子级时
上面当测试中 ColoredBox 没有子级，所以在其对应的 Element 执行 updateChild 时返回空，mount 方法执行完毕。那么当 ColoredBox 有子级，比如说是 SizedBox ，又会发生什么呢？

这是，updateChild 中，第二参数就会传入 SizedBox 。然后世界线开始展开，SizedBox 将进入轮回。

SizedBox 将会经历和上面 ColoredBox 一样的流程，如果SizedBox 还有子级，那就会继续进入这个轮回中。这就是 单子组件 的宿命，直到没有子级组件时，对应的 Element#mount 方法才会终止。
Element#updateChild 为 _child赋值
  -> Element#inflateWidget
    -> SizedBox 创建元素对象
      -> 元素对象执行 mount 方法
        -> mount 中触发 SizedBox 创建渲染对象
          -> 渲染对象关联到渲染树中
            -> 触发 Element#updateChild 为 _child赋值 -> 重新回到开头的执行步骤（直到没有子级组件时，对应的Element#mount方法才会终止。）

*/

void main() {
  runApp(
    const Align(
      child: ColoredBox(
        color: Colors.red,
        child: SizedBox(
          width: 100,
          height: 100,
        ),
      ),
    ),
  );
}