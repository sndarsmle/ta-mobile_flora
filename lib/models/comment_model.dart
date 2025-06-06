import 'package:hive/hive.dart';

part 'comment_model.g.dart';

@HiveType(typeId: 3) 
class Comment {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String plantId;
  @HiveField(2)
  final String userId;
  @HiveField(3)
  final String username;
  @HiveField(4)
  final String content;
  @HiveField(5)
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.plantId,
    required this.userId,
    required this.username,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plantId': plantId,
      'userId': userId,
      'username': username,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      plantId: json['plantId'],
      userId: json['userId'],
      username: json['username'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => toJson();
  
  factory Comment.fromMap(Map<String, dynamic> map) => Comment.fromJson(map);
}