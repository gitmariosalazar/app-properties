import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class ICoordinateParser {
  LatLng? parse(String input);
}

class CoordinateParser implements ICoordinateParser {
  @override
  LatLng? parse(String input) {
    if (input.trim().isEmpty) return null;
    
    // Attempt to split by comma
    final parts = input.split(',');
    if (parts.length != 2) return null;
    
    final lat = double.tryParse(parts[0].trim());
    final lng = double.tryParse(parts[1].trim());
    
    if (lat != null && lng != null) {
      return LatLng(lat, lng);
    }
    
    return null;
  }
}
