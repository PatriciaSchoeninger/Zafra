import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'theme.dart';
import 'router.dart';

class LivroReceitasApp extends StatelessWidget {
  const LivroReceitasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        title: 'Livro de Receitas da Mãe',
        routerConfig: router,
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        themeMode: ThemeMode.system,
      ),
    );
  }
}
