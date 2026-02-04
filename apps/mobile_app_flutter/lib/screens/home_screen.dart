import 'package:flutter/material.dart';
import 'package:mobile_app_flutter/screens/map_screen.dart';
import 'package:mobile_app_flutter/services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // User Data
  String _userId = "";
  String _nickname = "Runner";
  String _tier = "Start Running!";
  int _currentXp = 0;
  int _maxXp = 1000; // Default for Bronze
  double _totalDistance = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 1. Auto Login (Simple version: always logs in as 'Player1')
    // In a real app, you would show a login screen or load from storage.
    final user = await ApiService.loginOrSignup('Runner'); // Default Nickname

    if (user != null) {
      if (mounted) {
        setState(() {
          _userId = user['id'];
          _nickname = user['nickname'];
          _updateUiWithUser(user);
          _isLoading = false;
        });
      }
    } else {
      // Handle error (offline, etc)
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshUserData() async {
    if (_userId.isEmpty) return;

    final user = await ApiService.getUserProfile(_userId);
    if (user != null && mounted) {
      setState(() {
        _updateUiWithUser(user);
      });
    }
  }

  void _updateUiWithUser(Map<String, dynamic> user) {
    _tier = user['tier'] ?? 'BRONZE';
    _currentXp = user['totalXp'] ?? 0;
    _totalDistance = (user['totalDistance'] ?? 0).toDouble();

    // Update Max XP based on Tier (Simple logic)
    if (_tier == 'BRONZE')
      _maxXp = 1000;
    else if (_tier == 'SILVER')
      _maxXp = 5000;
    else if (_tier == 'GOLD')
      _maxXp = 10000;
    else
      _maxXp = 100000;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Calculate XP Progress safely
    double xpProgress = (_currentXp / _maxXp).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Area
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, $_nickname! 👋',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey[900],
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ready to run today?',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.blueAccent.withOpacity(0.1),
                    child: const Icon(
                      Icons.person,
                      color: Colors.blueAccent,
                      size: 30,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // 2. Main Stats Card (Tier & XP)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A90E2), Color(0xFF007AFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF007AFF).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.emoji_events_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$_tier Tier',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'XP Progress',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: xpProgress,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.orangeAccent,
                              ),
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$_currentXp / $_maxXp',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // 3. Additional Stats Grid
              Row(
                children: [
                  Expanded(
                    child: _buildStatBox(
                      icon: Icons.directions_run_rounded,
                      label: 'Total Distance',
                      value: '${_totalDistance.toStringAsFixed(1)}km',
                      color: Colors.orangeAccent,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatBox(
                      icon: Icons.local_fire_department_rounded,
                      label: 'Calories',
                      value:
                          '${(_totalDistance * 60).toInt()}kcal', // Approx calculation
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // 4. Call to Action Button
              Center(
                child: GestureDetector(
                  onTap: () async {
                    if (_userId.isEmpty) return;

                    // Wait for the MapScreen to pop (User finished running)
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapScreen(userId: _userId),
                      ),
                    );

                    // Refresh Data when back
                    _refreshUserData();
                  },
                  child: Container(
                    height: 80,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'GO RUNNING',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(width: 12),
                        Icon(Icons.arrow_forward_rounded, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBox({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    // Same UI code as before...
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
