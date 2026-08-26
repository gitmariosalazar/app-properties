// lib/features/properties/put/data/datasources/connection_remote_data_source.dart
import 'dart:convert';
import 'package:app_properties/config/environments/environment.dart';
import 'package:app_properties/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:http/http.dart' as http;
import 'package:app_properties/features/properties/form/update/data/models/dto/request/update_connection_request.dart';
import 'package:app_properties/features/properties/form/update/data/models/dto/request/change_meter_request.dart';
import 'package:http_parser/http_parser.dart';

class ConnectionRemoteDataSource {
  final http.Client client;
  final AuthLocalDataSource authLocalDataSource;
  static final String baseUrl = Environment.apiUrl;

  ConnectionRemoteDataSource({
    required this.client,
    required this.authLocalDataSource,
  });

  Future<void> updateConnection({
    required String connectionId,
    required UpdateConnectionRequest request,
  }) async {
    final token = await authLocalDataSource.getToken();
    final url = Uri.parse(
      '$baseUrl/connections/update-connection/$connectionId',
    );
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
      throw Exception('Failed to update connection: ${response.body}');
    }
  }

  Future<void> changeMeter({
    required ChangeMeterRequest request,
  }) async {
    final token = await authLocalDataSource.getToken();
    final url = Uri.parse(
      '$baseUrl/connections/change-meter/${request.connectionId}',
    );

    var requestMultipart = http.MultipartRequest('POST', url);

    if (token != null) {
      requestMultipart.headers['Authorization'] = 'Bearer $token';
    } else {
      requestMultipart.headers['x-api-key'] = Environment.publicAppApiKey;
    }

    requestMultipart.fields['changeDetail'] = jsonEncode(request.changeDetail.toJson());

    if (request.imageDescriptions.isNotEmpty) {
      requestMultipart.fields['imageDescriptions'] = jsonEncode(request.imageDescriptions);
    }

    for (var file in request.images) {
      final fileBytes = await file.readAsBytes();
      final extension = file.path.split('.').last.toLowerCase();

      http.MediaType contentType;
      switch (extension) {
        case 'png':
          contentType = http.MediaType('image', 'png');
          break;
        case 'webp':
          contentType = http.MediaType('image', 'webp');
          break;
        case 'gif':
          contentType = http.MediaType('image', 'gif');
          break;
        case 'jpg':
        case 'jpeg':
        default:
          contentType = http.MediaType('image', 'jpeg');
      }

      final multipartFile = http.MultipartFile.fromBytes(
        'images',
        fileBytes,
        filename: file.path.split('/').last,
        contentType: contentType,
      );
      requestMultipart.files.add(multipartFile);
    }

    final response = await client.send(requestMultipart);
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to change meter: $responseBody');
    }
  }
}
