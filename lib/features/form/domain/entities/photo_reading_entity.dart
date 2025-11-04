// lib/features/form/domain/entities/photo_reading_entity.dart
class PhotoReadingEntity {
  final int photoReadingId;
  final int readingId;
  final String photoUrl;
  final String cadastralKey;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  PhotoReadingEntity({
    required this.photoReadingId,
    required this.readingId,
    required this.photoUrl,
    required this.cadastralKey,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });
}
