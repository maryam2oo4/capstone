import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationPickerMap extends StatefulWidget {
  final double initialLatitude;
  final double initialLongitude;

  const LocationPickerMap({
    super.key,
    required this.initialLatitude,
    required this.initialLongitude,
  });

  @override
  State<LocationPickerMap> createState() => _LocationPickerMapState();
}

class _LocationPickerMapState extends State<LocationPickerMap> {
  late LatLng _selectedLocation;

  @override
  void initState() {
    super.initState();
    _selectedLocation = LatLng(
      widget.initialLatitude,
      widget.initialLongitude,
    );
  }

  void _confirmLocation() {
    Navigator.pop(context, {
      'latitude': _selectedLocation.latitude,
      'longitude': _selectedLocation.longitude,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Location'),
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              center: _selectedLocation,
              zoom: 16,
              onTap: (tapPosition, point) {
                setState(() {
                  _selectedLocation = point;
                });
              },
            ),
            children: [
              TileLayer(
  urlTemplate:
      'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
  subdomains: ['a', 'b', 'c', 'd'],
),

              MarkerLayer(
                markers: [
                  Marker(
  point: _selectedLocation,
  width: 40,
  height: 40,
  builder: (context) => const Icon(
    Icons.location_pin,
    color: Colors.red,
    size: 40,
  ),
),
                ],
              ),
            ],
          ),

          /// Bottom confirmation panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Lat: ${_selectedLocation.latitude.toStringAsFixed(6)}, '
                    'Lng: ${_selectedLocation.longitude.toStringAsFixed(6)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _confirmLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC3545),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Confirm Location',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
