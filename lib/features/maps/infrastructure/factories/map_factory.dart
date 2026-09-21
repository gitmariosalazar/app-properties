import 'package:app_properties/config/environments/environment.dart';
import '../../domain/interfaces/map_adapter.dart';
import '../adapters/flutter_map_adapter.dart';
import '../adapters/mapbox_native_adapter.dart';

class MapFactory {
  static IMapAdapter getAdapter() {
    final config = Environment.mapConfig;

    if (config.useMapboxNative) {
      return MapboxNativeAdapter(mapboxApiKey: config.mapboxApiKey);
    } else {
      return FlutterMapAdapter();
    }
  }
}
