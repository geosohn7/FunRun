import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const FunRunApp());
}

class FunRunApp extends StatelessWidget {
  const FunRunApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FunRun',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _backendStatus = 'Connecting to backend...';
  bool _isLoading = true;

  // In a real device/emulator, 'localhost' might need to be '10.0.2.2' for Android
  final String _apiUrl = 'http://localhost:3000';

  @override
  void initState() {
    super.initState();
    _checkBackend();
  }

  Future<void> _checkBackend() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          _backendStatus = response.body;
          _isLoading = false;
        });
      } else {
        setState(() {
          _backendStatus = 'Error: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _backendStatus = 'Failed to connect to backend.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('FunRun Mobile (Flutter)'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Welcome to FunRun!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              Text(
                'Backend Status: $_backendStatus',
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _checkBackend,
              child: const Text('Refresh Status'),
            ),
          ],
        ),
      ),
    );
  }
}
