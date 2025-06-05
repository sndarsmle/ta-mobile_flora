import 'package:flutter/material.dart';
import 'package:projekakhir_praktpm/models/comment_model.dart';
import 'package:projekakhir_praktpm/services/hive_service.dart';

class CommentPresenter extends ChangeNotifier {
  CommentPresenter();

  Future<List<Comment>> getCommentsByPlantId(String plantId) async {
    try {
      final comments = await HiveService().getComments(plantId);
      return comments;
    } catch (e) {
      throw Exception('Failed to load comments: $e');
    }
  }

  Future<void> addComment(Comment comment) async {
    try {
      await HiveService().addComment(comment.plantId, comment);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  Future<void> updateComment(Comment updatedComment) async {
    try {
      await HiveService().updateComment(updatedComment.plantId, updatedComment);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to update comment: $e');
    }
  }

  Future<void> deleteComment(String plantId, String commentId) async {
    try {
      await HiveService().deleteComment(plantId, commentId);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to delete comment: $e');
    }
  }
}