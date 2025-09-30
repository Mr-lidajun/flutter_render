import 'package:flutter/material.dart';

// ---->[09/04]----

/*
四、探索 ParentDataWidget
在 《Flutter 布局探索 - 薪火相传》的十一章，探索 Flexible 组件时其实就是在看 ParentDataWidget 的工作原理。当时的着重点在于布局的特性分析，这里就详细地介绍一下它的作用。本节测试代码见： 【09/04】

1. 探索 ParentDataWidget 组件
从 ParentDataWidget 的定义中可以看出，它主要是抽象出 applyParentData 方法，为 RenderObject 设置 ParentData 数据。其作为 Widget 的 createElement 使命，在该类中实现，返回 ParentDataElement 。 另外注意一点，ParentDataWidget 有一个泛型，该泛型继承自 ParentData 。

比如 Flexible 组件继承自 ParentDataWidget 泛型为 FlexParentData ，其中有两个成员属性 flex 和 fit 。

在 applyParentData 方法实现中，就是对 RenderObject 的 parentData 属性进行设置。可以看到，这里会进行强制类型转换，这也就说明 Flexible 只能用于: 支持子渲染对象 parentData 属性类型是 FlexParentData ，的渲染对象对应的组件中。一般来说指的就是 Flex 组件。

所以 ParentDataWidget 最大的一个特点就是，使用场景的限制性 。每一个 ParentDataWidget 的实现类，只是为某一种渲染对象而服务。

2. 渲染对象的 parentData 有什么用
parentData 是每个 RenderObject 都可以持有的数据，通过它，子级可以给父级渲染对象一些数据，用于父级渲染对象的布局逻辑中。比如 RenderFlex 在布局时，会根据子级渲染对象的 parentData 获取子级期望的 flex 和 fit 值，从而达到一些特殊的布局效果。

在 RenderStack 中根据子级渲染对象的 parentData 数据，对 Positioned 组件提供的 StackParentData 数据进行额外处理，从而达到一些特殊的布局效果。

另外 KeepAlive 组件也是如此，这在 《Flutter 滑动探索 - 珠联璧合》的十二章已经详细介绍过了，这里就不再赘述，你现在可以自己去回味一下。总的来看，Flutter 中 ParentDataWidget 的实现类并不是很多，但各个身怀绝技。
自定义ParentDataWidget 的门槛是比较高的，因为它和渲染对象是对应的，自定义 ParentDataWidget 就意味着你需要自定义一种 RenderObject 对附加数据进行使用。

3. ParentDataWidget#applyParentData 是何时触发的
通过调试可以看出，是在元素 mount 时，触发 attachRenderObject 关联渲染对象时触发的。现在看这个场景是不是非常熟悉了。所以本质上 applyParentData 方法的触发还是元素的功劳，Widget 只是在方法中起到配置的作用。

另外注意，ParentDataWidget 为 谁 设置 parentDate，也就是 applyParentData 方法中的入参 RenderObject 是谁。如下，是其子级持有的 renderObject 。

到这里，Proxy 一族的组件和元素就介绍完毕了，Flutter 框架中 Widget 和 Element 体系中，最后一块拼图已经获得。现在你的眼中应该有了一个全貌，接下来，我们将对前面的探索进行一个总结，归纳一些在构建期间，核心三大类型之间的关系，下一章，探索继续 ~

*/

void main() {
  runApp(
    const MaterialApp(
      home: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      // textDirection:TextDirection.ltr,
      children: const [
        Flexible(
          child: SizedBox(
            width: 100,
            height: 100,
            child: ColoredBox(
              color: Colors.blue,
            ),
          ),
        ),
        SizedBox(
          width: 100,
          height: 100,
          child: ColoredBox(
            color: Colors.red,
          ),
        ),
      ],
    );
  }
}