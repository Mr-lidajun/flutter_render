// ---->[11/03]----

/*
3. 混入多个 mixin 时同名方法的触发
比如现在需要在实现一个 运动系统 - MotorSystem ，其中也有initInstances 和 run 方法。

那问题来了，如果 Human 再混入 MotorSystem ，由于两个 mixin 系统中都存在 run 方法，那下面红框中会调用谁的方法呢？
答案是 后来居上 。

输出：
========初始化【运动系统】完成=========
========运动系统运行=======

另外注意一点，对于多个 mixin 方法同名，在混入时有严格的限制，方法签名需要保持一致。

4. mixin 的依赖关系
如果想要在 MotorSystem#initInstances 时，同时初始化 RespiratorySystem 该怎么办? 通过 on 关键字依赖 RespiratorySystem 即可。

我为什么用 依赖 这个词呢？对于 mixin 来说 继承 过于 “不解风情” ，这里相当于 MotorSystem 需要使用 RespiratorySystem 的功能，并没有很强的继承性。这样两个系统就能同时运作了。
输出：
========初始化【呼吸系统】完成====氧气值:10=======
========初始化【运动系统】完成=========
========呼吸系统正常运行===氧气值:9======
========运动系统运行=======

另外有个非常小的细节，可以说明 继承 extends 和 混入 mixin 的差别，这也是理解为什么 XXXBinding 在声明时混入比较复杂的关键。对于继承来说，你只要继承自一个类，就说明你拥有先祖的一切非私有能力，右侧是非常正常的继承关系。

*/

class Human with RespiratorySystem, MotorSystem {
  Human() {
    initInstances();
  }

  bool get alive => oxygen > 0;
}

mixin RespiratorySystem {
  int oxygen = 0;
  int _inhaleCount = 0; // 每次吸入的氧气量

  void initInstances({int inhaleCount = 10}) {
    oxygen = 10;
    _inhaleCount = inhaleCount;
    print('========初始化【呼吸系统】完成====氧气值:$oxygen=======');
  }

  void inhale() {
    oxygen += _inhaleCount;
    print('========呼吸系统吸入$_inhaleCount点氧气值===氧气值:$oxygen========');
  }

  void run() {
    oxygen--;
    print('========呼吸系统正常运行===氧气值:$oxygen======');
  }
}

mixin MotorSystem on RespiratorySystem {
  int _cost = 0; // 每次消耗的氧气量

  // 对于多个 mixin 方法同名，在混入时有严格的限制，方法签名需要保持一致。
  @override
  void initInstances({int inhaleCount = 3}) {
    super.initInstances();
    _cost = inhaleCount;
    print('========初始化【运动系统】完成=========');
  }

  @override
  void run() {
    super.run();
    print('========运动系统运行=======');
  }
}

/*mixin MotorSystem {
  int _cost = 0; // 每次消耗的氧气量

  // 对于多个 mixin 方法同名，在混入时有严格的限制，方法签名需要保持一致。
  void initInstances({int count = 3}) {
    _cost = count;
    print('========初始化【运动系统】完成=========');
  }

  void run() {
    print('========运动系统运行=======');
  }
}*/
