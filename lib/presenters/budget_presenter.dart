import 'package:flutter/foundation.dart';
import 'package:projekakhir_praktpm/models/budget_item_model.dart';
import 'package:projekakhir_praktpm/services/hive_service.dart';
import 'package:uuid/uuid.dart';

class BudgetPresenter extends ChangeNotifier {
  final HiveService _hiveService = HiveService();
  List<BudgetItem> _budgetItems = [];

  List<BudgetItem> get budgetItems => _budgetItems;

  Future<void> loadBudgetItems(String userId) async {
    if (userId.isEmpty) { // Jangan load jika userId kosong
      _budgetItems = [];
      notifyListeners();
      return;
    }
    _budgetItems = _hiveService.getBudgetItemsForUser(userId);
    _budgetItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
  }

  Future<void> addBudgetItem({
    required String userId,
    required int plantId,
    required String plantName,
    required String originalPriceIDR,
    required String targetCurrency,
    required String convertedPrice,
  }) async {
    final newItem = BudgetItem(
      id: const Uuid().v4(), 
      userId: userId,
      plantId: plantId,
      plantName: plantName,
      originalPriceIDR: originalPriceIDR,
      targetCurrency: targetCurrency,
      convertedPrice: convertedPrice,
      createdAt: DateTime.now(),
    );
    await _hiveService.addBudgetItem(newItem);
    await loadBudgetItems(userId); 
  }

  Future<void> removeBudgetItem(String itemId, String userId) async {
    await _hiveService.removeBudgetItem(itemId);
    await loadBudgetItems(userId); 
  }
}