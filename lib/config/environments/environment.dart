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

  static MapProviderConfig get mapConfig {
    return MapProviderConfig(
      provider: dotenv.env['USE_API_MAP_DEFAULT']?.toLowerCase() ?? 'carto',
      cartoApiKey: dotenv.env['API_KEY_CARTO'] ?? '',
      mapboxApiKey: dotenv.env['API_KEY_MAPBOX'] ?? '',
      stadiaApiKey: dotenv.env['API_KEY_STREET_MAP'] ?? '',
      useMapboxNative: dotenv.env['USE_MAPBOX_NATIVE']?.toLowerCase() == 'true',
    );
  }
}

class MapProviderConfig {
  final String provider;
  final String cartoApiKey;
  final String mapboxApiKey;
  final String stadiaApiKey;
  final bool useMapboxNative;

  const MapProviderConfig({
    required this.provider,
    required this.cartoApiKey,
    required this.mapboxApiKey,
    required this.stadiaApiKey,
    required this.useMapboxNative,
  });
}
