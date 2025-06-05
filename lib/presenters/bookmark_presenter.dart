import 'package:flutter/material.dart';
import 'package:projekakhir_praktpm/models/plant_model.dart';
import 'package:projekakhir_praktpm/services/hive_service.dart';

class BookmarkPresenter extends ChangeNotifier {
  static const String _bookmarksKey = 'plant_bookmarks';
  List<Bookmark> _bookmarks = [];

  List<Plant> getBookmarksForUser(String userId) {
    return _bookmarks
        .where((bookmark) => bookmark.userId == userId)
        .map((bookmark) => bookmark.plant)
        .toList();
  }

  BookmarkPresenter() {
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    try {
      final allBookmarks = HiveService().getAllBookmarks();
      _bookmarks = allBookmarks;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading bookmarks: $e');
      _bookmarks = [];
    }
  }

  Future<void> addBookmark(String userId, Plant plant) async {
    if (!_bookmarks.any((b) => b.plant.id == plant.id && b.userId == userId)) {
      final newBookmark = Bookmark(userId: userId, plant: plant);
      await HiveService().addBookmark(newBookmark);
      _bookmarks.add(newBookmark);
      notifyListeners();
    }
  }

  Future<void> removeBookmark(String userId, int plantId) async {
    await HiveService().removeBookmark(plantId.toString());
    _bookmarks.removeWhere((b) => b.plant.id == plantId && b.userId == userId);
    notifyListeners();
  }

  bool isBookmarked(String userId, int plantId) {
    return _bookmarks.any((b) => b.plant.id == plantId && b.userId == userId);
  }
}