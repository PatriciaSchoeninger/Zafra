import 'package:hive/hive.dart';
import '../../core/hive_ids.dart';

part 'ingredient_item.g.dart';

@HiveType(typeId: HiveIds.ingredientItem)
class IngredientItem extends HiveObject {
  @HiveField(0) String? masterId;   // pode ser null se não vincular ao catálogo
  @HiveField(1) String name;        // denormalizado (snapshot do nome usado)
  @HiveField(2) double quantity;
  @HiveField(3) String unit;        // g, ml, xic, un...
  @HiveField(4) double? price;      // custo opcional
  @HiveField(5) bool haveAtHome;    // tem em casa?

  IngredientItem({
    this.masterId,
    required this.name,
    required this.quantity,
    required this.unit,
    this.price,
    this.haveAtHome = false,
  });
}
