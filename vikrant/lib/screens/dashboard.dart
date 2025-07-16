import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../widgets/hamburger_menu.dart';
import '../widgets/notification_page.dart';

class DashboardPage extends StatefulWidget {
  final String bikeNumber;

  const DashboardPage({super.key, required this.bikeNumber});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final databaseRef = FirebaseDatabase.instance.ref();
  Map<String, dynamic> dashboardData = {};
  StreamSubscription<DatabaseEvent>? _dashboardSubscription;
  LatLng? gpsCoordinates;
  late final MapController mapController;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    _startRealtimeDashboardListener();
  }

  @override
  void dispose() {
    _dashboardSubscription?.cancel();
    super.dispose();
  }

  void _startRealtimeDashboardListener() {
    final bikePath = 'bike/${widget.bikeNumber}/bike_dashboard';

    _dashboardSubscription =
        databaseRef.child(bikePath).onValue.listen((event) {
          final rawData = event.snapshot.value;

          if (rawData is Map) {
            final data = Map<String, dynamic>.from(rawData);

            if (data['gps_location'] != null &&
                data['gps_location'].contains(',')) {
              final parts = data['gps_location'].split(',');
              final lat = double.tryParse(parts[0].trim());
              final lng = double.tryParse(parts[1].trim());

              if (lat != null && lng != null) {
                setState(() {
                  gpsCoordinates = LatLng(lat, lng);
                });
              }
            }

            setState(() {
              dashboardData = data;
            });
          } else {
            debugPrint('Unexpected data type from Firebase: ${rawData.runtimeType}');
          }
        }, onError: (error) {
          debugPrint('Firebase stream error: $error');
        });
  }

  void _showFullScreenMap() {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(0),
        child: Stack(
          children: [
            FlutterMap(
              mapController: MapController(),
              options: MapOptions(
                initialCenter: gpsCoordinates!,
                initialZoom: 16,
                interactionOptions:
                const InteractionOptions(flags: InteractiveFlag.all),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                  'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.vikrant',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: gpsCoordinates!,
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      child: const Icon(Icons.location_on,
                          size: 40, color: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              top: 40,
              right: 20,
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                mini: true,
                onPressed: () => Navigator.of(context).pop(),
                child: const Icon(Icons.close, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBikeStatusHeader() {
    final isConnected = dashboardData['bike_connected'] == 'on';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color.fromRGBO(255, 255, 255, 0.05),
        border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.bikeNumber,
            style: const TextStyle(
              fontSize: 18,
              fontFamily: 'Nico Moji',
              color: Colors.white,
            ),
          ),
          Row(
            children: [
              Icon(
                Icons.circle,
                size: 12,
                color: isConnected ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 6),
              Text(
                isConnected ? 'On' : 'Off',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Nico Moji',
                  color: isConnected ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataCard(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 255, 255, 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: const Color.fromRGBO(255, 255, 255, 0.2)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 36, color: Colors.white),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Nico Moji',
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Nico Moji',
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMap() {
    if (gpsCoordinates == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'GPS coordinates not available',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return Container(
      height: 250,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: gpsCoordinates!,
                initialZoom: 15,
                interactionOptions:
                const InteractionOptions(flags: InteractiveFlag.all),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                  'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.vikrant',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: gpsCoordinates!,
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      child: const Icon(Icons.location_on,
                          size: 40, color: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: Column(
                children: [
                  FloatingActionButton(
                    heroTag: "zoomIn",
                    backgroundColor: Colors.white,
                    mini: true,
                    onPressed: () {
                      final zoom = mapController.camera.zoom + 1;
                      mapController.move(mapController.camera.center, zoom);
                    },
                    child: const Icon(Icons.zoom_in, color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  FloatingActionButton(
                    heroTag: "zoomOut",
                    backgroundColor: Colors.white,
                    mini: true,
                    onPressed: () {
                      final zoom = mapController.camera.zoom - 1;
                      mapController.move(mapController.camera.center, zoom);
                    },
                    child: const Icon(Icons.zoom_out, color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  FloatingActionButton(
                    heroTag: "expandMap",
                    backgroundColor: Colors.white,
                    mini: true,
                    onPressed: () => _showFullScreenMap(),
                    child: const Icon(Icons.fullscreen, color: Colors.black),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      drawer: const HamburgerMenu(),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.directions_bike),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          "Vikrant Connect",
          style: TextStyle(
            fontFamily: 'Nico Moji',
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            color: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NotificationPage()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 20),
          children: [
            _buildBikeStatusHeader(),
            _buildDataCard("Distance",
                "${dashboardData['distance_travelled'] ?? '--'} km", Icons.alt_route),
            _buildDataCard("Speed", "${dashboardData['speed'] ?? '--'} km/h",
                Icons.speed),
            _buildDataCard("Acceleration",
                "${dashboardData['acceleration'] ?? '--'} m/s²", Icons.trending_up),
            _buildDataCard("Battery",
                "${dashboardData['battery_percentage'] ?? '--'}%", Icons.battery_full),
            _buildDataCard("Charging", "${dashboardData['charge'] ?? '--'}",
                Icons.electric_bike),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Live Location",
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Nico Moji',
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildMap(),
          ],
        ),
      ),
    );
  }
}
