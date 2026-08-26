import 'package:app_properties/features/auth/domain/entities/RoleOrPermission.dart';

class RolePermissionModel extends RoleOrPermission {
  const RolePermissionModel({
    required super.id,
    required super.name,
    required super.description,
  });

  factory RolePermissionModel.fromJson(Map<String, dynamic> json) {
    return RolePermissionModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'description': description};
  }
}
