import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../../../../../config/environments/environment.dart';
import '../../../../../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../../../../../shared/api/response/api_response.dart';
import '../models/uploaded_document_model.dart';

abstract class DocumentRemoteDataSource {
  Future<UploadedDocumentModel> uploadDocument({
    required Uint8List fileBytes,
    required String filename,
    required String codigoTipoDocumento,
    required String entityType,
    required String entityId,
    String? nivelAcceso,
    List<String>? rolesPermitidos,
    Map<String, dynamic>? metadatosExtras,
  });
}

class DocumentRemoteDataSourceImpl implements DocumentRemoteDataSource {
  final http.Client client;
  final AuthLocalDataSource authLocalDataSource;
  final String baseUrl = Environment.apiUrl;

  DocumentRemoteDataSourceImpl(this.client, this.authLocalDataSource);

  @override
  Future<UploadedDocumentModel> uploadDocument({
    required Uint8List fileBytes,
    required String filename,
    required String codigoTipoDocumento,
    required String entityType,
    required String entityId,
    String? nivelAcceso,
    List<String>? rolesPermitidos,
    Map<String, dynamic>? metadatosExtras,
  }) async {
    final token = await authLocalDataSource.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Token de autenticación no encontrado');
    }

    final uri = Uri.parse('$baseUrl/Documents/upload');
    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';

    // Add physical file
    final mimeType = filename.endsWith('.pdf') ? 'application/pdf' : 'image/jpeg';
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: filename,
        contentType: MediaType.parse(mimeType),
      ),
    );

    // Add fields
    request.fields['codigoTipoDocumento'] = codigoTipoDocumento;
    request.fields['entityType'] = entityType;
    request.fields['entityId'] = entityId;

    if (nivelAcceso != null) {
      request.fields['nivelAcceso'] = nivelAcceso;
    }
    if (rolesPermitidos != null && rolesPermitidos.isNotEmpty) {
      request.fields['rolesPermitidos'] = jsonEncode(rolesPermitidos);
    }
    if (metadatosExtras != null && metadatosExtras.isNotEmpty) {
      request.fields['metadatosExtras'] = jsonEncode(metadatosExtras);
    }

    debugPrint('📤 Subiendo documento a: $uri');
    debugPrint('📤 Campos: ${request.fields}');

    final streamedResponse = await request.send();
    final responseBody = await streamedResponse.stream.bytesToString();

    debugPrint('📥 Respuesta: ${streamedResponse.statusCode}');
    debugPrint('📥 Cuerpo de Respuesta: $responseBody');

    if (streamedResponse.statusCode == 401) {
      throw Exception('Token no autorizado o expirado');
    }

    if (streamedResponse.statusCode < 200 || streamedResponse.statusCode >= 300) {
      throw Exception('Error al subir el documento (HTTP ${streamedResponse.statusCode}): $responseBody');
    }

    final json = jsonDecode(responseBody) as Map<String, dynamic>;
    final apiResponse = ApiResponse<dynamic>.fromJson(json, (data) => data);

    if (apiResponse.statusCode < 200 || apiResponse.statusCode >= 300) {
      throw Exception(apiResponse.message.join(', '));
    }

    final rawData = apiResponse.data;
    if (rawData == null) {
      throw Exception('Respuesta vacía del servidor');
    }

    if (rawData is Map<String, dynamic>) {
      return UploadedDocumentModel.fromJson(rawData);
    } else {
      throw Exception('Formato de datos de documento inválido');
    }
  }
}
