import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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
  
  bool _isInitializing = true;
  bool _isProcessing = false;
  String? _bookingId;
  
  // Timer untuk waktu kedaluwarsa
  Timer? _timer;
  int _start = 900; // 15 minutes

  @override
  void initState() {
    super.initState();
    _startBookingProcess();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startBookingProcess() async {
    int pricePerSeat = int.parse(widget.route.price.replaceAll(RegExp(r'[^0-9]'), ''));
    int totalPrice = pricePerSeat * widget.selectedSeats.length;

    try {
      final bookingId = await _bookingService.createBooking(
        route: widget.route,
        selectedSeats: widget.selectedSeats,
        passengerNames: widget.passengerNames,
        passengerPhones: widget.passengerPhones,
        totalPrice: totalPrice,
        status: 'pending',
      );

      if (mounted) {
        setState(() {
          _bookingId = bookingId;
          _isInitializing = false;
        });
        _startTimer();
        _redirectToWhatsApp();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Terjadi kesalahan: $e"), backgroundColor: Colors.red),
        );
        Navigator.pop(context);
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() => timer.cancel());
      } else {
        setState(() => _start--);
      }
    });
  }

  Future<void> _redirectToWhatsApp() async {
    int pricePerSeat = int.parse(widget.route.price.replaceAll(RegExp(r'[^0-9]'), ''));
    int totalPrice = pricePerSeat * widget.selectedSeats.length;
    
    final String phoneNumber = "6281230888425";
    final String message = "Halo Admin, saya ingin melakukan pembayaran untuk pemesanan tiket.\n\n"
        "ID Pesanan: $_bookingId\n"
        "Total Pembayaran: Rp $totalPrice\n"
        "Rute: ${widget.route.fromCity} - ${widget.route.toCity}\n\n"
        "Mohon instruksi selanjutnya.";
        
    final Uri url = Uri.parse("https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}");
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal membuka WhatsApp"), backgroundColor: Colors.red),
        );
      }
    }
  }

  String get _timerDisplay {
    int minutes = _start ~/ 60;
    int seconds = _start % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  Future<void> _handlePayment() async {
    if (_bookingId == null) return;
    
    setState(() => _isProcessing = true);
    
    try {
      await _bookingService.updateBookingStatus(_bookingId!, 'paid');
      _timer?.cancel();
      _showSuccessDialog();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memproses pembayaran: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showSuccessDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 16),
            const Text("Pembayaran Berhasil!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("Terima kasih, pembayaran Anda telah kami terima.", textAlign: TextAlign.center),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _navigateToTicket();
                },
                child: const Text("Lihat Tiket"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToTicket() {
    if (_bookingId == null) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => TicketScreen(
          route: widget.route,
          selectedSeats: widget.selectedSeats,
          passengerNames: widget.passengerNames,
          ticketId: _bookingId!,
        ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    int pricePerSeat = int.parse(widget.route.price.replaceAll(RegExp(r'[^0-9]'), ''));
    int totalPrice = pricePerSeat * widget.selectedSeats.length;

    return Scaffold(
      appBar: AppBar(title: const Text("Pembayaran")),
      body: _isInitializing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Menyiapkan pembayaran..."),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Kartu Ringkasan Pesanan
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                    ),
                    child: Column(
                      children: [
                        const Text("Total Pembayaran", style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 8),
                        Text(
                          "Rp ${totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.orange),
                        ),
                        const Divider(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Batas Waktu", style: TextStyle(color: Colors.grey)),
                            Text(_timerDisplay, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Bagian Tombol Pembayaran
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                    ),
                    child: Column(
                      children: [
                        const Text("SVARGADWIPA", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                        const SizedBox(height: 24),
                        const Text(
                          "Silakan selesaikan pembayaran Anda",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isProcessing ? null : _handlePayment,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isProcessing
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text(
                                    "Saya Sudah Bayar",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Batal & Kembali", style: TextStyle(color: Colors.grey)),
                  ),
                ],
              ),
            ),
    );
  }
}
