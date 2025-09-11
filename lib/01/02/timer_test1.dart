import 'dart:async';

// ---->[01/02/timer_test1.dart]----

main(){
  print('1=======TAG1=======');
  Timer.run(() {
    print('2====Timer.run====');
  });
  print('3=======TAG2=======');
}