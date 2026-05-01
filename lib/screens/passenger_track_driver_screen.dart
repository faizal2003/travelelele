import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PassengerTrackDriverScreen extends StatelessWidget {
  final String driverId;
  const PassengerTrackDriverScreen({super.key, required this.driverId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lacak Driver"),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('driver_locations').doc(driverId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Driver belum mengaktifkan lokasi"));
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;
          double lat = data['latitude'];
          double lng = data['longitude'];
          LatLng driverPos = LatLng(lat, lng);

          return FlutterMap(
            options: MapOptions(
              initialCenter: driverPos,
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.travelelele',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: driverPos,
                    width: 80,
                    height: 80,
                    child: const Icon(
                      Icons.directions_bus,
                      color: Colors.blue,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
