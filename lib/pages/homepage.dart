import 'package:flutter/material.dart';
import 'package:fluttermocklocation/fluttermocklocation_platform_interface.dart';
import 'package:fluttermocklocation/mock_location_updates.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  GoogleMapController? _googleMapController;
  LatLng _selectedLocation = const LatLng(36.7783, 119.4179); //defult location

  Set<Marker> _markers = {};
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(36.7783, 119.4179),
    zoom: 14.0,
  );

  void _addMarker(LatLng postion) {
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: MarkerId("selected Loaction"),
          position: postion,
          infoWindow: InfoWindow(
            title: "Location",
            snippet:
                'Lat: ${postion.latitude.toStringAsFixed(6)}, '
                'Lng: ${postion.longitude.toStringAsFixed(6)}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
      _selectedLocation = postion;
    });
  }

  @override
  void initState() {
    super.initState();
    _addMarker(_selectedLocation);
  }

  void _onMapTapped(LatLng position) {
    _addMarker(position);
  }

  void _onMapCreated(GoogleMapController controller) {
    _googleMapController = controller;
  }

  Future<void> _swapLocation(LatLng location) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Location services are disabled. Please enable them in settings.",
            ),
          ),
        );
        return;
      }

      // Check and request location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Locations are disabled. Please enable them in settings.",
              ),
            ),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Locations are disabled forever. Please enable them in settings.",
            ),
          ),
        );
        return;
      }
      //swap with mock location
      await FluttermocklocationPlatform.instance.updateMockLocation(
        location.latitude,
        location.longitude,
        altitude: 0,
        delay: 5000,
      );
      Stream<Map<String, double>> updateLocation =
          MockLocationUpdates.locationStream;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(updateLocation.toString())));
    } catch (err) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Unable to update location")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "GPS Swapper",
          style: TextStyle(color: Colors.black, fontSize: 14),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: _initialPosition,
                onTap: _onMapTapped,
                markers: _markers,
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
                compassEnabled: true,
                mapToolbarEnabled: true,
                zoomControlsEnabled: true,
                mapType: MapType.normal,
              ),
            ),
            //location details
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selected Location:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Latitude: ${_selectedLocation.latitude.toStringAsFixed(6)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Longitude: ${_selectedLocation.longitude.toStringAsFixed(6)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          await _swapLocation(_selectedLocation);
                        },
                        child: Icon(
                          Icons.swap_horiz,
                          size: 28,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
