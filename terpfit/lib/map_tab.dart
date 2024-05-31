import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;

class MapTab extends StatefulWidget {
  const MapTab({super.key});

  @override
  _MapTabState createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  late MapController mapController;
  LatLng? currentLocation;
  List<Marker> markers = [];
  double? nearestDistance;
  double? currentBearing; // Bearing to nearest fitness center

  final List<LatLng> fitnessCenters = [
    const LatLng(38.9938118370325, -76.94516287487839), // Eppley
    const LatLng(38.98524546226578, -76.9364524613873), // Ritchie
    const LatLng(38.99369297602245, -76.9431019460422), // SPH
    const LatLng(38.99683075160181, -76.92265491905904) // Severn
  ];

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    locateUser();
  }

  void locateUser() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission != LocationPermission.denied &&
        permission != LocationPermission.deniedForever) {
      Geolocator.getPositionStream().listen(
        (Position position) {
          setState(() {
            currentLocation = LatLng(position.latitude, position.longitude);
            updateMarkers();
            updateNearestDistance();
          });
        },
      );
    } else {
      // Handle location permission denied scenario
      setState(() {
        currentLocation = const LatLng(38.9938118370325,
            -76.94516287487839); // Default to Eppley if location permission is denied
        updateMarkers();
      });
    }
  }

  void updateMarkers() {
    markers = [
      Marker(
        width: 80.0,
        height: 80.0,
        point: currentLocation!,
        child: const Icon(Icons.my_location, color: Colors.blue, size: 40),
      ),
      ...fitnessCenters
          .map((center) => Marker(
                width: 80.0,
                height: 80.0,
                point: center,
                child: const Icon(Icons.fitness_center, color: Colors.red, size: 40),
              ))
          .toList()
    ];
  }

  void updateNearestDistance() {
    if (currentLocation == null) return;
    LatLng nearestCenter = const LatLng(0, 0);
    double minDistance = double.infinity;
    for (var center in fitnessCenters) {
      double distance = Geolocator.distanceBetween(
        currentLocation!.latitude,
        currentLocation!.longitude,
        center.latitude,
        center.longitude,
      );
      if (distance < minDistance) {
        minDistance = distance;
        nearestCenter = center;
      }
    }
    nearestDistance = minDistance;
    updateBearing(nearestCenter);
  }

  void updateBearing(LatLng nearestCenter) {
    if (currentLocation == null || nearestCenter == null) return;
    currentBearing = calculateBearing(currentLocation!, nearestCenter);
  }

  double calculateBearing(LatLng startPoint, LatLng endPoint) {
    var startLat = degreesToRadians(startPoint.latitude);
    var startLong = degreesToRadians(startPoint.longitude);
    var endLat = degreesToRadians(endPoint.latitude);
    var endLong = degreesToRadians(endPoint.longitude);

    var dLong = endLong - startLong;

    var dPhi = math.log(math.tan(endLat / 2.0 + math.pi / 4.0) /
        math.tan(startLat / 2.0 + math.pi / 4.0));
    if (dLong.abs() > math.pi) {
      if (dLong > 0.0) {
        dLong = -(2.0 * math.pi - dLong);
      } else {
        dLong = (2.0 * math.pi + dLong);
      }
    }

    return (radiansToDegrees(math.atan2(dLong, dPhi)) + 360.0) % 360.0;
  }

  double degreesToRadians(double degrees) {
    return degrees * (math.pi / 180.0);
  }

  double radiansToDegrees(double radians) {
    return radians * (180.0 / math.pi);
  }

  @override
  Widget build(BuildContext context) {
    if (currentLocation == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(),
            SizedBox(
                height:
                    20), // Provides spacing between the indicator and the text
            Text('Fetching Location Information',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              center: currentLocation, // Center on user location
              zoom: 16.0, // Initial zoom level is set here
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: markers,
              ),
            ],
          ),
          Positioned(
            top: 20,
            left: MediaQuery.of(context).size.width / 2 -
                25, // Center horizontally
            child: currentBearing != null
                ? Transform.rotate(
                    angle: degreesToRadians(currentBearing!),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(
                                0.5), // Adjust the color and opacity to get the desired glow effect
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: const Offset(0, 0), // changes position of shadow
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_upward,
                          color: Colors.black,
                          size: 50,
                          semanticLabel: 'Nearest fitness center'),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          if (nearestDistance != null)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                color: Colors.white,
                child: Text(
                  'Nearest fitness center is ${nearestDistance!.toStringAsFixed(0)} meters away',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
