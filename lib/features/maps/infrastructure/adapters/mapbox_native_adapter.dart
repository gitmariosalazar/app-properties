import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../../domain/entities/app_map_marker.dart';
import '../../domain/interfaces/map_adapter.dart';

class MapboxNativeAdapter implements IMapAdapter {
  MapboxMap? _mapboxMap;
  PointAnnotationManager? _pointAnnotationManager;
  final String mapboxApiKey;
  bool _isMapReady = false;

  MapboxNativeAdapter({required this.mapboxApiKey}) {
    MapboxOptions.setAccessToken(mapboxApiKey);
  }

  @override
  Widget buildMap({
    required double initialLat,
    required double initialLng,
    required double initialZoom,
    required List<AppMapMarker> markers,
    String? mapStyleUrl,
  }) {
    // Actualizar estilo dinámicamente si el widget se vuelve a construir
    final styleUri = _getMapboxStyleUri(mapStyleUrl);
    if (_isMapReady && _mapboxMap != null) {
      _mapboxMap!.loadStyleURI(styleUri);
    }

    return MapWidget(
      key: const ValueKey("mapbox_map"),
      cameraOptions: CameraOptions(
        center: Point(coordinates: Position(initialLng, initialLat)),
        zoom: initialZoom - 1, // Mapbox zoom is usually ~1 unit off compared to Leaflet
      ),
      styleUri: _getMapboxStyleUri(mapStyleUrl),
      onMapCreated: (MapboxMap mapboxMap) async {
        _mapboxMap = mapboxMap;
        
        // Disable logo and attribution if needed, or adjust compass
        mapboxMap.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
        
        _pointAnnotationManager = await mapboxMap.annotations.createPointAnnotationManager();
        _isMapReady = true;

        _syncMarkers(markers);
      },
    );
  }

  @override
  void moveCamera(double lat, double lng, double zoom) {
    if (_mapboxMap != null) {
      _mapboxMap!.flyTo(
        CameraOptions(
          center: Point(coordinates: Position(lng, lat)),
          zoom: zoom - 1,
        ),
        MapAnimationOptions(duration: 500),
      );
    }
  }

  @override
  void zoomIn() async {
    if (_mapboxMap == null) return;
    final camera = await _mapboxMap!.getCameraState();
    _mapboxMap!.flyTo(
      CameraOptions(zoom: camera.zoom + 1),
      MapAnimationOptions(duration: 500),
    );
  }

  @override
  void zoomOut() async {
    if (_mapboxMap == null) return;
    final camera = await _mapboxMap!.getCameraState();
    _mapboxMap!.flyTo(
      CameraOptions(zoom: camera.zoom - 1),
      MapAnimationOptions(duration: 500),
    );
  }

  @override
  void dispose() {
    _pointAnnotationManager?.deleteAll();
    _mapboxMap = null;
  }

  /// Sync markers.
  /// NOTE: `mapbox_maps_flutter` version 2.x does NOT support native `ViewAnnotations` (Flutter Widgets) 
  /// directly on the `MapboxMap` controller.
  /// To render `AppMapMarker`s (which use `Widget`), you must either:
  /// 1. Use the `FlutterMapAdapter` instead.
  /// 2. Convert the `Widget`s to images (ByteData) and use `_pointAnnotationManager?.create(PointAnnotationOptions(...))`
  void _syncMarkers(List<AppMapMarker> markers) async {
    if (!_isMapReady || _mapboxMap == null) return;
    
    // TODO: Implement PointAnnotations using _pointAnnotationManager
    // Flutter widgets cannot be directly added to mapbox_maps_flutter v2 natively.
    debugPrint("MapboxNativeAdapter: Syncing markers is currently unsupported for Widget markers.");
  }

  String _getMapboxStyleUri(String? url) {
    if (url == null || url.isEmpty) return MapboxStyles.STANDARD;
    
    // Mapbox Native uses mapbox://styles/... instead of http urls.
    // Try to extract the style id if it's a mapbox url
    if (url.contains('api.mapbox.com/styles/v1/mapbox/')) {
      final RegExp regExp = RegExp(r'mapbox/([^/]+)/tiles');
      final match = regExp.firstMatch(url);
      if (match != null) {
        final styleId = match.group(1);
        return 'mapbox://styles/mapbox/$styleId';
      }
    }
    
    return MapboxStyles.STANDARD;
  }
}
