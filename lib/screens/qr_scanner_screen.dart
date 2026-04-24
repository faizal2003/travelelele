import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/booking_service.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  bool _isScanned = false;
  final BookingService _bookingService = BookingService();

  void _onDetect(BarcodeCapture capture) async {
    if (_isScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      if (code != null) {
        setState(() => _isScanned = true);
        _validateTicket(code);
      }
    }
  }

  void _validateTicket(String ticketId) async {
    try {
      final data = await _bookingService.validateAndUseTicket(ticketId);

      if (!mounted) return;

      _showResultDialog(
        success: true,
        ticketId: ticketId,
        passengerName: (data['passengers'] as List?)?.first?['name'] ?? 'Unknown',
        seat: (data['seats'] as List?)?.join(', ') ?? '-',
        route: "${data['fromCity']} → ${data['toCity']}",
      );
    } catch (e) {
      if (!mounted) return;
      _showResultDialog(
        success: false,
        ticketId: ticketId,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void _showResultDialog({
    required bool success,
    required String ticketId,
    String? passengerName,
    String? seat,
    String? route,
    String? error,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error,
              color: success ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(success ? "Check-in Berhasil" : "Check-in Gagal"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: success
              ? [
                  Text("ID: $ticketId", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text("Penumpang: $passengerName", style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text("Seat: $seat"),
                  Text("Rute: $route"),
                  const SizedBox(height: 8),
                  const Text("Status: VALID & DIGUNAKAN", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  const Text("Tiket ini sekarang sudah tidak bisa digunakan lagi.", style: TextStyle(fontSize: 10, color: Colors.grey)),
                ]
              : [
                  Text("ID: $ticketId", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text(error ?? "Tiket tidak valid", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              setState(() => _isScanned = false); // Allow another scan
            },
            child: const Text("Scan Lagi"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close scanner screen
            },
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Tiket"),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: _onDetect,
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Arahkan kamera ke QR Code tiket",
                style: TextStyle(color: Colors.white, backgroundColor: Colors.black54),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
