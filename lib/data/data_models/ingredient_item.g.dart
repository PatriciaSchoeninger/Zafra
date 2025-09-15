// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IngredientItemAdapter extends TypeAdapter<IngredientItem> {
  @override
  final int typeId = 2;

  @override
  IngredientItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IngredientItem(
      masterId: fields[0] as String?,
      name: fields[1] as String,
      quantity: fields[2] as double,
      unit: fields[3] as String,
      price: fields[4] as double?,
      haveAtHome: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, IngredientItem obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.masterId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.unit)
      ..writeByte(4)
      ..write(obj.price)
      ..writeByte(5)
      ..write(obj.haveAtHome);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IngredientItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
