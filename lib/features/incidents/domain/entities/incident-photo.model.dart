import 'package:equatable/equatable.dart';

class IncidentPhotoModel extends Equatable {
  final int id;
  final String incidentId;
  final String filePath;
  final String photoType; // 'REPORTE' | 'RESOLUCION'
  final DateTime createdAt;

  const IncidentPhotoModel({
    required this.id,
    required this.incidentId,
    required this.filePath,
    required this.photoType,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, incidentId, filePath, photoType, createdAt];

  factory IncidentPhotoModel.fromJson(Map<String, dynamic> json) {
    return IncidentPhotoModel(
      id: json['id'] as int? ?? 0,
      incidentId: json['incidentId'] as String? ?? '',
      filePath: json['filePath'] as String? ?? '',
      photoType: json['photoType'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'incidentId': incidentId,
      'filePath': filePath,
      'photoType': photoType,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
