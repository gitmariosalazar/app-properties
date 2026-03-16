import 'package:app_properties/features/auth/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.username,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.roles,
    required super.permissions,
    required super.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['userId'] as String? ?? json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      roles:
          (json['roles'] as List<dynamic>?)
              ?.map((e) => e is String ? e : (e['name'] as String))
              .toList() ??
          [],
      permissions:
          (json['permissions'] as List<dynamic>?)
              ?.map((e) => e is String ? e : (e['name'] as String))
              .toList() ??
          [],
      isActive: json['isActive'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'roles': roles.map((roleName) => {'name': roleName}).toList(),
      'permissions': permissions.map((permName) => {'name': permName}).toList(),
      'isActive': isActive,
    };
  }
}
