import 'dart:async';

// ---->[01/02/timer_test2.dart]----

main(){
  print('1=======TAG1=======');
  Timer.run(() {
    print('2====Timer.run====');
  });
  Future(() {
    print('3====Future====');
  });
  Timer.run(() {
    print('4====Timer.run====');
  });
  print('5=======TAG2=======');
}