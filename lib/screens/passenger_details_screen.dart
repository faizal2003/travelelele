import 'package:flutter/material.dart';

import '../models/route_model.dart';
import '../services/auth_service.dart';
import 'payment_screen.dart';

class PassengerDetailsScreen extends StatefulWidget {
  final TravelRoute route;
  final List<int> selectedSeats;

  const PassengerDetailsScreen({
    super.key,
    required this.route,
    required this.selectedSeats,
  });

  @override
  State<PassengerDetailsScreen> createState() => _PassengerDetailsScreenState();
}

class _PassengerDetailsScreenState extends State<PassengerDetailsScreen> {
  final List<TextEditingController> _nameControllers = [];
  final List<TextEditingController> _phoneControllers = [];
  final AuthService _authService = AuthService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Initialize controllers for each seat
    for (int i = 0; i < widget.selectedSeats.length; i++) {
      _nameControllers.add(TextEditingController());
      _phoneControllers.add(TextEditingController());
    }
    _loadUserData();
  }

  @override
  void dispose() {
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    for (var controller in _phoneControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final userStream = _authService.getUserStream();
      final snapshot = await userStream.first; // Get current state exactly once for pre-fill

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          // Pre-fill only the first passenger's info
          if (_nameControllers.isNotEmpty) {
            _nameControllers[0].text = data['name'] ?? '';
            _phoneControllers[0].text = data['phone'] ?? '';
          }
        });
      }
    } catch (e) {
      debugPrint("Error loading user data: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _proceedToPayment() {
    bool allValid = true;

    for (int i = 0; i < widget.selectedSeats.length; i++) {
      if (_nameControllers[i].text.isEmpty || _phoneControllers[i].text.isEmpty) {
        allValid = false;
        break;
      }
    }

    if (!allValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mohon lengkapi semua data penumpang")),
      );
      return;
    }

    List<String> names = _nameControllers.map((c) => c.text).toList();
    List<String> phones = _phoneControllers.map((c) => c.text).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          route: widget.route,
          selectedSeats: widget.selectedSeats,
          passengerNames: names,
          passengerPhones: phones,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Data Penumpang")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: _buildRouteSummary(),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    itemCount: widget.selectedSeats.length,
                    itemBuilder: (context, index) {
                      int seatNumber = widget.selectedSeats[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Penumpang ${index + 1} (Kursi $seatNumber)",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _nameControllers[index],
                              decoration: const InputDecoration(
                                labelText: "Nama Lengkap",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _phoneControllers[index],
                              decoration: const InputDecoration(
                                labelText: "Nomor Telepon",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.phone),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _proceedToPayment,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text("Lanjut ke Pembayaran"),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildRouteSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.route.fromCity,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
              Text(
                widget.route.toCity,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Kursi: ${widget.selectedSeats.join(', ')}"),
              Text(
                widget.route.price,
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
