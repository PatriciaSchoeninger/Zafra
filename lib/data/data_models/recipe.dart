import 'package:hive/hive.dart';
import '../../core/hive_ids.dart';
import 'ingredient_item.dart';

part 'recipe.g.dart';

@HiveType(typeId: HiveIds.recipe)
class Recipe extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  List<String> photoPaths;

  @HiveField(3)
  int servings;

  @HiveField(4)
  int prepTimeMin;

  @HiveField(5)
  int cookTimeMin;

  @HiveField(6)
  String? category;

  @HiveField(7)
  List<String> tags;

  @HiveField(8)
  List<IngredientItem> ingredients;

  @HiveField(9)
  List<String> steps;

  @HiveField(10)
  bool favorite;

  @HiveField(11)
  String? source;

  @HiveField(12)
  String? notes;

  @HiveField(13)
  DateTime createdAt;

  @HiveField(14)
  DateTime updatedAt;

  @HiveField(15)
  int coverIndex; // índice da foto usada como capa

  Recipe({
    required this.id,
    required this.title,
    this.photoPaths = const [],
    this.servings = 1,
    this.prepTimeMin = 0,
    this.cookTimeMin = 0,
    this.category,
    this.tags = const [],
    this.ingredients = const [],
    this.steps = const [],
    this.favorite = false,
    this.source,
    this.notes,
    this.coverIndex = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  int get totalTime => prepTimeMin + cookTimeMin;

  double get totalCost =>
      ingredients.fold(0.0, (s, it) => s + (it.price ?? 0.0));

  double get costPerServing =>
      servings > 0 ? totalCost / servings : totalCost;
}
