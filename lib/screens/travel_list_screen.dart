import 'package:flutter/material.dart';
import '../models/trip_model.dart';
import '../services/trip_service.dart';
import 'detail_screen.dart';

class TravelListScreen extends StatelessWidget {
  const TravelListScreen({super.key});

//travel
  @override
  Widget build(BuildContext context) {
    final TripService tripService = TripService();

    return Scaffold(
      body: StreamBuilder<List<Trip>>(
        stream: tripService.getTrips(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final tripsList = snapshot.data ?? [];
          
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    "Paket Wisata",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                    ),
                  ),
                  //mengatur gambar latar belakang di halaman dengan Image.mengambil gambar dari URL
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        "https://images.unsplash.com/photo-1506744038136-46273834b3fb",
                        fit: BoxFit.cover,
                      ),
                      //gradasi gambar
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              //padding
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: tripsList.isEmpty 
                  ? const SliverFillRemaining(child: Center(child: Text("Belum ada paket wisata tersedia.")))
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final trip = tripsList[index];
                          return _buildTripCard(context, trip);
                        },
                        childCount: tripsList.length,
                      ),
                    ),
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildTripCard(BuildContext context, Trip trip) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailScreen(trip: trip)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //melengkung pada gambar atas bagian wisata
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                trip.image,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            //menampilkan rating wisata
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        trip.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  //menampilkan harga perjalanan
                  const SizedBox(height: 8),
                  Text(
                    trip.price,
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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