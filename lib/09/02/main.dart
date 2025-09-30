import 'package:flutter/material.dart';

// ---->[09/02]----

/*
一、认识 ProxyWidget 与 ProxyElement 一族
可能一看到 Proxy ，很多人本能的感觉非常高大上，感觉很难的样子。估计是挨过 代理模式 的不少毒打，其实代理这个概念非常简单，一句话可以很贴切的表示代理是干嘛的。
```
我们不生产水,我们只是大自然的搬运工。
```
言外之意，我们只是大自然的代理，对水进行加工而已。

1. 族系关系
ProxyWidget 衍生出 InheritedWidget 和 ParentDataWidget 两类非常重要的组件，它们的 createElement 方法，分别返回对应类型的 Element ，如下所示：

其中 InheritedWidget 的价值不用我多说，MediaQuery 、Directionality 、各种 Theme 等组件，都是 InheritedWidget 的实现类。可以沿树上溯查询数据，这对 Flutter 主题至关重要。甚至是 provider 、flutter_bloc 等状态管理，对数据的维护、提取都是依赖于 InheritedWidget 实现的。

另外 ParentDataWidget 一族可能大家没怎么听说过，不过要提到 Expanded 、Flexible、KeepAlive 、Positioned 这些组件，大家应该不陌生吧。没错，它们就是最常用的 ParentDataWidget 实现类。

从上面可以看出，确实 代理都是黑科技 ，能实现一些一般组件无法办到的事。

2. ProxyWidget 的源码实现
你没有看错，这就是 ProxyWidget 的全部代码，其中只是维护了一个 Widget 类型的 child 成员。

也就是说，创建 ProxyWidget 对象时，使用者必须传入一个子组件。言外之意就是：
```
我们不生产 Widget ,我们只是 Flutter 框架的搬运工。
```

3. ProxyElement 的源码实现
ProxyWidget 继承中 ComponentElement ，说明该元素在整体流程上和 StatelessElement 是一样的。如下 tag1 出表示：在创建组件时，返回 child 组件，这也就显示出了 ProxyWidget 搬运，或说 白嫖 组件本质。

另外在 update 方法中，会触发抽象方法 notifyClients ，这就是 代理黑魔法 的关键之处。这样两个顶层的抽象就看完了，接下来通过实现类来分析一下 InheritedWidget 实现的原理。


二、探索 InheritedWidget 组件
我们知道 InheritedWidget 可以在组件中存储数据，其子树节点可以通过 上下文 获取数据。从而达到 跨节点的数据传输 的功能。本节就来探索一下，这个功能的本质是什么。

1.探索 InheritedWidget 组件
如下，是 InheritedWidget 的所有源码，它是一个抽象类，可以看出其中只定义了一个 updateShouldNotify 方法。其作为 Widget 的 createElement 使命，在该类中实现，返回 InheritedElement 。

其实可用看出，InheritedWidget 本身似乎并没干什么大事。

2. 通过 Directionality 组件看 InheritedWidget 的价值
Directionality 是最简单的 InheritedWidget 实现类，通过它来认识 InheritedWidget 是再好不过的了。

实现我们通过看一个异常，并引入 Directionality 来解决这个异常。
如下，通过 Row 盛放两个色块，直接在 runApp 跑这个组件。源码于 【09/01】

这应该是再平常不过的代码了，但是运行却会出错，看样子是 textDirection 为空。

如果让 MyApp 在 MaterialApp 之下，也不会出错。为 Row 明确添加 textDirection 也不会出错。这就说明：在 MaterialApp 之下，一定蕴含中什么，可以为 Row 的 textDirection 属性赋值。

如下，确实 RenderFlex 在构造是通过一个方法来获取 textDirection 属性：

这个方法核心就是通过 Directionality.maybeOf(context) 来获取 TextDirection 对象，如下，此时是 null 。

如果此时在 MyApp 上嵌套一个 Directionality，就可以发现此时 Directionality.maybeOf(context) 就有值了。从这里可以看出 InheritedWidget 最重要的价值在于：组件可以在节点上存储数据，其下的子树节点可以对数据进行获取。
---->[09/02]----
const Directionality(
  textDirection: TextDirection.ltr,
  child: MyApp(),
),


*/

void main() {
  runApp(
    const Directionality(textDirection: TextDirection.ltr, child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      // textDirection:TextDirection.ltr,
      children: const [
        SizedBox(
          width: 100,
          height: 100,
          child: ColoredBox(color: Colors.blue),
        ),
        SizedBox(width: 100, height: 100, child: ColoredBox(color: Colors.red)),
      ],
    );
  }
}
