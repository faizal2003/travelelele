import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:gal/gal.dart';
import '../models/route_model.dart';
import '../services/booking_service.dart';
import '../services/midtrans_service.dart';
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
  final MidtransService _midtransService = MidtransService();
  
  bool _isInitializing = true;
  String? _bookingId;
  String? _qrisImageUrl;
  StreamSubscription? _bookingSubscription;
  Timer? _statusTimer; // Polling timer
  
  // Timer untuk waktu kedaluwarsa QRIS
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
    _statusTimer?.cancel();
    _bookingSubscription?.cancel();
    super.dispose();
  }

  bool _isDownloadingQris = false;

  Future<void> _downloadQris() async {
    if (_qrisImageUrl == null) return;
    setState(() => _isDownloadingQris = true);
    
    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final request = await Gal.requestAccess();
        if (!request) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Akses galeri ditolak", style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
            );
            setState(() => _isDownloadingQris = false);
          }
          return;
        }
      }

      final response = await http.get(Uri.parse(_qrisImageUrl!));
      if (response.statusCode == 200) {
        await Gal.putImageBytes(response.bodyBytes, name: 'SVARGADWIPA_QRIS_${_bookingId}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("QRIS berhasil disimpan ke Galeri!", style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
          );
        }
      } else {
        throw Exception("Gagal mengunduh gambar");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menyimpan QRIS: $e", style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloadingQris = false);
    }
  }

  void _startBookingProcess() async {
    int pricePerSeat = int.parse(widget.route.price.replaceAll(RegExp(r'[^0-9]'), ''));
    int totalPrice = pricePerSeat * widget.selectedSeats.length;

    try {
      // 1. Buat pesanan dengan status 'pending' terlebih dahulu untuk mendapatkan ID Pesanan yang stabil (menggunakan ID dokumen)
      final bookingId = await _bookingService.createBooking(
        route: widget.route,
        selectedSeats: widget.selectedSeats,
        passengerNames: widget.passengerNames,
        passengerPhones: widget.passengerPhones,
        totalPrice: totalPrice,
        status: 'pending',
      );

      setState(() => _bookingId = bookingId);

      // 2. Meminta URL Gambar QRIS dari backend menggunakan bookingId sebagai ID Pesanan
      final imageUrl = await _midtransService.getQrisImageUrl(
        orderId: bookingId,
        grossAmount: totalPrice,
      );

      if (mounted) {
        setState(() {
          _qrisImageUrl = imageUrl;
          _isInitializing = false;
        });
        if (_qrisImageUrl != null) {
          _startTimer();
          _listenToBookingStatus(bookingId);
        }
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

  // 3. Memantau pembaruan dari Webhook di Firestore & Melakukan Polling ke Midtrans
  void _listenToBookingStatus(String bookingId) {
    // Lakukan polling langsung ke Midtrans untuk memeriksa perubahan status transaksi
    _statusTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      final status = await _midtransService.checkStatus(bookingId);
      
      if (status == 'settlement' || status == 'capture') {
        timer.cancel();
        _bookingSubscription?.cancel();
        await _bookingService.updateBookingStatus(bookingId, 'paid');
        _showSuccessDialog();
      } else if (status == 'expire' || status == 'cancel' || status == 'deny') {
        timer.cancel();
        _bookingSubscription?.cancel();
        await _bookingService.updateBookingStatus(bookingId, status);
        _showFailureDialog(status);
      }
    });

    _bookingSubscription = _bookingService.getBookingStream(bookingId).listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        final status = data['status'];

        if (status == 'paid') {
          _statusTimer?.cancel();
          _bookingSubscription?.cancel();
          _showSuccessDialog();
        } else if (status == 'expire' || status == 'cancel') {
          _statusTimer?.cancel();
          _bookingSubscription?.cancel();
          _showFailureDialog(status);
        }
      }
    });
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

  String get _timerDisplay {
    int minutes = _start ~/ 60;
    int seconds = _start % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
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

  void _showFailureDialog(String status) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Pembayaran ${status == 'expire' ? 'Kadaluarsa' : 'Dibatalkan'}"),
        content: const Text("Silakan lakukan pemesanan ulang."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
        ],
      ),
    ).then((_) => Navigator.pop(context));
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
      appBar: AppBar(title: const Text("Pembayaran QRIS")),
      body: _isInitializing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text("Menyiapkan pembayaran..."),
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
                  
                  // Bagian Gambar QRIS
                  if (_qrisImageUrl != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                      ),
                      child: Column(
                        children: [
                          const Text("SVARGADWIPA", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                          const SizedBox(height: 16),
                          Image.network(
                            _qrisImageUrl!,
                            height: 280,
                            width: 280,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.qr_code_scanner, size: 200, color: Colors.grey),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const SizedBox(height: 280, width: 280, child: Center(child: CircularProgressIndicator()));
                            },
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _isDownloadingQris ? null : _downloadQris,
                            icon: _isDownloadingQris 
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Icon(Icons.download, size: 18),
                            label: const Text("Simpan QRIS"),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade50,
                                foregroundColor: Colors.blue.shade700,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Menunggu pembayaran...",
                            style: TextStyle(fontSize: 14, color: Colors.blue, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Halaman ini akan otomatis diperbarui\nsetelah pembayaran Anda terverifikasi.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11, color: Colors.grey),
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


