import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/route_model.dart';
import 'home_screen.dart';

class TicketScreen extends StatelessWidget {
  final TravelRoute route;
  final List<int> selectedSeats;
  final List<String> passengerNames;
  final String ticketId;

//menampilkan tiket perjalanan
  const TicketScreen({
    super.key,
    required this.route,
    required this.selectedSeats,
    required this.passengerNames,
    required this.ticketId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("E-Tiket"), //judul e tiket
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          ),
        ),
      ), //ui container
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
              //form detail booking
              child: Column(
                children: [
                  const Text(
                    "Detail Tiket",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const Divider(height: 30),
                  _buildTicketRow("ID Tiket", ticketId),
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
                  QrImageView(
                    data: ticketId,
                    version: QrVersions.auto,
                    size: 150.0,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Scan Masuk Gate",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            //tombol download tiket
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
  //membuat baris yang menampilkan informasi, seperti label dan nilai, di halaman tiket.
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
