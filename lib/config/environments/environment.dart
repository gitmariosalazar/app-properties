import 'package:flutter_dotenv/flutter_dotenv.dart';

enum EnvironmentType { dev, prod }

class Environment {
  static Future<void> init({EnvironmentType env = EnvironmentType.prod}) async {
    final fileName = ".env${env == EnvironmentType.dev ? '.dev' : ''}";
    await dotenv.load(fileName: "assets/$fileName");
  }

  static String get apiUrl {
    final url = dotenv.env['API_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('API_URL no está definida en assets/.env');
    }
    return url;
  }

  static void printConfig() {
    if (dotenv.isInitialized) {
      print('Environment loaded:');
      print('  API_URL: $apiUrl');
    }
  }
}
