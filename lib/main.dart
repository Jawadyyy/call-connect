import 'package:call_connect/splash_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const AgoraCallApp());
}

class AgoraCallApp extends StatelessWidget {
  const AgoraCallApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agora Call App',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const SplashScreen(),
    );
  }
}
