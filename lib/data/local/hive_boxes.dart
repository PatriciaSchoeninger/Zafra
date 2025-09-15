import 'package:hive_flutter/hive_flutter.dart';

import '../data_models/ingredient_master.dart';
import '../data_models/ingredient_item.dart';
import '../data_models/recipe.dart';

class Boxes {
  static const master = 'ingredient_master';
  static const recipe = 'recipes';

  static Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(IngredientMasterAdapter());
      Hive.registerAdapter(IngredientItemAdapter());
      Hive.registerAdapter(RecipeAdapter());
    }

    await Hive.openBox<IngredientMaster>(Boxes.master);
    await Hive.openBox<Recipe>(Boxes.recipe);
  }
}
