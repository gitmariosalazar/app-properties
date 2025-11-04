import 'package:app_properties/config/environments/environment.dart';
import 'package:app_properties/features/observations/data/models/observation_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

abstract class ObservationsDataSource {
  Future<List<ObservationModel>> fetchObservationsByCadastralKey(
    String connectionId,
  );
  Future<List<ObservationModel>> fetchAllObservations();
}

class ObservationsDataSourceImpl implements ObservationsDataSource {
  final String apiUrl = Environment.apiUrl;

  @override
  Future<List<ObservationModel>> fetchObservationsByCadastralKey(
    String connectionId,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$apiUrl/observations/get-observation-details-by-cadastral-key/$connectionId',
      ),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);

      // Verificar que 'data' exista y sea lista
      final data = decoded['data'];
      if (data is! List) {
        throw Exception(
          'La respuesta de la API no contiene una lista en "data"',
        );
      }

      return data.map((item) => ObservationModel.fromJson(item)).toList();
    } else {
      throw Exception('Error en la API: ${response.statusCode}');
    }
  }

  @override
  Future<List<ObservationModel>> fetchAllObservations() async {
    final response = await http.get(
      Uri.parse('$apiUrl/observations/get-observations'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);

      final data = decoded['data'];
      if (data is! List) {
        throw Exception(
          'La respuesta de la API no contiene una lista en "data"',
        );
      }

      return data.map((item) => ObservationModel.fromJson(item)).toList();
    } else {
      throw Exception('Error en la API: ${response.statusCode}');
    }
  }
}
