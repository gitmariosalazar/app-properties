import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:app_properties/utils/coordinate_parser.dart';

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

  // Single Responsibility: UI only handles the text controller
  // Parsing is delegated to the ICoordinateParser service
  final ICoordinateParser _coordinateParser = CoordinateParser();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final initialLatLng = LatLng(widget.initialLat, widget.initialLng);
    
    _searchController.text = '${widget.initialLat}, ${widget.initialLng}';
    
    _cameraPosition = CameraPosition(
      target: initialLatLng,
      zoom: 17,
    );
    
    _marker = Marker(
      markerId: const MarkerId('picked_location'),
      position: initialLatLng,
      draggable: true,
      onDragEnd: (newPosition) {
        // Al soltar el marcador después de arrastrar, actualizamos el estado
        _updateLocation(newPosition, moveCamera: false);
      },
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateLocation(LatLng newPos, {bool moveCamera = true}) {
    setState(() {
      _marker = _marker.copyWith(positionParam: newPos);
      _searchController.text = '${newPos.latitude}, ${newPos.longitude}';
    });
    if (moveCamera) {
      _controller?.animateCamera(CameraUpdate.newLatLng(newPos));
    }
  }

  void _handleSearch() {
    // Open/Closed Principle: Parser can be extended in the future 
    // without changing the UI logic
    final latLng = _coordinateParser.parse(_searchController.text);
    if (latLng != null) {
      _updateLocation(latLng);
      // Opcional: Ocultar el teclado después de buscar
      FocusScope.of(context).unfocus();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Formato de coordenada inválido. Usa "lat, lng"'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _cameraPosition,
            onMapCreated: (controller) => _controller = controller,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: {_marker},
            onTap: (latLng) {
              _updateLocation(latLng);
            },
          ),
          // Search Bar Overlay
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Pegar coordenada (ej. 0.313, -78.210)',
                          border: InputBorder.none,
                        ),
                        keyboardType: TextInputType.text,
                        onSubmitted: (_) => _handleSearch(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      color: cs.primary,
                      onPressed: _handleSearch,
                      tooltip: 'Buscar coordenada',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: cs.secondary,
        foregroundColor: cs.onSecondary,
        child: const Icon(Icons.my_location),
        onPressed: () async {
          try {
            final position = await Geolocator.getCurrentPosition();
            final newPos = LatLng(position.latitude, position.longitude);
            _updateLocation(newPos);
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
