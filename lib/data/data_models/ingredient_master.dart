import 'package:hive/hive.dart';
import '../../core/hive_ids.dart';

part 'ingredient_master.g.dart';

@HiveType(typeId: HiveIds.ingredientMaster)
class IngredientMaster extends HiveObject {
  @HiveField(0) String id;              // uuid
  @HiveField(1) String name;            // canônico
  @HiveField(2) List<String> synonyms;  // sinônimos
  @HiveField(3) String defaultUnit;     // ex: g, ml, xic
  @HiveField(4) double? densityGPerMl;  // g/ml (opcional)
  @HiveField(5) double? defaultPrice;   // preço base por unidade padrão
  @HiveField(6) List<String> tags;

  IngredientMaster({
    required this.id,
    required this.name,
    this.synonyms = const [],
    required this.defaultUnit,
    this.densityGPerMl,
    this.defaultPrice,
    this.tags = const [],
  });
}
