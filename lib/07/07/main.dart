import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ---->[07/07]----

/*
三、关于更新的效率问题
通过上面分析我知道，当某个节点更新时，其子树都会触发更新。所以更新的复杂程度是和树深有关系的，理论上来说子树节点越少更新越快。理论上来说，通过单独抽离组件，我们可以精确的对某个节点进行提取，单独更新；或通过 ValueListenableBuilder 精确地对某一节点进行更新。

1.不要空谈效率
但我们要清楚地是，节点的更新只是在做 设置属性 的工作，而且也有几道屏障来确保不会做无用的设置。所以当你想要精确控制某一节点的更新时，要先考量一下，我这么做是否会影响代码的阅读。

2. 元素节点的更新效率分析
在直觉上来说，更新 1 个节点和更新 100 个节点，肯定选前者。 但是如果场景切换一下，你每秒能赚 1 个亿，你还会计较买个东西花 1 块钱还是 100 块吗？

如下的测试中，执行 10 亿次累加，耗时大约 7 秒，累加中包括计数器增加、sum 值累加、i 值判断三个步骤。 也就是说，赋值、比较的语句，在一秒之内可以执行 数亿 次。
而元素节点的更新，只是为渲染对象设置属性而已，都是些基本的语句，所以没有必要为了少刷 几个节 点而费尽心机。

3. 万事把握 度 是最重要的
但这并不代表你可以放飞自我，满屏 setState ，不计后果的铺张浪费，勤俭节约是我们的传统美德。但勤俭，也并不等于一毛不拔，为了一块钱，跑十站路，不是勤俭。下面我们来进行一些测试，思路是通过一个 3s 间隔轮训的 Timer 触发更新，对比不同情况下 build 的耗时情况。 *注* : 性能查看请在 --profile 模式下进行。

如下，是通过 ValueListenableBuilder 局部更新一个节点时，一帧中的构建时间，build 耗时 0.1 ms 。测试代码 【07/02】。

如下，是通过 setState 局部更新一个节点时，一帧中的构建时间，build 耗时也是 0.1 ms 。测试代码 【07/03】。可以看到对于几个节点的优化几乎没有什么影响，但用了 ValueListenableBuilder 代码会更复杂一些。

可能有人觉得不过瘾，节点太少，看不出什么优劣。在 【07/04】 的测试代码中，故意套了 150 个 SizedBox 组件。来看一下通过 setState 重新构建时的耗时情况。

此时【07/05】 中通过 ValueListenableBuilder 局部更新一个节点时，每次 build 耗时大概在 0.2 ms 。也就是说，如果你的 setState 可能导致上百个节点的更新，那么通过定点更新确实可以起到微小的作用。

只要保证每 16.66 ms 能完成一帧的全部渲染逻辑，就能达到 60 fps 的效果，在用户眼中就不会出现掉帧。另外，构建只是一帧工作中的组成一小部分，从图中可以看出，绘制 和 合成 才是耗时的大户。

4. 再看 StatefulWidget 组件
了解 Flutter 对元素及渲染对象的更新机制，其实我们并不用太抗拒 StatefulWidget ，它是组合组件中不可或缺的一个部分。StatefulWidget 的价值在于对可变状态的封装，让使用者可以非常简单的完成一下复杂的变化效果。

就拿 ElevatedButton 来说，如下，在点击时会出现水波纹。前面说过，只要界面产生了一丝的变动，就表示元素树或渲染树的某处触发了更新。也就是说， ElevatedButton 组件中的水波纹扩散中每一帧都有更新操作。
通过封装，使用者就可以直接拿来使用，而不用在意其中的实现细节。

水波纹是如何产生的、如何触发重绘的、如何进行动画的，这些和使用者都没有关系。封装使得 ElevatedButton 成为一个独立的个体，直接作为一个组件来使用。
而将其单独封装之后，其内部的状态更新，只会从该组件创建的元素开始，是一个局部的子树，这也是封装的附加好处。

了解元素节点更新后，子元素之所以触发 update 方法，是因为父节点触发更新。现在可以回看 State#didUpdateWidget 方法，它是在 本元素 节点触发 update 时，回调的。
也就是说 didUpdateWidget 是在 父级节点 更新时的回调。我们可以根据当前配置的变化进行一些逻辑处理。


*/

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _animation = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: toggle,
        child:
            _animation
                ? const Icon(Icons.stop)
                : const Icon(Icons.directions_run),
      ),
      body: Center(
        child: CupertinoActivityIndicator(
          color: Colors.red,
          animating: _animation,
          radius: 18,
        ),
      ),
    );
  }

  void toggle() {
    setState(() {
      _animation = !_animation;
    });
  }
}
