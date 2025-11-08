// lib/features/properties/put/data/datasources/connection_remote_data_source.dart
import 'dart:convert';
import 'package:app_properties/config/environments/environment.dart';
import 'package:http/http.dart' as http;
import 'package:app_properties/features/properties/form/update/data/models/dto/request/update_connection_request.dart';

class ConnectionRemoteDataSource {
  final http.Client client;
  static final String baseUrl = Environment.apiUrl;

  ConnectionRemoteDataSource({required this.client});

  Future<void> updateConnection({
    required String connectionId,
    required UpdateConnectionRequest request,
  }) async {
    final url = Uri.parse(
      '$baseUrl/connections/update-connection/$connectionId',
    );
    final response = await client.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to update connection: ${response.body}');
    }
  }
}
