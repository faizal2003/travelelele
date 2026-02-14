import 'package:flutter/material.dart';
import '../models/trip_model.dart';
import '../models/route_model.dart';
import 'seat_selection_screen.dart';

class DetailScreen extends StatelessWidget {
  final Trip trip;
  const DetailScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(trip.title)),
      body: Column(
        children: [
          Image.network(
            trip.image,
            height: 250,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    trip.price,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Description",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Enjoy a wonderful trip with our premium travel package. Includes transportation, meals, and guided tours.",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Create a dummy route from the trip details
                        final route = TravelRoute(
                          id: 'trip-${trip.title.hashCode}',
                          fromCity: 'Jakarta', // Default
                          toCity: trip.title,
                          departTime: '08:00',
                          arriveTime: '18:00',
                          price: trip.price,
                          seatsAvailable: 20,
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SeatSelectionScreen(route: route),
                          ),
                        );
                      },
                      child: const Text("Pilih Kursi"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
