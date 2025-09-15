import 'package:flutter/material.dart';

ThemeData buildTheme(Brightness b) {
  final base = ThemeData(
    useMaterial3: true,
    brightness: b,
    colorSchemeSeed: Colors.purple,
  );

  // Corrige erro de fonte null no Flutter 3.22+
  final fixedTextTheme = base.textTheme.copyWith(
    bodyLarge: base.textTheme.bodyLarge?.copyWith(fontSize: 16),
    bodyMedium: base.textTheme.bodyMedium?.copyWith(fontSize: 14),
    bodySmall: base.textTheme.bodySmall?.copyWith(fontSize: 12),
  );

  return base.copyWith(
    textTheme: fixedTextTheme,
  );
}
