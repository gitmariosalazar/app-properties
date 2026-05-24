// lib/features/properties/presentation/screens/map_picker_screen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

/// All colors resolved from [ColorScheme] — adapts to light/dark.
class MapPickerScreen extends StatefulWidget {
  final double initialLat;
  final double initialLng;
  final Function(double lat, double lng) onLocationPicked;

  const MapPickerScreen({
    super.key,
    required this.initialLat,
    required this.initialLng,
    required this.onLocationPicked,
  });

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  GoogleMapController? _controller;
  late CameraPosition _cameraPosition;
  late Marker _marker;

  @override
  void initState() {
    super.initState();
    _cameraPosition = CameraPosition(
      target: LatLng(widget.initialLat, widget.initialLng),
      zoom: 17,
    );
    _marker = Marker(
      markerId: const MarkerId('picked_location'),
      position: LatLng(widget.initialLat, widget.initialLng),
      draggable: true,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Ubicación'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Confirmar ubicación',
            onPressed: () {
              final pos = _marker.position;
              widget.onLocationPicked(pos.latitude, pos.longitude);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: _cameraPosition,
        onMapCreated: (controller) => _controller = controller,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        markers: {_marker},
        onTap: (latLng) {
          setState(() => _marker = _marker.copyWith(positionParam: latLng));
          _controller?.animateCamera(CameraUpdate.newLatLng(latLng));
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: cs.secondary,
        foregroundColor: cs.onSecondary,
        child: const Icon(Icons.my_location),
        onPressed: () async {
          try {
            final position = await Geolocator.getCurrentPosition();
            final newPos = LatLng(position.latitude, position.longitude);
            setState(() => _marker = _marker.copyWith(positionParam: newPos));
            _controller?.animateCamera(CameraUpdate.newLatLng(newPos));
          } catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: $e')));
          }
        },
      ),
    );
  }
}
