import 'package:hive_flutter/hive_flutter.dart';
import '../../core/hive_ids.dart';
import '../models/recipe.dart';
import '../models/ingredient_item.dart';
import '../models/ingredient_master.dart';

class Boxes {
  static const recipes = 'recipes_box';
  static const masters = 'ingredient_master_box';

  static Future<void> init() async {
    // inicializa Hive no app
    await Hive.initFlutter();

    // registra os adapters (se ainda não estiverem registrados)
    if (!Hive.isAdapterRegistered(HiveIds.recipe)) {
      Hive.registerAdapter(RecipeAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveIds.ingredientItem)) {
      Hive.registerAdapter(IngredientItemAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveIds.ingredientMaster)) {
      Hive.registerAdapter(IngredientMasterAdapter());
    }

    // abre as caixas
    await Hive.openBox<Recipe>(recipes);
    await Hive.openBox<IngredientMaster>(masters);
  }
}
