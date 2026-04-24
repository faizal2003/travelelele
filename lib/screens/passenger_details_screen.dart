import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/route_model.dart';
import '../services/auth_service.dart';
import 'payment_screen.dart';
//detail kursi penumpang
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
    for (int i = 0; i < widget.selectedSeats.length; i++) { //looping
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
  //data pengguna
  Future<void> _loadUserData() async {
    try {
      final userStream = _authService.getUserStream();
      final snapshot = await userStream.first; //mengambil data user yg login

      if (snapshot.exists) {
        //ambil data pengguna
        final data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          //memastikan data yang sudah ada "nama dan telf" diisi otomatis ke form sebelum melanjutkan proses selanjutnya.
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

  //validasi data pengguna, dan pesan kesalahan
  void _proceedToPayment() {
    String? errorMessage;

    for (int i = 0; i < widget.selectedSeats.length; i++) {
      String name = _nameControllers[i].text.trim();
      String phone = _phoneControllers[i].text.trim();

      if (name.isEmpty || phone.isEmpty) {
        errorMessage = "Mohon lengkapi semua data penumpang";
        break;
      }

      if (name.length < 3) {
        errorMessage = "Nama penumpang ${i + 1} terlalu pendek (min 3 karakter)";
        break;
      }

      if (phone.length < 10 || phone.length > 13) {
        errorMessage = "Nomor telepon penumpang ${i + 1} tidak valid (10-13 digit)";
        break;
      }
    }
    //pesan error
    if (errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
      return;
    }

    //ambil data diteruskan ke pembayaran
    List<String> names = _nameControllers.map((c) => c.text.trim()).toList();
    List<String> phones = _phoneControllers.map((c) => c.text.trim()).toList();

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

  //tampilan halaman data penumpang
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
                //tampilan daftar kursi ui
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
                        //informasi nomor penumpang dan kursi
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
                            //kolom input nama
                            const SizedBox(height: 16),
                            TextField(
                              controller: _nameControllers[index],
                              decoration: const InputDecoration(
                                labelText: "Nama Lengkap",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person),
                                hintText: "Contoh: Budi Santoso",
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                              ],
                              textCapitalization: TextCapitalization.words,
                            ),
                            //kolom input nomor telf
                            const SizedBox(height: 16),
                            TextField(
                              controller: _phoneControllers[index],
                              decoration: const InputDecoration(
                                labelText: "Nomor Telepon",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.phone),
                                hintText: "Contoh: 081234567890",
                              ),
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(13),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                //lanjut pembayaran
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
  //detail rute atas
  Widget _buildRouteSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      //rute darimana ke mana
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
          //kursi yang dipilih
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
