import 'package:flutter/material.dart';
import '../models/route_model.dart';
import 'ticket_screen.dart';

class PaymentScreen extends StatelessWidget {
  final TravelRoute route;
  final List<int> selectedSeats;
  final String passengerName;
  final String passengerPhone;

  const PaymentScreen({
    super.key,
    required this.route,
    required this.selectedSeats,
    required this.passengerName,
    required this.passengerPhone,
  });

  @override
  Widget build(BuildContext context) {
    // Parse price string "Rp 100.000" -> 100000
    int pricePerSeat = int.parse(route.price.replaceAll(RegExp(r'[^0-9]'), ''));
    int totalPrice = pricePerSeat * selectedSeats.length;

    return Scaffold(
      appBar: AppBar(title: const Text("Pembayaran QRIS")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Booking untuk ${selectedSeats.length} Kursi",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              const Text(
                "Scan QRIS untuk Bayar",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Container(
                height: 250,
                width: 250,
                color: Colors.white,
                child: const Center(
                  child: Icon(Icons.qr_code_2, size: 200, color: Colors.black),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Total: Rp ${totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TicketScreen(
                        route: route,
                        selectedSeats: selectedSeats,
                        passengerName: passengerName,
                      ),
                    ),
                    (route) => false,
                  ),
                  child: const Text("Saya Sudah Bayar"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
