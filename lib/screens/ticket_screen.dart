import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:gal/gal.dart';
import '../models/route_model.dart';
import 'home_screen.dart';

class TicketScreen extends StatefulWidget {
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
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  final GlobalKey _ticketKey = GlobalKey();
  bool _isSaving = false;

  Future<void> _downloadTicket() async {
    setState(() => _isSaving = true);
    try {
      // Periksa izin akses galeri
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final request = await Gal.requestAccess();
        if (!request) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Akses galeri ditolak", style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
            );
            setState(() => _isSaving = false);
          }
          return;
        }
      }

      // Pastikan widget sudah selesai dirender
      await Future.delayed(const Duration(milliseconds: 100));

      // Render widget ke bentuk gambar
      RenderRepaintBoundary boundary = _ticketKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData != null) {
        Uint8List pngBytes = byteData.buffer.asUint8List();
        
        // Simpan ke galeri menggunakan package gal
        await Gal.putImageBytes(pngBytes, name: 'SVARGADWIPA_Ticket_${widget.ticketId}');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Tiket berhasil disimpan ke Galeri!", style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menyimpan tiket: $e", style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

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
            RepaintBoundary(
              key: _ticketKey,
              child: Container(
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
                    _buildTicketRow("ID Tiket", widget.ticketId),
                    _buildTicketRow("Penumpang", widget.passengerNames.join(", ")),
                    _buildTicketRow(
                      "Rute",
                      "${widget.route.fromCity} - ${widget.route.toCity}",
                    ),
                    _buildTicketRow("Tanggal", widget.route.date),
                    _buildTicketRow(
                      "Jadwal",
                      "${widget.route.departTime} - ${widget.route.arriveTime}",
                    ),
                    _buildTicketRow("Kursi", widget.selectedSeats.join(", ")),
                    const Divider(height: 30),
                    QrImageView(
                      data: widget.ticketId,
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
            ),
            //tombol download tiket
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _downloadTicket,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: _isSaving 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Download Tiket", style: TextStyle(color: Colors.white)),
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
