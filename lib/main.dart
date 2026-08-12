import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/setup_screen.dart';

void main() {
  runApp(const HotspotGameApp());
}

class HotspotGameApp extends StatelessWidget {
  const HotspotGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hotspot Card Game',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF111B21), // خلفية داكنة نظيفة
        textTheme: GoogleFonts.tajawalTextTheme(Theme.of(context).textTheme).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF58CC02)),
      ),
      home: const SetupScreen(),
    );
  }
}
