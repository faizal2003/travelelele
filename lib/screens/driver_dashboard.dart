import 'package:flutter/material.dart';

class DriverDashboard extends StatelessWidget {
  const DriverDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Driver Dashboard")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.qr_code_scanner, size: 100, color: Colors.blue),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Simulate Scanning
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Scan Result"),
                    content: const Text("Penumpang: Budi Santoso\nSeat: B3\nStatus: Valid"),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))
                    ],
                  ),
                );
              },
              child: const Text("Scan Tiket Penumpang"),
            ),
          ],
        ),
      ),
    );
  }
}