import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import "../data/mobiledata.dart";

class VikrantPlayModePage extends StatefulWidget {
  const VikrantPlayModePage({super.key});

  @override
  State<VikrantPlayModePage> createState() => _VikrantPlayModePageState();
}

class _VikrantPlayModePageState extends State<VikrantPlayModePage> with TickerProviderStateMixin {
  Offset _joystickOffset = Offset.zero;
  String? _bikeId;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _initialize();
  }

  Future<void> _initialize() async {
    await loadSavedData();
    setState(() {
      _bikeId = savedBikeNumber;
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void _animateJoystick(Offset offset) {
    setState(() {
      _joystickOffset = offset;
    });

    _updateBikeControl({
      'linear_movement': offset.dy.toStringAsFixed(0),
      'angular_movement': offset.dx.toStringAsFixed(0),
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _joystickOffset = Offset.zero;
      });
      _updateBikeControl({
        'linear_movement': '0',
        'angular_movement': '0',
      });
    });
  }

  Future<void> _updateBikeControl(Map<String, String> data) async {
    final bikeId = _bikeId;
    if (bikeId == null || bikeId.isEmpty) return;

    final bikeRef = FirebaseDatabase.instance.ref().child("bike").child(bikeId);

    await bikeRef.child("bike_control").update(data);

    final now = DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30)); // IST
    final timestamp = now.toIso8601String();

    await bikeRef.child("bike_Details").update({
      "bike_last_controlled_time": timestamp,
      "bike_last_controlled_user_id": savedUserKey ?? "",
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide > 600;
    final double controlSize = isTablet ? 90 : 60;
    final double wheelSize = size.height * 0.35;
    final double joystickSize = size.height * 0.45;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Row(
              children: [
                // Left Joystick
                Expanded(
                  flex: 3,
                  child: Center(
                    child: _buildJoystick(joystickSize),
                  ),
                ),

                // Control Panel
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Expanded(
                        child: Center(
                          child: SizedBox(
                            width: isTablet ? 400 : 300,
                            child: GridView.count(
                              crossAxisCount: 2,
                              mainAxisSpacing: 20,
                              crossAxisSpacing: 20,
                              shrinkWrap: true,
                              children: [
                                _triggerButton(Icons.lightbulb, "Lights", controlSize, 'headlight_front', 'on'),
                                _triggerButton(Icons.volume_up, "Horn", controlSize, 'horn', 'on', autoOff: true),
                                _triggerButton(Icons.arrow_back, "Left Indicator", controlSize, 'indicator_left', 'on'),
                                _triggerButton(Icons.arrow_forward, "Right Indicator", controlSize, 'indicator_right', 'on'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Text(
                          "Vikrant Play Mode",
                          style: TextStyle(
                            fontFamily: 'Nico Moji',
                            fontSize: isTablet ? 28 : 20,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Right Joystick
                Expanded(
                  flex: 3,
                  child: Center(
                    child: _buildJoystick(joystickSize),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJoystick(double size) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[850],
              boxShadow: const [
                BoxShadow(color: Colors.black45, offset: Offset(2, 2), blurRadius: 6),
              ],
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            left: size / 2 - 30 + _joystickOffset.dx,
            top: size / 2 - 30 + _joystickOffset.dy,
            child: _joystickKnob(60),
          ),
          Positioned(
            top: 10,
            child: _joystickButton(Icons.arrow_drop_up, () => _animateJoystick(const Offset(0, -20))),
          ),
          Positioned(
            bottom: 10,
            child: _joystickButton(Icons.arrow_drop_down, () => _animateJoystick(const Offset(0, 20))),
          ),
          Positioned(
            left: 10,
            child: _joystickButton(Icons.arrow_left, () => _animateJoystick(const Offset(-20, 0))),
          ),
          Positioned(
            right: 10,
            child: _joystickButton(Icons.arrow_right, () => _animateJoystick(const Offset(20, 0))),
          ),
        ],
      ),
    );
  }

  Widget _joystickKnob(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[700],
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(color: Colors.black87, blurRadius: 4, offset: Offset(2, 2)),
        ],
      ),
    );
  }

  Widget _joystickButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[700],
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(color: Colors.black87, blurRadius: 4, offset: Offset(2, 2)),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _triggerButton(IconData icon, String label, double size, String field, String onValue,
      {bool autoOff = false}) {
    return GestureDetector(
      onTap: () {
        _updateBikeControl({field: onValue});
        if (autoOff) {
          Future.delayed(const Duration(milliseconds: 500), () {
            _updateBikeControl({field: 'off'});
          });
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(size * 0.25),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(color: Colors.white24, blurRadius: 4, offset: Offset(1, 1)),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: size * 0.6),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }
}
