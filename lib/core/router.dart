import 'package:flutter/material.dart';
import '../features/home/home_page.dart';
import '../features/recipe_edit/recipe_edit_page.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const HomePage());
      case '/recipe/edit':
        return MaterialPageRoute(builder: (_) => const RecipeEditPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('404')),
            body: Center(child: Text('Rota não encontrada: ${settings.name}')),
          ),
        );
    }
  }
}
