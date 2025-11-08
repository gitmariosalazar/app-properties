import 'dart:convert';
import 'package:app_properties/config/environments/environment.dart';
import 'package:app_properties/features/properties/form/update/data/models/dto/request/create_observation_request.dart';
import 'package:http/http.dart' as http;

class ObservationConnectionRemoteDataSource {
  final http.Client client;
  static final String baseUrl = Environment.apiUrl;

  ObservationConnectionRemoteDataSource({required this.client});

  Future<void> addObservationConnection({
    required CreateObservationRequest request,
  }) async {
    final url = Uri.parse(
      '$baseUrl/observation-connection/create-observation-connection',
    );
    final response = await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Failed to create observation connection: ${response.body}',
      );
    }
  }
}
