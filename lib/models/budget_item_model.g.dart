// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BudgetItemAdapter extends TypeAdapter<BudgetItem> {
  @override
  final int typeId = 4;

  @override
  BudgetItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BudgetItem(
      id: fields[0] as String,
      plantId: fields[1] as int,
      plantName: fields[2] as String,
      originalPriceIDR: fields[3] as String,
      targetCurrency: fields[4] as String,
      convertedPrice: fields[5] as String,
      createdAt: fields[6] as DateTime,
      userId: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, BudgetItem obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.plantId)
      ..writeByte(2)
      ..write(obj.plantName)
      ..writeByte(3)
      ..write(obj.originalPriceIDR)
      ..writeByte(4)
      ..write(obj.targetCurrency)
      ..writeByte(5)
      ..write(obj.convertedPrice)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
