// lib/services/hive_service.dart
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:projekakhir_praktpm/models/user_model.dart';
import 'package:projekakhir_praktpm/models/plant_model.dart';
import 'package:projekakhir_praktpm/models/comment_model.dart';
import 'package:projekakhir_praktpm/models/budget_item_model.dart'; // IMPORT BARU

class HiveService {
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  late Box<User> _userBox;
  late Box<String> _sessionBox;
  late Box<User> _allUsersBox;
  late Box<Bookmark> _bookmarkBox;
  late Box<BudgetItem> _budgetBox; // BOX BARU

  bool _isInitialized = false;

  Future<void> init() async {
    if (!_isInitialized) {
      await Hive.initFlutter();

      if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(UserAdapter());
      if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(PlantAdapter());
      if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(BookmarkAdapter());
      if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(CommentAdapter());
      if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(BudgetItemAdapter()); // DAFTARKAN ADAPTER BARU

      _userBox = await Hive.openBox<User>('current_user_box');
      _sessionBox = await Hive.openBox<String>('session_box');
      _allUsersBox = await Hive.openBox<User>('all_registered_users_box');
      _bookmarkBox = await Hive.openBox<Bookmark>('bookmarks_box');
      _budgetBox = await Hive.openBox<BudgetItem>('budget_items_box'); // BUKA BOX BARU

      _isInitialized = true;
    }
  }

  // ... (metode User, Session, Comment, Bookmark yang sudah ada) ...
  // Pastikan semua metode yang ada sebelumnya tetap di sini

  Future<void> saveUser(User user) async {
    await init();
    await _userBox.put('loggedInUser', user);
  }

  Future<User?> getCurrentUser() async {
    await init();
    return _userBox.get('loggedInUser');
  }

  Future<void> logout() async {
    await init();
    await _userBox.clear();
    await _sessionBox.clear();
    // Pertimbangkan apakah _budgetBox juga perlu di-clear saat logout jika budget bersifat per user
    // Untuk saat ini, kita biarkan global
  }

  Future<void> saveRegisteredUser(User user) async {
    await init();
    await _allUsersBox.put(user.id, user); 
  }

  Future<List<User>> getAllRegisteredUsers() async {
    await init();
    return _allUsersBox.values.toList();
  }

  Future<void> saveSession(String token, DateTime expiryTime) async {
    await init();
    await _sessionBox.put('token', token);
    await _sessionBox.put('expiry_time', expiryTime.toIso8601String());
  }

  Future<String?> getSessionToken() async {
    await init();
    return _sessionBox.get('token');
  }

  Future<DateTime?> getSessionExpiryTime() async {
    await init();
    final expiryTimeString = _sessionBox.get('expiry_time');
    return expiryTimeString != null ? DateTime.parse(expiryTimeString) : null;
  }

  Future<void> saveComments(String plantId, List<Comment> comments) async {
    await init();
    final commentsBoxName = 'comments_plant_$plantId';
    if(!Hive.isBoxOpen(commentsBoxName)){
         await Hive.openBox<String>(commentsBoxName);
    }
    final commentsBox = Hive.box<String>(commentsBoxName);
    final commentsJson = json.encode(comments.map((c) => c.toJson()).toList());
    await commentsBox.put('list', commentsJson);
  }

  Future<List<Comment>> getComments(String plantId) async {
    await init();
    final commentsBoxName = 'comments_plant_$plantId';
     if(!Hive.isBoxOpen(commentsBoxName)){
         await Hive.openBox<String>(commentsBoxName);
    }
    final commentsBox = Hive.box<String>(commentsBoxName);
    final commentsJson = commentsBox.get('list');
    if (commentsJson != null) {
      final List<dynamic> decoded = json.decode(commentsJson);
      return decoded.map((jsonMap) => Comment.fromJson(jsonMap as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<void> addComment(String plantId, Comment comment) async {
    final comments = await getComments(plantId);
    comments.add(comment);
    await saveComments(plantId, comments);
  }

  Future<void> updateComment(String plantId, Comment updatedComment) async {
    final comments = await getComments(plantId);
    final index = comments.indexWhere((c) => c.id == updatedComment.id);
    if (index != -1) {
      comments[index] = updatedComment;
      await saveComments(plantId, comments);
    }
  }

  Future<void> deleteComment(String plantId, String commentId) async {
    final comments = await getComments(plantId);
    comments.removeWhere((c) => c.id == commentId);
    await saveComments(plantId, comments);
  }

  Future<void> addBookmark(Bookmark bookmark) async {
    await init();
    await _bookmarkBox.put(bookmark.plant.id.toString(), bookmark); 
  }

  Future<void> removeBookmark(String plantId) async {
    await init();
    await _bookmarkBox.delete(plantId);
  }

  List<Bookmark> getAllBookmarks() {
    if (!_isInitialized || !_bookmarkBox.isOpen) {
     // Bisa throw error atau return list kosong, atau panggil init() lagi
     // Untuk robust, pastikan init() dipanggil sebelum presenter mengakses ini
     return [];
    }
    return _bookmarkBox.values.toList();
  }

  bool isBookmarked(String plantId) {
     if (!_isInitialized || !_bookmarkBox.isOpen) return false;
    return _bookmarkBox.containsKey(plantId);
  }

  // METODE BARU UNTUK BUDGET ITEM
  Future<void> addBudgetItem(BudgetItem item) async {
    await init(); // Pastikan box sudah siap
    await _budgetBox.put(item.id, item);
  }

  List<BudgetItem> getBudgetItemsForUser(String userId) {
    if (!_isInitialized || !_budgetBox.isOpen) return [];
    // Ambil semua item, lalu filter berdasarkan userId
    return _budgetBox.values.where((item) => item.userId == userId).toList();
  }

  Future<void> removeBudgetItem(String itemId) async {
    await init(); // Pastikan box sudah siap
    await _budgetBox.delete(itemId);
  }
}