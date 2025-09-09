import 'package:flutter/material.dart';

ThemeData buildTheme() {
  final base = ThemeData.light(useMaterial3: true);
  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(
      primary: const Color(0xFFEB9800), // laranja que você curte 😉
    ),
    scaffoldBackgroundColor: const Color(0xFFFDFCF9),
    textTheme: base.textTheme.apply(
      bodyColor: const Color(0xFF222222),
      displayColor: const Color(0xFF222222),
    ),
  );
}
