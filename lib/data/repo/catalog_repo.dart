import 'package:hive/hive.dart';
import 'package:collection/collection.dart';
import '../local/hive_boxes.dart';
import '../models/ingredient_master.dart';

class CatalogRepo {
  final Box<IngredientMaster> _box =
      Hive.box<IngredientMaster>(Boxes.master);

  List<IngredientMaster> all() => _box.values.toList();

  IngredientMaster? findByNameOrSynonym(String q) {
    final query = q.trim().toLowerCase();
    return _box.values.firstWhereOrNull((m) =>
      m.name.toLowerCase() == query ||
      m.synonyms.any((s) => s.toLowerCase() == query));
  }

  Future<IngredientMaster> addIfMissing(String name,
      {String defaultUnit = 'g'}) async {
    final existing = findByNameOrSynonym(name);
    if (existing != null) return existing;
    final m = IngredientMaster(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim(),
      defaultUnit: defaultUnit,
    );
    await _box.add(m);
    return m;
  }
}
