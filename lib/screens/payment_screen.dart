import 'package:flutter/material.dart';
import 'ticket_screen.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pembayaran QRIS")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Scan QRIS untuk Bayar",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
              const Text("Total: Rp 300.000",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange)),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const TicketScreen()),
                        (route) => false,
                  ),
                  child: const Text("Saya Sudah Bayar"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}