import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'item.dart';

import 'package:path/path.dart' as path;

// ---->[08/09]----

/*

三、探索 GlobalKey 的价值
可能很多人听别人说 GlobalKey 很重，又不知道为什么，所以用起来畏首畏尾的。一个东西如何，不是靠别人说他怎么怎么样，而是要看它实际做了什么。说一个对象很重，无非三个原因：
其一: 该类中持有很大的数据
其二: 该类可能引起其他类持有很大的数据
其三: 该类可能触发一些复杂逻辑

1. GlobalKey 类的结构
如下是 GlobalKey 类的结构，它有一个 State 类型的泛型。如下的四个方法这样我们知道通过 GlobalKey 可以做什么。它可以获取 Widget 、 BuildContext (本质是Element) 和 State ，这足够给 GlobalKey 发个最佳劳模奖。

注意一点： GlobalKey 并不持有任何成员， GlobalKey 并不持有任何成员， GlobalKey 并不持有任何成员！也就是说 GlobalKey 的重，并不是其自身原因。

2. GlobalKey 的源码实现
可能有人有疑问，一无所有的 GlobalKey 凭什么可以获取 Flutter 框架中的三大类对象。现在可以停下来仔细想想这三者的关系，其实只要获取到 元素 ，就能拿到其中 widget 对象；只要元素是 StatefulElement 就可以拿到 State 对象。

所以，对于 GlobalKey 来说，最重要的是如何获取 Element 对象。如下，可以清楚地看到：返回的元素对象是根据当前 key ，从 _globalKeyRegistry 映射中取值的。

如下，_globalKeyRegistry 是定义在 BuildOwner 中的一个映射，以 GlobalKey 为键，Element 为值。所以说每个 GlobalKey 都会和一个 Element 对象被记录在 _globalKeyRegistry 中。
从这里来看，GlobalKey 似乎也不是很重，是因 Element 本身也不是什么大对象，而且在元素节点卸载时，会注销掉_globalKeyRegistry
---->[BuildOwner#_globalKeyRegistry]----
final Map<GlobalKey, Element> _globalKeyRegistry = <GlobalKey, Element>{};

---->[BuildOwner#_unregisterGlobalKey]----
void _unregisterGlobalKey(GlobalKey key, Element element) {
  if (_globalKeyRegistry[key] == element) {
    _globalKeyRegistry.remove(key);
  }
}

---->[Element#unmount]
void unmount() {
  ....
  // Use the private property to avoid a CastError during hot reload.
  final Key? key = _widget?.key;
  if (key is GlobalKey) {
    owner!._unregisterGlobalKey(key, this);
  }
  ....
}

3. GlobalKey 可以用来干嘛
从 GlobalKey 的定义中我们可以看出它的价值就是获取 Widget 、State 和 BuildContext (也就是 Element) 。通过 BuildContext 就可以找到 渲染对象 ，获取尺寸等信息，甚至将渲染对象存储为图片；获取 State 就更有用了，我们可以通过获取状态类，执行它的一些方法，比如 Scaffold 、Navigator 、Form 等组件都有 GlobalKey 的使用场景。

下面来表演个祖传艺能，保存 Widget 成为 图片 ，如下所示：代码【08/09】

下面就是通过 GlobalKey 获取图片字节数组的核心逻辑，就是通过 key 获取元素，然后拿到渲染对象。保证它是 RenderRepaintBoundary 类型的渲染对象，然后执行其 toImage 方法。
注意其中有个 pixelRatio ，可以控制图片大小，值越大越清晰，默认是 1.0 。
Future<Uint8List?> _getBitsByKey(GlobalKey key) async {
  RenderObject? boundary = key.currentContext?.findRenderObject();
  if (boundary != null && boundary is RenderRepaintBoundary) {
    ui.Image img = await boundary.toImage(pixelRatio: 2);
    ByteData? byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    Uint8List? bits = byteData?.buffer.asUint8List();
    return bits;
  }
  return null;
}

对组件需要做的就是通过 RepaintBoundary 包裹，设置 key 。下面通过调试来看一下 GlobalKey 在整个过程中都做了什么。
final GlobalKey<MyAppState> _globalKey = GlobalKey();

RepaintBoundary(
  key: _globalKey,
  child: // 你想要变成图片的组件,
),


*/

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final GlobalKey<MyAppState> _globalKey = GlobalKey();

  Widget buildChild() {
    return SpecialColumn(
      item: SpecialColumnItem(
        url:
            "https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2031ed3efa78412cb73edb90fec8843f~tplv-k3u1fbpfcp-zoom-crop-mark:1304:1304:1304:734.awebp?",
        title: 'Flutter Basics',
        articleCount: 97,
        attentionCount: 188,
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      actions: [
        IconButton(onPressed: () => saveWidget(), icon: const Icon(Icons.save)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: RepaintBoundary(key: _globalKey, child: buildChild()),
    );
  }

  void saveWidget() async {
    Uint8List? bytes = await _getBitsByKey(_globalKey);
    print('bytes.length=${bytes?.length}');
    Directory directory = await getApplicationSupportDirectory();
    File file = File(path.join(directory.path, 'Widget2Image.png'));
    if (bytes != null) {
      file.writeAsBytes(bytes.toList());
    }
  }

  Future<Uint8List?> _getBitsByKey(GlobalKey key) async {
    RenderObject? boundary = key.currentContext?.findRenderObject();
    if (boundary != null && boundary is RenderRepaintBoundary) {
      ui.Image img = await boundary.toImage(pixelRatio: 2);
      ByteData? byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      Uint8List? bits = byteData?.buffer.asUint8List();
      return bits;
    }
    return null;
  }
}
