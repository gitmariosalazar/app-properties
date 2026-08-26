import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:app_properties/config/environments/environment.dart';
import 'package:app_properties/core/error/exception.dart';
import 'package:app_properties/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:app_properties/features/searchs/domain/entities/pending_reading_response.model.dart';
import 'package:http/http.dart' as http;

abstract class IFindPendingReadingsDatasource {
  Future<List<PendingReadingResponse>>
  findPendingReadingsByCadastralKeyOrCardIdAll(String searchValue);
}

class FindPendingReadingsDatasourceImpl
    implements IFindPendingReadingsDatasource {
  final http.Client client;
  final AuthLocalDataSource authLocalDataSource;
  final String _baseUrl = Environment.apiUrl;

  FindPendingReadingsDatasourceImpl({
    required this.client,
    required this.authLocalDataSource,
  });

  Future<Map<String, String>> _getHeaders() async {
    final token = await authLocalDataSource.getToken();
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    } else {
      headers['x-api-key'] = Environment.publicAppApiKey;
    }

    return headers;
  }

  @override
  Future<List<PendingReadingResponse>>
  findPendingReadingsByCadastralKeyOrCardIdAll(String searchValue) async {
    final headers = await _getHeaders();

    try {
      final response = await client.get(
        Uri.parse(
          '$_baseUrl/accounting/find-pending-reading-by-cadastral-key-or-card-id-all/$searchValue',
        ),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List<dynamic> dataList = [];

        if (decoded is List) {
          dataList = decoded;
        } else if (decoded is Map<String, dynamic>) {
          if (decoded.containsKey('data') && decoded['data'] is List) {
            dataList = decoded['data'];
          } else {
            dataList = [decoded];
          }
        }

        return dataList
            .map((json) => PendingReadingResponse.fromJson(json))
            .toList();
      } else {
        throw ServerException(
          'Error al buscar lecturas pendientes (${response.statusCode})',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data?['message'] ?? e.message ?? 'Error de conexión';
      throw ServerException(errorMessage, e.response?.statusCode);
    } catch (e) {
      throw ServerException('Error inesperado: $e', 500);
    }
  }
}
