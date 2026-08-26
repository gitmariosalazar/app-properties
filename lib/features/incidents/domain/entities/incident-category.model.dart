import 'package:equatable/equatable.dart';

class IncidentCategoryModel extends Equatable {
  final int id;
  final String code;
  final String name;
  final String? description;
  final bool isActive;
  final List<IncidentTypeModel> incidentTypes;

  const IncidentCategoryModel({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.isActive,
    required this.incidentTypes,
  });

  @override
  List<Object?> get props => [
    id,
    code,
    name,
    description,
    isActive,
    incidentTypes,
  ];

  factory IncidentCategoryModel.fromJson(Map<String, dynamic> json) {
    return IncidentCategoryModel(
      id: (json['categoryId'] ?? json['id']) as int? ?? 0,
      code: (json['categoryCode'] ?? json['code']) as String? ?? '',
      name: (json['categoryName'] ?? json['name']) as String? ?? '',
      description:
          (json['categoryDescription'] ?? json['description']) as String?,
      isActive: json['isActive'] as bool? ?? true,
      incidentTypes:
          (json['incidentTypes'] as List<dynamic>?)
              ?.map(
                (e) => IncidentTypeModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': id,
      'categoryCode': code,
      'categoryName': name,
      'categoryDescription': description,
      'isActive': isActive,
      'incidentTypes': incidentTypes.map((e) => e.toJson()).toList(),
    };
  }
}

class IncidentTypeModel extends Equatable {
  final int typeCode;
  final String typeName;
  final String typeDescription;
  final String suggestedPriority;

  const IncidentTypeModel({
    required this.typeCode,
    required this.typeName,
    required this.typeDescription,
    required this.suggestedPriority,
  });

  @override
  List<Object?> get props => [
    typeCode,
    typeName,
    typeDescription,
    suggestedPriority,
  ];

  factory IncidentTypeModel.fromJson(Map<String, dynamic> json) {
    return IncidentTypeModel(
      typeCode: json['typeCode'] as int? ?? 0,
      typeName: json['typeName'] as String? ?? '',
      typeDescription: json['typeDescription'] as String? ?? '',
      suggestedPriority: json['suggestedPriority'] as String? ?? 'MEDIA',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'typeCode': typeCode,
      'typeName': typeName,
      'typeDescription': typeDescription,
      'suggestedPriority': suggestedPriority,
    };
  }
}
