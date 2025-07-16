import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class BikeMapPage extends StatefulWidget {
  final String gpsString;

  const BikeMapPage({super.key, required this.gpsString});

  @override
  State<BikeMapPage> createState() => _BikeMapPageState();
}

class _BikeMapPageState extends State<BikeMapPage> {
  late final double? lat;
  late final double? lng;
  late final MapController mapController;
  bool isFullScreen = false;

  @override
  void initState() {
    super.initState();
    mapController = MapController();

    final gpsParts = widget.gpsString.split(',');
    lat = double.tryParse(gpsParts[0].trim());
    lng = double.tryParse(gpsParts[1].trim());
  }

  @override
  Widget build(BuildContext context) {
    if (lat == null || lng == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text("GPS Map", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.black,
        ),
        body: const Center(
          child: Text("Invalid GPS coordinates", style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Bike Location", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(
              isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                isFullScreen = !isFullScreen;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: LatLng(lat!, lng!),
                initialZoom: 16,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  // 🔒 No subdomains to comply with OSM policy
                  userAgentPackageName: 'com.example.vikrant',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(lat!, lng!),
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.location_on,
                        size: 40,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Zoom In Button
          Positioned(
            bottom: 80,
            right: 16,
            child: FloatingActionButton(
              heroTag: "zoomIn",
              backgroundColor: Colors.white,
              mini: true,
              onPressed: () {
                final zoom = mapController.camera.zoom + 1;
                mapController.move(mapController.camera.center, zoom);
              },
              child: const Icon(Icons.zoom_in, color: Colors.black),
            ),
          ),

          // Zoom Out Button
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              heroTag: "zoomOut",
              backgroundColor: Colors.white,
              mini: true,
              onPressed: () {
                final zoom = mapController.camera.zoom - 1;
                mapController.move(mapController.camera.center, zoom);
              },
              child: const Icon(Icons.zoom_out, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
