import 'package:caco_flutter_blog/core/common/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.id, 
    required super.email, 
    required super.username
    });
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Get username from top level or from user_metadata
    String username = json['username'] as String? ?? '';
    if (username.isEmpty && json['user_metadata'] != null) {
      final metadata = json['user_metadata'] as Map<String, dynamic>;
      username = metadata['username'] as String? ?? '';
    }
    
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      username: username,
    );
  }
  UserModel copyWith({
    String? id,
    String? email,
    String? username,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
    );
  }
}