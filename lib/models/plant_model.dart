// lib/models/plant_model.dart
import 'package:hive/hive.dart';

part 'plant_model.g.dart';

@HiveType(typeId: 1) // typeId harus unik
class Plant {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String commonName;
  @HiveField(2)
  final List<String> scientificName;
  @HiveField(3)
  final String? otherName;
  @HiveField(4)
  final String? type;
  @HiveField(5)
  final String cycle;
  @HiveField(6)
  final String watering;
  @HiveField(7)
  final Map<String, dynamic>? wateringGeneralBenchmark;
  @HiveField(8)
  final List<dynamic> sunlight;
  @HiveField(9)
  final String description;
  @HiveField(10)
  final Map<String, dynamic>? defaultImage;

  // TAMBAHAN FIELD BARU
  @HiveField(11) // Pastikan nomor ini unik dan berurutan
  final String? family;
  @HiveField(12) // Pastikan nomor ini unik dan berurutan
  final String? genus;

  Plant({
    required this.id,
    required this.commonName,
    required this.scientificName,
    this.otherName,
    this.type,
    required this.cycle,
    required this.watering,
    this.wateringGeneralBenchmark,
    required this.sunlight,
    required this.description,
    this.defaultImage,
    this.family, // Tambahkan di constructor
    this.genus,  // Tambahkan di constructor
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      id: json['id'] as int,
      commonName: json['common_name'] ?? 'Unknown',
      scientificName: (json['scientific_name'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      otherName: (json['other_name'] as List<dynamic>?)?.isNotEmpty == true ? (json['other_name'] as List<dynamic>)[0] as String? : null,
      type: json['type'] as String?,
      cycle: json['cycle'] as String? ?? 'Unknown',
      watering: json['watering'] as String? ?? 'Unknown',
      wateringGeneralBenchmark: json['watering_general_benchmark'] is Map ? Map<String, dynamic>.from(json['watering_general_benchmark']) : null,
      sunlight: json['sunlight'] is List ? List<dynamic>.from(json['sunlight']) : [],
      description: json['description'] as String? ?? 'No description available.',
      defaultImage: json['default_image'] is Map ? Map<String, dynamic>.from(json['default_image']) : null,
      family: json['family'] as String?,   // Tambahkan parsing untuk family
      genus: json['genus'] as String?,     // Tambahkan parsing untuk genus
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'common_name': commonName,
      'scientific_name': scientificName,
      'other_name': otherName,
      'type': type,
      'cycle': cycle,
      'watering': watering,
      'watering_general_benchmark': wateringGeneralBenchmark,
      'sunlight': sunlight,
      'description': description,
      'default_image': defaultImage,
      'family': family, // Tambahkan ke toJson
      'genus': genus,   // Tambahkan ke toJson
    };
  }
}

@HiveType(typeId: 2) // typeId harus unik
class Bookmark {
  @HiveField(0)
  final String userId;
  @HiveField(1)
  final Plant plant;

  Bookmark({
    required this.userId,
    required this.plant,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'plant': plant.toJson(),
    };
  }

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      userId: json['userId'],
      plant: Plant.fromJson(json['plant']),
    );
  }
}