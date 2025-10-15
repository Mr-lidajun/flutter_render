// ---->[11/05]----

/*
另外，MotorSystem 依赖于 RespiratorySystem ，自然也就可以使用其中的属性。如下在 MotorSystem 中可以访问 RespiratorySystem 中的 oxygen 属性，这样就可以借此处理一些逻辑，体现了其 依赖性。
---->[11/05/test.dart]----
main() {
  Human toly = Human();
  toly.run(); // 运行
  toly.run(); // 运行
  toly.run(); // 运行
  toly.inhale(); // 吸气
  toly.run(); // 运行
}

这就可以简单的模拟一下两个系统运行中对氧气的消耗情况，及通过 inhale 获取氧气。
========初始化【呼吸系统】完成====氧气值:10=======
========初始化【运动系统】完成=========
========呼吸系统正常运行===氧气值:9======
========运动系统正常运行=====氧气值:6=======
========呼吸系统正常运行===氧气值:5======
========运动系统正常运行=====氧气值:2=======
========氧气不足，运动系统无法完成==氧气值:2
========呼吸系统吸入10点氧气值===氧气值:12========
========呼吸系统正常运行===氧气值:11======
========运动系统正常运行=====氧气值:8=======

 */

class Human with RespiratorySystem, MotorSystem {
  Human() {
    initInstances();
  }

  bool get alive => oxygen > 0;
}

class SystemConfig {
  final int inhaleCount;
  final int motorCost;

  const SystemConfig({this.inhaleCount = 10, this.motorCost = 3});
}

mixin MotorSystem on RespiratorySystem {
  int _cost = 0; // 每次消耗的氧气量

  @override
  void initInstances({int count = 3}) {
    super.initInstances();
    _cost = count;
    print('========初始化【运动系统】完成=========');
  }

  @override
  void run() {
    if (oxygen <= 3) {
      print('========氧气不足，运动系统无法完成==氧气值:$oxygen');
      return;
    }
    super.run();
    oxygen -= _cost;
    print('========运动系统正常运行=====氧气值:$oxygen=======');
  }
}

mixin RespiratorySystem {
  int oxygen = 0;
  int _inhaleCount = 0; // 每次吸入的氧气量

  void initInstances({int count = 10}) {
    oxygen = 10;
    _inhaleCount = count;
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
