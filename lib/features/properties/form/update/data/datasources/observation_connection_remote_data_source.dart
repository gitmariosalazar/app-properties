import 'dart:convert';
import 'package:app_properties/config/environments/environment.dart';
import 'package:app_properties/features/properties/form/update/data/models/dto/request/create_observation_request.dart';
import 'package:http/http.dart' as http;
import 'package:app_properties/features/auth/data/datasources/auth_local_datasource.dart';

class ObservationConnectionRemoteDataSource {
  final http.Client client;
  final AuthLocalDataSource authLocalDataSource;
  static final String baseUrl = Environment.apiUrl;

  ObservationConnectionRemoteDataSource({
    required this.client,
    required this.authLocalDataSource,
  });

  Future<void> addObservationConnection({
    required CreateObservationRequest request,
  }) async {
    final token = await authLocalDataSource.getToken();
    final url = Uri.parse(
      '$baseUrl/observation-connection/create-observation-connection',
    );
    final response = await client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(request),
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
      throw Exception(
        'Failed to create observation connection: ${response.body}',
      );
    }
  }
}
