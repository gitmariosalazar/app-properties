/*

export interface RolOrPermission {
  id: number;
  name: string;
  description: string;
}

export const isAdmin = (roles: RolOrPermission[]) => {
  return roles.some(
    (r: RolOrPermission) =>
      r.name.toUpperCase() === 'SUPER ADMINISTRADOR' ||
      r.name.toUpperCase() === 'ADMINISTRADOR',
  );
};

export const isCustomer = (roles: RolOrPermission[]) => {
  return roles.some(
    (r: RolOrPermission) => r.name.toUpperCase() === 'ABONADO PORTAL WEB',
  );
};
 */

import 'package:equatable/equatable.dart';

class RoleOrPermission extends Equatable {
  final int id;
  final String name;
  final String description;

  const RoleOrPermission({
    required this.id,
    required this.name,
    required this.description,
  });

  factory RoleOrPermission.fromJson(Map<String, dynamic> json) {
    return RoleOrPermission(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'description': description};
  }

  @override
  List<Object?> get props => [id, name, description];

  bool isAdmin() {
    return name.toUpperCase() == 'SUPER ADMINISTRADOR' ||
        name.toUpperCase() == 'ADMINISTRADOR';
  }

  bool isCustomer() {
    return name.toUpperCase() == 'ABONADO PORTAL WEB';
  }
}
