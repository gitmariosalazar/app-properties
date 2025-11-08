import 'package:app_properties/config/environments/environment.dart';
import 'package:app_properties/features/properties/list/data/model/schemas/dto/response/connection_with_properties_response.dart';
import 'package:http/http.dart' as http;
import 'package:app_properties/shared/api/response/api_response.dart';
import 'dart:convert';

abstract class RemoteConnectionWithPropertiesDataSource {
  Future<ConnectionWithPropertiesResponse>
  fetchConnectionWithPropertiesByCadastralKey(String cadastralKey);
}

class RemoteConnectionWithPropertiesDataSourceImpl
    implements RemoteConnectionWithPropertiesDataSource {
  final http.Client client;
  final String baseUrl = Environment.apiUrl;

  RemoteConnectionWithPropertiesDataSourceImpl(this.client);

  @override
  Future<ConnectionWithPropertiesResponse>
  fetchConnectionWithPropertiesByCadastralKey(String cadastralKey) async {
    final response = await client.get(
      Uri.parse(
        '$baseUrl/connections/find-connection-with-property-by-cadastral-key/$cadastralKey',
      ),
      headers: {'Content-Type': 'application/json'},
    );

    // 1. Verifica HTTP status
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Error HTTP ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    final apiResponse = ApiResponse<ConnectionWithPropertiesResponse>.fromJson(
      json,
      (data) => ConnectionWithPropertiesResponse.fromJson(
        data as Map<String, dynamic>,
      ),
    );

    // 2. Verifica el status_code del JSON (201 es éxito)
    if (apiResponse.statusCode < 200 || apiResponse.statusCode >= 300) {
      throw Exception(apiResponse.message.join(', '));
    }

    if (apiResponse.data == null) {
      throw Exception(
        'No se encontró conexión para la clave catastral: $cadastralKey',
      );
    }

    return apiResponse.data!;
  }
}
