// lib/features/form/data/models/photo_reading_model.dart
import 'package:app_properties/features/form/domain/entities/photo_reading_entity.dart';

class PhotoReadingModel extends PhotoReadingEntity {
  PhotoReadingModel({
    required super.photoReadingId,
    required super.readingId,
    required super.photoUrl,
    required super.cadastralKey,
    super.description,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PhotoReadingModel.fromJson(Map<String, dynamic> json) {
    return PhotoReadingModel(
      photoReadingId:
          json['photoReadingId'] as int? ?? (json['id'] as int? ?? 0),
      readingId: json['readingId'] as int? ?? 0,
      photoUrl: json['photoUrl'] as String? ?? '',
      cadastralKey: json['cadastralKey'] as String? ?? '',
      description: json['description'] as String?,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  static DateTime _parseDateTime(dynamic date) {
    if (date is String) {
      try {
        return DateTime.parse(date).toUtc();
      } catch (e) {
        return DateTime.now().toUtc();
      }
    }
    return DateTime.now().toUtc();
  }

  PhotoReadingEntity toEntity() {
    return PhotoReadingEntity(
      photoReadingId: photoReadingId,
      readingId: readingId,
      photoUrl: photoUrl,
      cadastralKey: cadastralKey,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'photoReadingId': photoReadingId,
      'readingId': readingId,
      'photoUrl': photoUrl,
      'cadastralKey': cadastralKey,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
