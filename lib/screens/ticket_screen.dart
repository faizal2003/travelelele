import 'package:flutter/material.dart';
import '../models/route_model.dart';
import 'home_screen.dart';

class TicketScreen extends StatelessWidget {
  final TravelRoute route;
  final List<int> selectedSeats;
  final List<String> passengerNames;

  const TicketScreen({
    super.key,
    required this.route,
    required this.selectedSeats,
    required this.passengerNames,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("E-Tiket"),
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "Smart Travel Booking",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const Divider(height: 30),
                  _buildTicketRow("Penumpang", passengerNames.join(", ")),
                  _buildTicketRow(
                    "Rute",
                    "${route.fromCity} - ${route.toCity}",
                  ),
                  _buildTicketRow(
                    "Jadwal",
                    "${route.departTime} - ${route.arriveTime}",
                  ),
                  _buildTicketRow("Kursi", selectedSeats.join(", ")),
                  const Divider(height: 30),
                  const Icon(Icons.qr_code, size: 120),
                  const SizedBox(height: 10),
                  const Text(
                    "Scan Masuk Gate",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Share ticket logic would go here
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text("Download Tiket"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Flexible(
            child: Text(
              value, 
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
