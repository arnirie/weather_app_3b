import 'package:flutter/material.dart';
import 'package:weather_3b/screens/current_location_screen.dart';
import 'package:weather_3b/screens/maps_screen.dart';

import 'screens/register_screen.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MapsScreen(),
    );
  }
}
