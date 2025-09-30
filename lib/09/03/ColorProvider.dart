import 'package:flutter/material.dart';

class ColorProvider extends InheritedWidget {
  final Color color;

  const ColorProvider({super.key, required this.color, required super.child});

  static Color? maybeOf(BuildContext context) {
    final ColorProvider? widget =
        context.dependOnInheritedWidgetOfExactType<ColorProvider>();
    return widget?.color;
  }

  @override
  bool updateShouldNotify(covariant ColorProvider oldWidget) =>
      color != oldWidget.color;
}
