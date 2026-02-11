import 'package:flutter/material.dart';
import 'payment_screen.dart';

class SeatSelectionScreen extends StatefulWidget {
  const SeatSelectionScreen({super.key});

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  // Simple 4x4 grid state. 0=Available, 1=Selected, 2=Booked
  List<int> seats = [0, 0, 2, 0, 0, 1, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pilih Kursi")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildLegend(),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: seats.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      if (seats[index] == 2) return; // Booked
                      setState(() {
                        seats[index] = seats[index] == 0 ? 1 : 0;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: _getSeatColor(seats[index]),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Center(
                          child: Icon(
                            Icons.chair,
                            color:
                            seats[index] == 1 ? Colors.white : Colors.grey[600],
                          )),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const PaymentScreen())),
                child: const Text("Lanjut ke Pembayaran"),
              ),
            )
          ],
        ),
      ),
    );
  }

  Color _getSeatColor(int status) {
    if (status == 2) return Colors.grey[300]!; // Booked
    if (status == 1) return const Color(0xFF154c79); // Selected
    return Colors.white; // Available
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _legendItem(Colors.white, "Available"),
        _legendItem(const Color(0xFF154c79), "Selected"),
        _legendItem(Colors.grey[300]!, "Booked"),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey))),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}