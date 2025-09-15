// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecipeAdapter extends TypeAdapter<Recipe> {
  @override
  final int typeId = 3;

  @override
  Recipe read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Recipe(
      id: fields[0] as String,
      title: fields[1] as String,
      photoPaths: (fields[2] as List).cast<String>(),
      servings: fields[3] as int,
      prepTimeMin: fields[4] as int,
      cookTimeMin: fields[5] as int,
      category: fields[6] as String?,
      tags: (fields[7] as List).cast<String>(),
      ingredients: (fields[8] as List).cast<InvalidType>(),
      steps: (fields[9] as List).cast<String>(),
      favorite: fields[10] as bool,
      source: fields[11] as String?,
      notes: fields[12] as String?,
      createdAt: fields[13] as DateTime?,
      updatedAt: fields[14] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Recipe obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.photoPaths)
      ..writeByte(3)
      ..write(obj.servings)
      ..writeByte(4)
      ..write(obj.prepTimeMin)
      ..writeByte(5)
      ..write(obj.cookTimeMin)
      ..writeByte(6)
      ..write(obj.category)
      ..writeByte(7)
      ..write(obj.tags)
      ..writeByte(8)
      ..write(obj.ingredients)
      ..writeByte(9)
      ..write(obj.steps)
      ..writeByte(10)
      ..write(obj.favorite)
      ..writeByte(11)
      ..write(obj.source)
      ..writeByte(12)
      ..write(obj.notes)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
