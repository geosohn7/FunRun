import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class MapScreen extends StatefulWidget {
  final String userId;
  const MapScreen({super.key, required this.userId});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  // Tracking Stats
  LatLng? _currentPosition;
  final List<LatLng> _runPath = [];
  bool _isTracking = false;
  double _totalDistance = 0.0;
  String? _runId;
  StreamSubscription<Position>? _positionStreamSubscription;

  // Timer Stats
  int _secondsElapsed = 0;
  Timer? _timer;

  // Backend Config
  // Backend Config
  // For Chrome/Web, localhost works. For Android Emulator use '10.0.2.2'.
  final String _backendUrl = 'http://localhost:3000';

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsElapsed = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int mins = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showError('Location services are disabled.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showError('Location permissions are denied');
        return;
      }
    }

    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });

      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition!, 17),
      );
    } catch (e) {
      print('Error getting initial location: $e');
    }
  }

  // --- Run Control Logic ---

  Future<void> _toggleTracking() async {
    if (_isTracking) {
      await _stopRun();
    } else {
      await _startRun();
    }
  }

  Future<void> _startRun() async {
    try {
      // 1. Tell Backend we are starting
      final response = await http.post(
        Uri.parse('$_backendUrl/runs/start'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': widget.userId}), // Use dynamic User ID
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _runId = data['runId'];
          _isTracking = true;
          _runPath.clear();
          _totalDistance = 0.0;
        });

        _startTimer();

        // 2. Start Real-time tracking stream
        _positionStreamSubscription = Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5, // Update every 5 meters
          ),
        ).listen(_onLocationUpdate);

        _showSnackBar('Run Started!');
      }
    } catch (e) {
      _showError('Backend Connection Error: $e');
    }
  }

  void _onLocationUpdate(Position position) async {
    final newPoint = LatLng(position.latitude, position.longitude);

    setState(() {
      _currentPosition = newPoint;
      _runPath.add(newPoint);
    });

    // Move camera slightly
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLng(newPoint));

    // Send update to backend
    if (_runId != null) {
      try {
        final response = await http.post(
          Uri.parse('$_backendUrl/runs/update'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'runId': _runId,
            'latitude': position.latitude,
            'longitude': position.longitude,
          }),
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          final data = jsonDecode(response.body);
          setState(() {
            _totalDistance = data['totalDistance'].toDouble();
          });
        }
      } catch (e) {
        print('Location update failed: $e');
      }
    }
  }

  Future<void> _stopRun() async {
    if (_runId == null) return;

    try {
      _positionStreamSubscription?.cancel();
      _timer?.cancel();

      final response = await http.post(
        Uri.parse('$_backendUrl/runs/stop'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'runId': _runId}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _isTracking = false;
        });

        _showSummaryDialog(data['finalDistance'], data['summary']);
      }
    } catch (e) {
      _showError('Stop run failed: $e');
    }
  }

  // --- UI Components ---

  void _showError(String message) {
    _showSnackBar(message);
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showSummaryDialog(dynamic distance, String summary) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Run Finished! 🏃‍♂️'),
        content: Text(
          'Total Distance: ${distance.toStringAsFixed(2)}m\n$summary',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Great!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Map Tracking',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.black87),
      ),
      body: Stack(
        children: [
          // 1. Full Screen Map
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: const CameraPosition(
              target: LatLng(37.5665, 126.9780), // Seoul default
              zoom: 15,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            polylines: {
              Polyline(
                polylineId: const PolylineId('runPath'),
                points: _runPath,
                color: Colors.blueAccent,
                width: 5,
              ),
            },
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),

          // 2. Status Card (Top)
          if (_isTracking)
            Positioned(
              top: 100, // Adjusted for AppBar
              left: 20,
              right: 20,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20.0,
                    horizontal: 16.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        'DISTANCE',
                        '${_totalDistance.toStringAsFixed(1)}m',
                      ),
                      Container(
                        height: 40,
                        width: 1,
                        color: Colors.grey.shade300,
                      ),
                      _buildStatItem('TIME', _formatTime(_secondsElapsed)),
                    ],
                  ),
                ),
              ),
            ),

          // 3. Control Button (Bottom)
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _toggleTracking,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _isTracking
                        ? Colors.redAccent
                        : Colors.greenAccent.shade700,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            (_isTracking
                                    ? Colors.redAccent
                                    : Colors.greenAccent.shade700)
                                .withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isTracking ? Icons.stop_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 45,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
