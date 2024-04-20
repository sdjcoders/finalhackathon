import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';
//import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

import 'dart:io' show Platform;

class Maping extends StatefulWidget {
  const Maping({Key? key}) : super(key: key);

  @override
  State<Maping> createState() => _MapingState();
}

class _MapingState extends State<Maping> {
  Location _locationController = Location();
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();
  static const LatLng _kGooglePlex = LatLng(21.137870, 72.762922);
  LatLng? _currentP;

  @override
  void initState() {
    super.initState();
    getLocationUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _kGooglePlex == null
          ? const Center(child: Text("Loading..."))
          : GoogleMap(
              onMapCreated: ((GoogleMapController controller) =>
                  _mapController.complete(controller)),
              initialCameraPosition: CameraPosition(
                target: _kGooglePlex,
                zoom: 13,
              ),
              myLocationButtonEnabled: true,
              markers: {},
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _openLocationSettings();
        },
        child: Icon(Icons.location_on),
      ),
    );
  }

  Future<void> _cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition _newCameraPosition = CameraPosition(
      target: pos,
      zoom: 16,
    );
    await controller
        .animateCamera(CameraUpdate.newCameraPosition(_newCameraPosition));
  }

  Future<void> getLocationUpdate() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _locationController.serviceEnabled();
    if (!_serviceEnabled) {
      _openLocationSettings(); // Request enabling location services directly
      return;
    }

    _permissionGranted = await _locationController.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    /*_locationController.onLocationChanged.listen((LocationData currentlocation) {
      if (currentlocation.latitude != null && currentlocation.longitude != null) {
        setState(() {
          _currentP = LatLng(currentlocation.latitude!, currentlocation.longitude!);
          _cameraToPosition(_currentP!);
        });
      }
    });*/
  }

  Future<void> _openLocationSettings() async {
    if (Platform.isAndroid) {
      await _locationController.requestService();
    } else if (Platform.isIOS) {
      // You can add iOS-specific settings opening mechanism here
      // For iOS, you might need to guide the user to the Settings app manually
      // as there's no direct API to open location settings programmatically.
      // You can use packages like 'url_launcher' with specific URL schemes.
    }
  }
}
