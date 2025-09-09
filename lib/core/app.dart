import 'package:flutter/material.dart';
import 'theme.dart';
import 'router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Livro de Receitas da Mãe',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: '/',
    );
  }
}
