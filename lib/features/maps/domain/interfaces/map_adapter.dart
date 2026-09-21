import 'package:flutter/material.dart';
import '../entities/app_map_marker.dart';

abstract class IMapAdapter {
  /// Builds the map widget
  Widget buildMap({
    required double initialLat,
    required double initialLng,
    required double initialZoom,
    required List<AppMapMarker> markers,
    String? mapStyleUrl,
  });

  /// Moves the camera to a specific coordinate
  void moveCamera(double lat, double lng, double zoom);

  void zoomIn();
  void zoomOut();

  /// Disposes resources (controllers, etc.)
  void dispose();
}
