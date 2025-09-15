import 'package:flutter/material.dart';

ThemeData buildTheme(Brightness b) {
  final base = ThemeData(
    useMaterial3: true,
    brightness: b,
    colorSchemeSeed: Colors.purple,
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(fontSizeFactor: 1.1), // fonte maior
  );
}
