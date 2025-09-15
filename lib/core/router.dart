import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/home/home_page.dart';
import '../features/recipe_edit/recipe_edit_page.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (c, s) => const HomePage(),
      routes: [
        GoRoute(
          path: 'edit',
          builder: (c, s) => RecipeEditPage(
            recipeId: s.uri.queryParameters['id'],
          ),
        ),
      ],
    ),
  ],
);
