import 'package:equatable/equatable.dart';

class IncidentCategoryTypeModel extends Equatable {
  final int categoryId;
  final String categoryCode;
  final String categoryName;
  final String categoryDescription;
  final List<IncidentTypeModel> incidentTypes;

  const IncidentCategoryTypeModel({
    required this.categoryId,
    required this.categoryCode,
    required this.categoryName,
    required this.categoryDescription,
    required this.incidentTypes,
  });

  @override
  List<Object?> get props => [
    categoryId,
    categoryCode,
    categoryName,
    categoryDescription,
    incidentTypes,
  ];

  factory IncidentCategoryTypeModel.fromJson(Map<String, dynamic> json) {
    return IncidentCategoryTypeModel(
      categoryId: json['categoryId'] as int? ?? 0,
      categoryCode: json['categoryCode'] as String? ?? '',
      categoryName: json['categoryName'] as String? ?? '',
      categoryDescription: json['categoryDescription'] as String? ?? '',
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
      'categoryId': categoryId,
      'categoryCode': categoryCode,
      'categoryName': categoryName,
      'categoryDescription': categoryDescription,
      'incidentTypes': incidentTypes.map((e) => e.toJson()).toList(),
    };
  }
}

class IncidentTypeModel extends Equatable {
  final String typeCode;
  final String typeName;
  final String typeDescription;
  final bool suggestedPriority;

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
      typeCode: json['typeCode'] as String? ?? '',
      typeName: json['typeName'] as String? ?? '',
      typeDescription: json['typeDescription'] as String? ?? '',
      suggestedPriority: json['suggestedPriority'] as bool? ?? false,
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
