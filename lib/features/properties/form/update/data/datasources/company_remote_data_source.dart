import 'dart:convert';
import 'package:app_properties/config/environments/environment.dart';
import 'package:app_properties/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:http/http.dart' as http;
import 'package:app_properties/features/properties/form/update/data/models/dto/request/update_company_request.dart';

class CompanyRemoteDataSource {
  final http.Client client;
  final AuthLocalDataSource authLocalDataSource;

  static final String baseUrl = Environment.apiUrl;

  CompanyRemoteDataSource({
    required this.client,
    required this.authLocalDataSource,
  });

  Future<void> updateCompany({
    required String companyRuc,
    required UpdateCompanyRequest request,
  }) async {
    final token = await authLocalDataSource.getToken();
    final url = Uri.parse('$baseUrl/Customers/update-company/$companyRuc');
    final response = await client.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        // Add authentication headers if needed
      },
      body: jsonEncode(request.toJson()..['companyRuc'] = companyRuc),
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
      throw Exception('Failed to update company: ${response.body}');
    }
  }
}
