import 'package:flutter/material.dart';
import '../models/trip_model.dart';
import '../models/route_model.dart';
import '../models/promo_model.dart';
import 'seat_selection_screen.dart';

class DetailScreen extends StatelessWidget {
  final Trip trip;
  final Promo? promo;

  const DetailScreen({super.key, required this.trip, this.promo});

  @override
  Widget build(BuildContext context) {
    final String finalPrice = promo != null 
        ? Promo.calculateDiscountedPrice(trip.price, promo!.discount)
        : trip.price;

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        trip.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (promo != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "Promo ${promo!.discount}",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        finalPrice,
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (promo != null) ...[
                        const SizedBox(width: 12),
                        Text(
                          trip.price,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    "Description",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    promo != null ? promo!.description : "Enjoy a wonderful trip with our premium travel package. Includes transportation, meals, and guided tours.",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final now = DateTime.now();
                        final route = TravelRoute(
                          id: 'trip-${trip.title.hashCode}',
                          fromCity: 'Yogyakarta',
                          toCity: trip.title,
                          date: "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}",
                          departTime: '08:00',
                          arriveTime: '18:00',
                          price: finalPrice,
                          seatsAvailable: 19,
                          isWisata: true,
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


