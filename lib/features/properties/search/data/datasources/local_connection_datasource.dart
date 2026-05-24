import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_properties/features/properties/search/data/model/schemas/dto/response/connection_response.dart';

abstract class LocalConnectionDataSource {
  Future<void> cacheConnections(String searchValue, List<ConnectionResponse> connections);
  Future<List<ConnectionResponse>?> getCachedConnections(String searchValue);
}

class LocalConnectionDataSourceImpl implements LocalConnectionDataSource {
  final SharedPreferences sharedPreferences;
  static const String _cachePrefix = 'CACHED_CONNECTIONS_';

  LocalConnectionDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheConnections(String searchValue, List<ConnectionResponse> connections) async {
    final jsonList = connections.map((c) => c.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await sharedPreferences.setString('$_cachePrefix$searchValue', jsonString);
  }

  @override
  Future<List<ConnectionResponse>?> getCachedConnections(String searchValue) async {
    final jsonString = sharedPreferences.getString('$_cachePrefix$searchValue');
    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }
    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList.map((item) => ConnectionResponse.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return null;
    }
  }
}
