import 'package:flutter/material.dart';
import 'package:mobile_app_flutter/screens/home_screen.dart';

void main() {
  runApp(const FunRunApp());
}

class FunRunApp extends StatelessWidget {
  const FunRunApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FunRun',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
        fontFamily:
            'Roboto', // Assuming default system font, but good to explicit later
      ),
      home: const HomeScreen(),
    );
  }
}
