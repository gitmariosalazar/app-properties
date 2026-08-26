import 'dart:convert';

import 'package:app_properties/config/environments/environment.dart';
import 'package:app_properties/core/error/exception.dart';
import 'package:app_properties/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:app_properties/features/auth/data/models/auth_response_model.dart';
import 'package:app_properties/features/auth/domain/entities/verify_user_result.dart';
import 'package:app_properties/features/auth/domain/schemas/dto/request/ChangePasswordRequest.dart';
import 'package:http/http.dart' as http;

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(String username_or_email, String password);
  Future<AuthResponseModel> refreshToken(String refreshToken);
  Future<void> logout();

  /// Throws [NetworkException] if offline. Throws [ServerException] if server errors.
  Future<VerifyUserResult> verifyUser(String usernameOrEmail);
  Future<void> changePassword(String userId, ChangePasswordRequest request);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;
  final AuthLocalDataSource authLocalDataSource;
  final String baseUrl = Environment.apiUrl;

  AuthRemoteDataSourceImpl({
    required this.client,
    required this.authLocalDataSource,
  });

  Future<Map<String, String>> _getHeaders() async {
    final token = await authLocalDataSource.getToken();
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  @override
  Future<AuthResponseModel> login(
    String username_or_email,
    String password,
  ) async {
    return guardNetwork(() async {
      final uri = Uri.parse('$baseUrl/auth/signin');
      final response = await client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username_or_email': username_or_email,
          'password': password,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final json = jsonDecode(response.body);
        final data = json['data'];
        if (data == null) {
          throw ServerException('Invalid response: missing data');
        }
        if (data is Map<String, dynamic>) {
          print('✅✅✅✅✅✅ Data: ${data}');
          return AuthResponseModel.fromJson(data);
        }
        throw ServerException('Invalid response: data is not an object');
      } else {
        try {
          final json = jsonDecode(response.body);
          final messageData = json['message'];
          String errorMessage = 'Error al iniciar sesión';

          if (messageData is List && messageData.isNotEmpty) {
            errorMessage = messageData.join('\n');
          } else if (messageData is String) {
            errorMessage = messageData;
          }

          if (errorMessage.contains('Invalid credentials')) {
            errorMessage =
                'Usuario o contraseña incorrectos. Por favor, inténtalo de nuevo.';
          }

          throw ServerException(errorMessage, response.statusCode);
        } catch (e) {
          if (e is ServerException) rethrow;
          throw ServerException(
            'Login failed with status code ${response.statusCode}',
            response.statusCode,
          );
        }
      }
    });
  }

  @override
  Future<AuthResponseModel> refreshToken(String refreshToken) async {
    return guardNetwork(() async {
      final uri = Uri.parse('$baseUrl/auth/refresh');
      final response = await client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final json = jsonDecode(response.body);
        final data = json['data'];
        if (data == null) {
          throw ServerException('Invalid response: missing data');
        }
        if (data is Map<String, dynamic>) {
          return AuthResponseModel.fromJson(data);
        }
        throw ServerException('Invalid response: data is not an object');
      } else {
        try {
          final json = jsonDecode(response.body);
          throw ServerException(
            json['message']?.toString() ?? 'Refresh token failed',
            response.statusCode,
          );
        } catch (e) {
          if (e is ServerException) rethrow;
          throw ServerException(
            'Refresh token failed with status ${response.statusCode}',
            response.statusCode,
          );
        }
      }
    });
  }

  @override
  Future<void> logout() async {
    try {
      final uri = Uri.parse('$baseUrl/auth/signout');
      await client.post(uri, headers: {'Content-Type': 'application/json'});
    } catch (_) {
      // Logout is best-effort — never block the UI
    }
  }

  @override
  Future<VerifyUserResult> verifyUser(String usernameOrEmail) async {
    return guardNetwork(() async {
      final uri = Uri.parse('$baseUrl/auth/verify');
      final response = await client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username_or_email': usernameOrEmail}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final data = json['data'];
        if (data == null) {
          throw ServerException('Invalid verify response: missing data');
        }
        return VerifyUserResult.fromJson(data as Map<String, dynamic>);
      } else {
        try {
          final json = jsonDecode(response.body);
          throw ServerException(
            json['message']?.toString() ?? 'User verification failed',
            response.statusCode,
          );
        } catch (e) {
          if (e is ServerException) rethrow;
          throw ServerException(
            'User verification failed with status ${response.statusCode}',
            response.statusCode,
          );
        }
      }
    });
  }

  @override
  Future<void> changePassword(
    String userId,
    ChangePasswordRequest request,
  ) async {
    return guardNetwork(() async {
      final authResponse = await authLocalDataSource.getAuthResponse();
      final uri = Uri.parse('$baseUrl/users-gateway/update-password/$userId');
      final response = await client.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (authResponse != null)
            'Authorization': 'Bearer ${authResponse.accessToken}',
        },
        body: jsonEncode({
          'oldPassword': request.oldPassword,
          'newPassword': request.newPassword,
          'confirmNewPassword': request.confirmNewPassword,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      } else {
        try {
          final json = jsonDecode(response.body);
          throw ServerException(
            json['message']?.toString() ?? 'Change password failed',
            response.statusCode,
          );
        } catch (e) {
          if (e is ServerException) rethrow;
          throw ServerException(
            'Change password failed with status ${response.statusCode}',
            response.statusCode,
          );
        }
      }
    });
  }
}
