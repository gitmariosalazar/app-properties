import 'dart:convert';
import 'package:app_properties/config/environments/environment.dart';
import 'package:http/http.dart' as http;
import 'package:app_properties/features/properties/form/update/data/models/dto/request/update_company_request.dart';

class CompanyRemoteDataSource {
  final http.Client client;
  static final String baseUrl = Environment.apiUrl;

  CompanyRemoteDataSource({required this.client});

  Future<void> updateCompany({
    required String companyRuc,
    required UpdateCompanyRequest request,
  }) async {
    final url = Uri.parse('$baseUrl/companies/update-company/$companyRuc');
    final response = await client.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        // Add authentication headers if needed
      },
      body: jsonEncode(request.toJson()..['companyRuc'] = companyRuc),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to update company: ${response.body}');
    }
  }
}
