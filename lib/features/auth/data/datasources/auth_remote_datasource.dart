import 'dart:convert';

import 'package:app_properties/config/environments/environment.dart';
import 'package:app_properties/core/error/exception.dart';
import 'package:app_properties/features/auth/data/models/auth_response_model.dart';
import 'package:http/http.dart' as http;

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(String usernameOrEmail, String password);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;
  final String baseUrl = Environment.apiUrl;

  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<AuthResponseModel> login(
    String usernameOrEmail,
    String password,
  ) async {
    final uri = Uri.parse('$baseUrl/auth/signin');
    final response = await client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username_or_email': usernameOrEmail,
        'password': password,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);
      // Assuming structure similar to ApiResponse but we handle parsing manually
      // since the generic ApiResponse might expect a List

      // Check if 'data' exists, otherwise use root (unlikely for ApiResponse wrapper)
      // Usually ApiResponse puts payload in 'data'.
      final data = json['data'];
      if (data == null) {
        throw ServerException('Invalid response: missing data');
      }

      // If data is array, take first (unlikely for login) or it is the object.
      if (data is Map<String, dynamic>) {
        return AuthResponseModel.fromJson(data);
      } else {
        throw ServerException('Invalid response: data is not an object');
      }
    } else {
      // try to parse message
      try {
        final json = jsonDecode(response.body);
        throw ServerException(json['message']?.toString() ?? 'Login failed');
      } catch (e) {
        if (e is ServerException) rethrow;
        throw ServerException(
          'Login failed with status code ${response.statusCode}',
        );
      }
    }
  }

  @override
  Future<void> logout() async {
    final uri = Uri.parse('$baseUrl/auth/signout');
    final response = await client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    } else {
      throw ServerException('Logout failed');
    }
  }
}
