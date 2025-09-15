import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repo/catalog_repo.dart';
import '../data/repo/recipe_repo.dart';

final catalogRepoProvider = Provider((ref) => CatalogRepo());
final recipeRepoProvider  = Provider((ref) => RecipeRepo());
