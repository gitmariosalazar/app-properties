import 'package:flutter_dotenv/flutter_dotenv.dart';

enum EnvironmentType { dev, prod }

class Environment {
  static Future<void> init({EnvironmentType env = EnvironmentType.prod}) async {
    final fileName = env == EnvironmentType.dev
        ? '.env.dev'
        : '.env.production';
    await dotenv.load(fileName: fileName);
  }

  static String get apiUrl {
    final url = dotenv.env['API_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('API_URL no está definida en .env.production o .env.dev');
    }
    return url;
  }

  static void printConfig() {
    if (dotenv.isInitialized) {
      print('Environment loaded:');
      print('  API_URL: $apiUrl');
    }
  }

  static String get publicAppApiKey {
    return dotenv.env['PUBLIC_APP_API_KEY'] ?? 'mi_token_secreto_epaa_123';
  }
}
