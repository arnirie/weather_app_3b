import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  static final initialPosition = LatLng(15.988074641736006, 120.57355709373951);
  late GoogleMapController _mapController;

  List<Marker> _markers = <Marker>[
    Marker(
      markerId: MarkerId('01'),
      position: initialPosition,
      infoWindow: InfoWindow(title: 'PSU'),
    ),
  ];

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

  Future<void> getLocation() async {
    if (!await checkServicePermission()) {
      return;
    }
    Geolocator.getPositionStream(
      locationSettings:
          LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 1),
    ).listen((position) {
      updateMarkerCamera(LatLng(position.latitude, position.longitude));
    });
  }

  void updateMarkerCamera(LatLng position) {
    _markers.clear();
    _markers.add(
      Marker(
          markerId: MarkerId('${position.latitude + position.longitude}'),
          position: position,
          infoWindow: InfoWindow(
            title: 'Arni\'s Location',
          )),
    );
    //camera position
    CameraPosition _cameraPosition = CameraPosition(target: position, zoom: 18);
    _mapController
        .animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GoogleMap(
          mapType: MapType.normal,
          zoomControlsEnabled: true,
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          initialCameraPosition: CameraPosition(
            target: initialPosition,
            zoom: 10,
            // tilt: 0,
            // bearing: 60,
          ),
          onTap: (position) {
            print('${position.latitude}, ${position.longitude}');
            updateMarkerCamera(position);
          },
          markers: _markers.toSet(),
          onMapCreated: (controller) {
            _mapController = controller;
          },
        ),
      ),
    );
  }
}
