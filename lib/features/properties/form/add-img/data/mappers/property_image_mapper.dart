import 'package:app_properties/features/properties/form/add-img/domain/entities/photo_connection.dart';

class PropertyImageMapper {
  static PhotoConnection fromJson(Map<String, dynamic> json) {
    return PhotoConnection(
      connectionId: json['connectionId'],
      photoUrl: json['photoUrl'],
      description: json['description'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  static List<PhotoConnection> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => fromJson(json)).toList();
  }
}
