import 'dart:convert';

import 'package:app_properties/config/environments/environment.dart';
import 'package:app_properties/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:app_properties/features/properties/search/data/model/schemas/dto/response/connection_response.dart';
import 'package:app_properties/shared/api/response/api_response.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

abstract class RemoteConnectionDataSource {
  Future<List<ConnectionResponse>>
  getConnectionByCadastralKeyOrClientIdOrCardId(String searchValue);
}

class RemoteConnectionDataSourceImpl implements RemoteConnectionDataSource {
  final http.Client client;
  final AuthLocalDataSource authLocalDataSource;

  final String baseUrl = Environment.apiUrl;

  RemoteConnectionDataSourceImpl(this.client, this.authLocalDataSource);

  @override
  Future<List<ConnectionResponse>>
  getConnectionByCadastralKeyOrClientIdOrCardId(String searchValue) async {
    final token = await authLocalDataSource.getToken();
    final response = await client.get(
      Uri.parse(
        '$baseUrl/connections/find-connection-by-cadastral-key-or-card-id/$searchValue',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    debugPrint('Response status: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');

    if (token == null) {
      throw Exception('Token no encontrado');
    }

    if (token.isEmpty) {
      throw Exception('Token no encontrado');
    }

    if (response.statusCode == 401) {
      throw Exception('Token no autorizado');
    }

    if (response.statusCode == 404) {
      throw Exception(
        'No se encontró registro para el número de cédula/RUC o clave catastral: $searchValue',
      );
    }

    // 1. Verifica HTTP status
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Error HTTP ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    try {
      final apiResponse = ApiResponse<dynamic>.fromJson(json, (data) => data);

      // 2. Verifica el status_code del JSON (201 es éxito)
      if (apiResponse.statusCode < 200 || apiResponse.statusCode >= 300) {
        throw Exception(apiResponse.message.join(', '));
      }

      final rawData = apiResponse.data;
      if (rawData == null) {
        throw Exception(
          'No se encontró conexión para la clave catastral: $searchValue',
        );
      }

      List<ConnectionResponse> connections = [];
      if (rawData is List) {
        connections = rawData
            .map((e) => ConnectionResponse.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (rawData is Map<String, dynamic>) {
        connections = [ConnectionResponse.fromJson(rawData)];
      } else {
        throw Exception('Formato de datos de conexión desconocido');
      }

      return connections;
    } catch (e, stackTrace) {
      debugPrint('Error parseando ConnectionResponse: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
