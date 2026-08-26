// lib/features/scan/data/datasources/remote_reading_data_source.dart
import 'dart:convert';
import 'package:app_properties/config/environments/environment.dart';
import 'package:app_properties/core/error/exception.dart';
import 'package:app_properties/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:app_properties/features/reading/data/model/create_reading_request.dart';
import 'package:app_properties/features/reading/data/model/reading_basic_info_response.dart';
import 'package:app_properties/features/reading/data/model/reading_info_response.dart';
import 'package:app_properties/features/reading/data/model/reading_response.dart';
import 'package:app_properties/features/reading/data/model/update_reading_request.dart';
import 'package:app_properties/shared/api/response/api_response.dart';
import 'package:http/http.dart' as http;

abstract class RemoteReadingDataSource {
  Future<List<ReadingInfoResponse>> getReadingInfo(String cadastralKey);
  Future<List<ReadingBasicInfoResponse>> findBasicReading(String catastralCode);
  Future<ReadingResponse> updateCurrentReading(
    String readingId,
    UpdateReadingRequest request,
  );
  Future<ReadingResponse> createReading(CreateReadingRequest request);
}

class RemoteReadingDataSourceImpl implements RemoteReadingDataSource {
  final http.Client client;
  final AuthLocalDataSource authLocalDataSource;
  final String baseUrl = Environment.apiUrl;

  RemoteReadingDataSourceImpl(this.client, this.authLocalDataSource);

  Future<Map<String, String>> _getHeaders() async {
    final token = await authLocalDataSource.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<List<ReadingInfoResponse>> getReadingInfo(String cadastralKey) async {
    final headers = await _getHeaders();
    final response = await client.get(
      Uri.parse('$baseUrl/Readings/find-reading-info/$cadastralKey'),
      headers: headers,
    );

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    if (json["status_code"] == 404) {
      throw ServerException(
        'No se encontró lectura para la clave catastral: $cadastralKey',
      );
    }

    // Check for 401 Unauthorized
    if (response.statusCode == 401) {
      throw ServerException('Unauthorized: Please login again', 401);
    }

    if (json.isEmpty) {
      throw ServerException('Respuesta vacía del servidor');
    }

    final apiResponse = ApiResponse<dynamic>.fromJson(
      json,
      (data) => data,
    );

    if (apiResponse.statusCode >= 400) {
      throw ServerException(apiResponse.message.join(', '));
    }

    final rawData = apiResponse.data;
    if (rawData == null) {
      throw ServerException('No se encontró lectura para $cadastralKey');
    }

    List<ReadingInfoResponse> results = [];
    if (rawData is List) {
      results = rawData
          .map((e) => ReadingInfoResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (rawData is Map<String, dynamic>) {
      results = [ReadingInfoResponse.fromJson(rawData)];
    } else {
      throw ServerException('Formato de datos de lectura desconocido');
    }

    if (results.isEmpty) {
      throw ServerException('No se encontró lectura para $cadastralKey');
    }
    return results;
  }

  @override
  Future<List<ReadingBasicInfoResponse>> findBasicReading(
    String catastralCode,
  ) async {
    final headers = await _getHeaders();
    final response = await client.get(
      Uri.parse('$baseUrl/Readings/find-basic-reading/$catastralCode'),
      headers: headers,
    );

    if (response.statusCode == 401) {
      throw ServerException('Unauthorized: Please login again', 401);
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final apiResponse = ApiResponse<dynamic>.fromJson(
      json,
      (data) => data,
    );

    if (apiResponse.statusCode >= 400) {
      throw ServerException(apiResponse.message.join(', '));
    }

    final rawData = apiResponse.data;
    if (rawData == null) {
      return [];
    }

    List<ReadingBasicInfoResponse> results = [];
    if (rawData is List) {
      results = rawData
          .map((e) => ReadingBasicInfoResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (rawData is Map<String, dynamic>) {
      results = [ReadingBasicInfoResponse.fromJson(rawData)];
    } else {
      throw ServerException('Formato de datos de lectura básico desconocido');
    }

    return results;
  }

  @override
  Future<ReadingResponse> updateCurrentReading(
    String readingId,
    UpdateReadingRequest request,
  ) async {
    final headers = await _getHeaders();
    final response = await client.put(
      Uri.parse('$baseUrl/Readings/update-current-reading/$readingId'),
      headers: headers,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 401) {
      throw ServerException('Unauthorized: Please login again', 401);
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    // ApiResponse generic wrapper usually returns List<T>, but for single updates
    // it might be cleaner to parse data directly if the structure allows.
    // Assuming backend returns standard ApiResponse structure where data is List or Single object wrapped.
    // Based on previous code, ApiResponse expects data to be a list.
    // If backend returns single object in data, we might need to adjust or use the first element.

    // However, looking at the backend controller:
    // return new ApiResponse(..., response, ...)
    // 'response' is a ReadingResponse object.

    // ApiResponse.fromJson expects data to be List.
    // Let's check shared/api/response/api_response.dart again:
    // data: (json['data'] as List<dynamic>).map(...)

    // If backend returns a single object in 'data', ApiResponse.fromJson will fail if it casts to List.
    // BUT the backend usually wraps it in a list or the ApiResponse class in backend handles it.
    // In the provided backend controller (Step 161), it passes `response` (ReadingResponse object) to ApiResponse constructor.
    // If the NestJS ApiResponse wrapper puts it in an array or passes as is, depends on that implementation.
    // Assuming standard behavior where data might be a single object for single updates.

    // Let's manually parse for safety since ApiResponse in Steps 24 implementation enforces List.

    final data = json['data'];
    if (data is List) {
      if (data.isEmpty) throw ServerException('Empty response data');
      return ReadingResponse.fromJson(data.first as Map<String, dynamic>);
    } else if (data is Map<String, dynamic>) {
      return ReadingResponse.fromJson(data);
    } else {
      // If data is null or unknown
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Potentially success but no data? Unlikely for update returning ReadingResponse.
        throw ServerException('Invalid response format');
      }
      throw ServerException(json['message']?.toString() ?? 'Update failed');
    }
  }

  @override
  Future<ReadingResponse> createReading(CreateReadingRequest request) async {
    final headers = await _getHeaders();
    final response = await client.post(
      Uri.parse('$baseUrl/Readings/create-reading'),
      headers: headers,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 401) {
      throw ServerException('Unauthorized: Please login again', 401);
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    // Similar handling as update
    final data = json['data'];
    if (data is List) {
      if (data.isEmpty) throw ServerException('Empty response data');
      return ReadingResponse.fromJson(data.first as Map<String, dynamic>);
    } else if (data is Map<String, dynamic>) {
      return ReadingResponse.fromJson(data);
    } else {
      throw ServerException(json['message']?.toString() ?? 'Create failed');
    }
  }
}
