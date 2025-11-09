// lib/features/properties/form/add-img/domain/entities/photo_connection.dart
class PhotoConnection {
  final String connectionId;
  final String photoUrl;
  final String? description;
  final String? createdAt;
  final String? updatedAt;

  PhotoConnection({
    required this.connectionId,
    required this.photoUrl,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory PhotoConnection.fromJson(Map<String, dynamic> json) {
    return PhotoConnection(
      connectionId: json['connectionId'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      description: json['description'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  static List<PhotoConnection> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => PhotoConnection.fromJson(json)).toList();
  }
}
