// lib/models/budget_item_model.dart
import 'package:hive/hive.dart';

part 'budget_item_model.g.dart'; // Akan digenerate

@HiveType(typeId: 4) // Pastikan typeId unik (0:User, 1:Plant, 2:Bookmark, 3:Comment)
class BudgetItem {
  @HiveField(0)
  final String id; // ID unik untuk setiap item budget

  @HiveField(1)
  final int plantId;

  @HiveField(2)
  final String plantName;

  @HiveField(3)
  final String originalPriceIDR; // Misal "Rp 25.000 - Rp 75.000" atau satu nilai

  @HiveField(4)
  final String targetCurrency; // Misal "USD"

  @HiveField(5)
  final String convertedPrice; // Misal "$ 1.56 - $ 4.69" atau satu nilai

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7) // FIELD BARU UNTUK USER ID
  final String userId;

  BudgetItem({
    required this.id,
    required this.plantId,
    required this.plantName,
    required this.originalPriceIDR,
    required this.targetCurrency,
    required this.convertedPrice,
    required this.createdAt,
    required this.userId, 
  });
}