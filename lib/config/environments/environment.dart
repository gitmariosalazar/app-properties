import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get apiUrl {
    final url = dotenv.env['API_URL'];
    if (url == null) {
      throw Exception('API_URL no está definida en el archivo .env');
    }
    return url;
  }
}
