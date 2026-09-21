import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/entities/app_map_marker.dart';
import '../../domain/interfaces/map_adapter.dart';

class FlutterMapAdapter implements IMapAdapter {
  final MapController _mapController = MapController();

  @override
  Widget buildMap({
    required double initialLat,
    required double initialLng,
    required double initialZoom,
    required List<AppMapMarker> markers,
    String? mapStyleUrl,
  }) {
    final flutterMarkers = markers.map((m) {
      return Marker(
        point: LatLng(m.latitude, m.longitude),
        width: m.width,
        height: m.height,
        child: GestureDetector(
          onTap: m.onTap,
          child: m.widget,
        ),
      );
    }).toList();

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: LatLng(initialLat, initialLng),
        initialZoom: initialZoom,
        maxZoom: 18.0,
      ),
      children: [
        if (mapStyleUrl != null && mapStyleUrl.isNotEmpty)
          TileLayer(
            urlTemplate: mapStyleUrl,
            userAgentPackageName: 'com.epaa.app',
            subdomains: const ['a', 'b', 'c', 'd'],
          ),
        MarkerLayer(markers: flutterMarkers),
      ],
    );
  }

  @override
  void moveCamera(double lat, double lng, double zoom) {
    _mapController.move(LatLng(lat, lng), zoom);
  }

  @override
  void zoomIn() {
    _mapController.move(
      _mapController.camera.center,
      _mapController.camera.zoom + 1,
    );
  }

  @override
  void zoomOut() {
    _mapController.move(
      _mapController.camera.center,
      _mapController.camera.zoom - 1,
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
  }
}
