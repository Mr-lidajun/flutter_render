// ---->[11/06/m.dart]----

/*
5. mixin 依赖普通类或抽象类

另外，还有一个非常重要的，可能很少人在意，或是很少有文章提及的要点：其实 mixin 是可以依赖于 普通类 或 抽象类 的。如下所示：WidgetsBinding 通过 on 依赖了 BindingBase 抽象类。
mixin WidgetsBinding
    on
        BindingBase,
        ServicesBinding,
        SchedulerBinding,
        GestureBinding,
        RendererBinding,
        SemanticsBinding {
  @override
  void initInstances() {

下面我们进行一些简化，来探索这个知识点。 如下，B on D ，此时 B 可以访问 D 中的 方法 和 成员 ：
---->[11/06/m.dart]----
mixin B on D, C {
  int get count => _count;
  void log() => say();
}

mixin C {}

abstract class D {
  int _count = 0;
  void say();
}

当我们直接对 A 混入 C 、B 时，会出现异常。这说明这种方式在使用时是有限制的：
class A with C, B {}
提示错误：
'B' can't be mixed onto 'Object' because 'Object' doesn't implement 'D'. (Documentation)

Try extending the class 'B'.

简单来说，这个限制就是 此时 A 必须继承自 D ，如下所示，就不会出错：
class A extends D with C, B {
  @override
  void say() {
    print(count);
  }
}

也就是说，如果一个 mixin 依赖于(on) 一个抽象类，那么被混入的类必须要继承自该 抽象类 。有了目前的这些基础，我们就可以去看 WidgetsBinding 初始化的流程了。

 */

// class A with C, B {}
class A extends D with C, B {
  @override
  void say() {
    print(count);
  }
}

mixin B on D, C {
  int get count => _count;

  void log() => say();
}

mixin C {}

abstract class D {
  int _count = 0;

  void say();
}
