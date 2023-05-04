import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class CurrentLocationScreen extends StatefulWidget {
  const CurrentLocationScreen({super.key});

  @override
  State<CurrentLocationScreen> createState() => _CurrentLocationScreenState();
}

class _CurrentLocationScreenState extends State<CurrentLocationScreen> {
  Position? position;

  Future<bool> checkServicePermission() async {
    bool isEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission;

    if (!isEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Please enable Location services')));
      return false;
    }

    //check location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text(
                'Location permission is denied. You cannot use the app without allowing location permission.')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text(
              'Location permission is denied. Please enable in the settings')));
      return false;
    }
    return true;
  }

  Future<void> getCurrentPosition() async {
    if (!await checkServicePermission()) {
      return;
    }
    await Geolocator.getCurrentPosition().then((value) {
      setState(() {
        position = value;
      });
    });
    print(position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GPS Coordinates'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Lat: ${position?.latitude ?? ''}'),
            Text('Long: ${position?.longitude ?? ''}'),
            ElevatedButton(
              onPressed: getCurrentPosition,
              child: Text('Get Location'),
            ),
          ],
        ),
      ),
    );
  }
}
