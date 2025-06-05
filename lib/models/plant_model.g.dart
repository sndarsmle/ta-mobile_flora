// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plant_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlantAdapter extends TypeAdapter<Plant> {
  @override
  final int typeId = 1;

  @override
  Plant read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Plant(
      id: fields[0] as int,
      commonName: fields[1] as String,
      scientificName: (fields[2] as List).cast<String>(),
      otherName: fields[3] as String?,
      type: fields[4] as String?,
      cycle: fields[5] as String,
      watering: fields[6] as String,
      wateringGeneralBenchmark: (fields[7] as Map?)?.cast<String, dynamic>(),
      sunlight: (fields[8] as List).cast<dynamic>(),
      description: fields[9] as String,
      defaultImage: (fields[10] as Map?)?.cast<String, dynamic>(),
      family: fields[11] as String?,
      genus: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Plant obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.commonName)
      ..writeByte(2)
      ..write(obj.scientificName)
      ..writeByte(3)
      ..write(obj.otherName)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.cycle)
      ..writeByte(6)
      ..write(obj.watering)
      ..writeByte(7)
      ..write(obj.wateringGeneralBenchmark)
      ..writeByte(8)
      ..write(obj.sunlight)
      ..writeByte(9)
      ..write(obj.description)
      ..writeByte(10)
      ..write(obj.defaultImage)
      ..writeByte(11)
      ..write(obj.family)
      ..writeByte(12)
      ..write(obj.genus);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlantAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BookmarkAdapter extends TypeAdapter<Bookmark> {
  @override
  final int typeId = 2;

  @override
  Bookmark read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Bookmark(
      userId: fields[0] as String,
      plant: fields[1] as Plant,
    );
  }

  @override
  void write(BinaryWriter writer, Bookmark obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.plant);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookmarkAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
