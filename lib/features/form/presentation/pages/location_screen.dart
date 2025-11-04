import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'dart:async';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  bool _isTracking = false;
  bool _isLoading = true;
  Position? _currentPosition;
  String _currentAddress = 'Cargando ubicación...';
  StreamSubscription<Position>? _positionStreamSubscription;
  GeoPoint? _geoPoint;
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    // Initialize map with user position tracking
    _mapController = MapController(
      initMapWithUserPosition: const UserTrackingOption(
        enableTracking: true,
        unFollowUser: false,
      ),
    );
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showError('Los servicios de ubicación no están habilitados.');
        await _setFallbackLocation();
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError('Permiso de ubicación denegado.');
          await _setFallbackLocation();
          if (mounted) setState(() => _isLoading = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showError(
          'Permiso de ubicación denegado permanentemente. Abre configuración.',
        );
        await Geolocator.openAppSettings();
        await _setFallbackLocation();
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // If permissions are granted, get initial position
      await _getInitialPosition();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Error checking permissions: $e');
        debugPrintStack(stackTrace: stackTrace);
      }
      _showError('Error al verificar permisos: $e');
      await _setFallbackLocation();
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _setFallbackLocation() async {
    try {
      _geoPoint = GeoPoint(latitude: 51.5074, longitude: -0.1278); // London
      await _mapController.goToLocation(_geoPoint!);
      if (mounted) {
        setState(
          () => _currentAddress =
              'Ubicación no disponible (usando Londres como predeterminado)',
        );
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Error setting fallback location: $e');
        debugPrintStack(stackTrace: stackTrace);
      }
      _showError('Error al establecer ubicación predeterminada: $e');
    }
  }

  Future<void> _getInitialPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!mounted) return;
      setState(() {
        _currentPosition = position;
        _geoPoint = GeoPoint(
          latitude: position.latitude,
          longitude: position.longitude,
        );
        _isLoading = false;
      });
      await _mapController.goToLocation(_geoPoint!);
      await _updateAddress(position);
      await _updateMarker(position);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Error getting initial position: $e');
        debugPrintStack(stackTrace: stackTrace);
      }
      _showError('Error al obtener ubicación inicial: $e');
      await _setFallbackLocation();
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateAddress(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty && mounted) {
        Placemark place = placemarks.first;
        String fullAddress =
            "${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}";
        setState(
          () => _currentAddress = fullAddress.trim().isEmpty
              ? 'Dirección no disponible'
              : fullAddress.trim(),
        );
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Error getting address: $e');
        debugPrintStack(stackTrace: stackTrace);
      }
      _showError('Error al obtener dirección: $e');
    }
  }

  Future<void> _updateMarker(Position position) async {
    try {
      if (_geoPoint != null) {
        await _mapController.removeMarkers([_geoPoint!]);
      }
      _geoPoint = GeoPoint(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      await _mapController.addMarker(
        _geoPoint!,
        markerIcon: const MarkerIcon(
          icon: Icon(Icons.location_pin, color: Colors.red, size: 48),
        ),
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Error updating marker: $e');
        debugPrintStack(stackTrace: stackTrace);
      }
      _showError('Error al actualizar marcador: $e');
    }
  }

  void _startTracking() async {
    try {
      if (!mounted) return;
      setState(() => _isTracking = true);
      _positionStreamSubscription =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.best,
              distanceFilter: 5,
            ),
          ).listen(
            (Position position) async {
              if (!mounted) return;
              setState(() {
                _currentPosition = position;
                _geoPoint = GeoPoint(
                  latitude: position.latitude,
                  longitude: position.longitude,
                );
              });

              await _mapController.goToLocation(_geoPoint!);
              await _updateAddress(position);
              await _updateMarker(position);

              if (kDebugMode) {
                debugPrint(
                  "📍 Posición actual: ${position.latitude}, ${position.longitude} => $_currentAddress",
                );
              }
            },
            onError: (e, stackTrace) {
              if (kDebugMode) {
                debugPrint('Error in position stream: $e');
                debugPrintStack(stackTrace: stackTrace);
              }
              if (mounted) {
                _showError('Error en el seguimiento de ubicación: $e');
                setState(() => _isTracking = false);
              }
            },
          );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Error starting tracking: $e');
        debugPrintStack(stackTrace: stackTrace);
      }
      _showError('Error al iniciar seguimiento: $e');
      if (mounted) setState(() => _isTracking = false);
    }
  }

  void _stopTracking() {
    if (!mounted) return;
    setState(() {
      _isTracking = false;
    });
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubicación en Tiempo Real'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: OSMFlutter(
                  controller: _mapController,
                  osmOption: OSMOption(
                    zoomOption: const ZoomOption(
                      initZoom: 17,
                      minZoomLevel: 3,
                      maxZoomLevel: 19,
                      stepZoom: 1.0,
                    ),
                    userLocationMarker: UserLocationMaker(
                      personMarker: const MarkerIcon(
                        icon: Icon(
                          Icons.person_pin_circle,
                          color: Colors.red,
                          size: 48,
                        ),
                      ),
                      directionArrowMarker: const MarkerIcon(
                        icon: Icon(
                          Icons.navigation,
                          color: Colors.blue,
                          size: 36,
                        ),
                      ),
                    ),
                    roadConfiguration: const RoadOption(roadColor: Colors.blue),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _currentAddress,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_currentPosition != null)
                      Text(
                        'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)} | Lon: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      icon: Icon(_isTracking ? Icons.stop : Icons.location_on),
                      label: Text(
                        _isTracking
                            ? 'Detener Seguimiento'
                            : 'Iniciar Seguimiento',
                      ),
                      onPressed: _isTracking ? _stopTracking : _startTracking,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        textStyle: const TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
