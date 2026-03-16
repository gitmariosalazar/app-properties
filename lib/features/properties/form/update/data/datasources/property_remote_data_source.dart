// lib/features/properties/put/data/datasources/property_remote_data_source.dart
import 'dart:convert';
import 'package:app_properties/config/environments/environment.dart';
import 'package:http/http.dart' as http;
import 'package:app_properties/features/properties/form/update/data/models/dto/request/update_property_request.dart';
import 'package:app_properties/features/auth/data/datasources/auth_local_datasource.dart';

class PropertyRemoteDataSource {
  final http.Client client;
  final AuthLocalDataSource authLocalDataSource;
  static final String baseUrl = Environment.apiUrl;

  PropertyRemoteDataSource({
    required this.client,
    required this.authLocalDataSource,
  });

  Future<void> updateProperty({
    required String cadastralKey,
    required UpdatePropertyRequest request,
  }) async {
    final token = await authLocalDataSource.getToken();
    final url = Uri.parse('$baseUrl/properties/update-property/$cadastralKey');
    final response = await client.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(request.toJson()),
    );

    if (token == null) {
      throw Exception('Token no encontrado');
    }

    if (token.isEmpty) {
      throw Exception('Token no encontrado');
    }

    if (response.statusCode == 401) {
      throw Exception('Token no autorizado');
    }

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to update property: ${response.body}');
    }
  }
}
