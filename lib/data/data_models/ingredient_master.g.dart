// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient_master.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IngredientMasterAdapter extends TypeAdapter<IngredientMaster> {
  @override
  final int typeId = 1;

  @override
  IngredientMaster read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IngredientMaster(
      id: fields[0] as String,
      name: fields[1] as String,
      synonyms: (fields[2] as List).cast<String>(),
      defaultUnit: fields[3] as String,
      densityGPerMl: fields[4] as double?,
      defaultPrice: fields[5] as double?,
      tags: (fields[6] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, IngredientMaster obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.synonyms)
      ..writeByte(3)
      ..write(obj.defaultUnit)
      ..writeByte(4)
      ..write(obj.densityGPerMl)
      ..writeByte(5)
      ..write(obj.defaultPrice)
      ..writeByte(6)
      ..write(obj.tags);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IngredientMasterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
