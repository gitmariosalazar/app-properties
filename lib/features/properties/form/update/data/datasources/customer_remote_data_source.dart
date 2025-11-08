import 'dart:convert';
import 'package:app_properties/config/environments/environment.dart';
import 'package:http/http.dart' as http;
import 'package:app_properties/features/properties/form/update/data/models/dto/request/update_customer_request.dart';

class CustomerRemoteDataSource {
  final http.Client client;
  static final String baseUrl = Environment.apiUrl;

  CustomerRemoteDataSource({required this.client});

  Future<void> updateCustomer({
    required String customerId,
    required UpdateCustomerRequest request,
  }) async {
    final url = Uri.parse('$baseUrl/Customers/update-customer/$customerId');
    final response = await client.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        // Add authentication headers if needed, e.g., 'Authorization': 'Bearer token',
      },
      body: jsonEncode(
        request.toJson()..['customerId'] = int.tryParse(customerId) ?? 0,
      ), // Include customerId in body if required
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to update customer: ${response.body}');
    }
  }
}
