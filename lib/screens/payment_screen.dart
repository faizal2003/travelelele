import 'package:flutter/material.dart';
import '../models/route_model.dart';
import '../services/booking_service.dart';
import 'ticket_screen.dart';

class PaymentScreen extends StatefulWidget {
  final TravelRoute route;
  final List<int> selectedSeats;
  final List<String> passengerNames;
  final List<String> passengerPhones;

  const PaymentScreen({
    super.key,
    required this.route,
    required this.selectedSeats,
    required this.passengerNames,
    required this.passengerPhones,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final BookingService _bookingService = BookingService();
  bool _isLoading = false;

  void _processPayment(int totalPrice) async {
    setState(() => _isLoading = true);

    try {
      await _bookingService.createBooking(
        route: widget.route,
        selectedSeats: widget.selectedSeats,
        passengerNames: widget.passengerNames,
        passengerPhones: widget.passengerPhones,
        totalPrice: totalPrice,
      );

      if (!mounted) return;

      // Show animated success card
      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: Opacity(
            opacity: anim1.value,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 80,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Pemesanan Berhasil!",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Tiket Anda telah berhasil diterbitkan.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                        _navigateToTicket();
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Lihat Tiket"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToTicket() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => TicketScreen(
          route: widget.route,
          selectedSeats: widget.selectedSeats,
          passengerNames: widget.passengerNames,
        ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Parse price string "Rp 100.000" -> 100000
    int pricePerSeat = int.parse(widget.route.price.replaceAll(RegExp(r'[^0-9]'), ''));
    int totalPrice = pricePerSeat * widget.selectedSeats.length;

    return Scaffold(
      appBar: AppBar(title: const Text("Pembayaran QRIS")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Booking untuk ${widget.selectedSeats.length} Kursi",
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
                  onPressed: _isLoading ? null : () => _processPayment(totalPrice),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text("Saya Sudah Bayar"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
