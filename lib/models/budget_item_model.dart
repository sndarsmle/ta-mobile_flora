import 'package:hive/hive.dart';

part 'budget_item_model.g.dart';

@HiveType(typeId: 4)
class BudgetItem {
  @HiveField(0)
  final String id; 

  @HiveField(1)
  final int plantId;

  @HiveField(2)
  final String plantName;

  @HiveField(3)
  final String originalPriceIDR; 

  @HiveField(4)
  final String targetCurrency; 

  @HiveField(5)
  final String convertedPrice; 

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7) 
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