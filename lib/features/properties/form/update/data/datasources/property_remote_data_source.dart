// lib/features/properties/put/data/datasources/property_remote_data_source.dart
import 'dart:convert';
import 'package:app_properties/config/environments/environment.dart';
import 'package:http/http.dart' as http;
import 'package:app_properties/features/properties/form/update/data/models/dto/request/update_property_request.dart';

class PropertyRemoteDataSource {
  final http.Client client;
  static final String baseUrl = Environment.apiUrl;

  PropertyRemoteDataSource({required this.client});

  Future<void> updateProperty({
    required String cadastralKey,
    required UpdatePropertyRequest request,
  }) async {
    final url = Uri.parse('$baseUrl/properties/update-property/$cadastralKey');
    final response = await client.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to update property: ${response.body}');
    }
  }
}
