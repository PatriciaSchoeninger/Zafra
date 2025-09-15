import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../local/hive_boxes.dart';
import '../data_models/recipe.dart';

class RecipeRepo {
  final Box<Recipe> _box = Hive.box<Recipe>(Boxes.recipe);
  final _uuid = const Uuid();

  List<Recipe> list({String? search}) {
    var items = _box.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    if (search?.trim().isNotEmpty == true) {
      final q = search!.toLowerCase();
      items = items.where((r) =>
          r.title.toLowerCase().contains(q) ||
          r.ingredients.any((i) => i.name.toLowerCase().contains(q))
      ).toList();
    }

    return items;
  }

  Future<Recipe> create(String title) async {
    final r = Recipe(id: _uuid.v4(), title: title);
    await _box.add(r);
    return r;
  }

  Future<void> save(Recipe r) async {
    r.updatedAt = DateTime.now();
    await r.save();
  }

  Future<void> delete(Recipe r) => r.delete();
}
