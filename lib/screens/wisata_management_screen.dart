import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/trip_model.dart';
import '../services/trip_service.dart';

class WisataManagementScreen extends StatefulWidget {
  const WisataManagementScreen({super.key});

  @override
  State<WisataManagementScreen> createState() => _WisataManagementScreenState();
}

class _WisataManagementScreenState extends State<WisataManagementScreen> {
  final TripService _tripService = TripService();

  String _formatRupiah(String value) {
    if (value.isEmpty) return "Rp 0";
    String digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return "Rp 0";
    final number = int.parse(digits);
    String formatted = number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return "Rp $formatted";
  }

  void _showTripDialog({Trip? trip}) {
    final titleController = TextEditingController(text: trip?.title);
    final imageController = TextEditingController(text: trip?.image);
    final priceController = TextEditingController(text: trip?.price.replaceAll(RegExp(r'[^0-9]'), ''));
    bool isFeatured = trip?.isFeatured ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(trip == null ? "Tambah Paket Wisata" : "Edit Paket Wisata"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: "Judul Wisata")),
                TextField(controller: imageController, decoration: const InputDecoration(labelText: "URL Gambar")),
                TextField(
                  controller: priceController, 
                  decoration: const InputDecoration(labelText: "Harga (e.g. 300000)", prefixText: "Rp "),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                SwitchListTile(
                  title: const Text("Tampilkan di Carousel (Featured)"),
                  value: isFeatured,
                  onChanged: (val) => setDialogState(() => isFeatured = val),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
            ElevatedButton(
              onPressed: () {
                final newTrip = Trip(
                  id: trip?.id ?? '',
                  title: titleController.text,
                  image: imageController.text,
                  price: _formatRupiah(priceController.text),
                  isFeatured: isFeatured,
                );

                if (trip == null) {
                  _tripService.addTrip(newTrip);
                } else {
                  _tripService.updateTrip(newTrip);
                }
                Navigator.pop(context);
              },
              child: const Text("Simpan"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kelola Wisata"),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Trip>>(
        stream: _tripService.getTrips(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final trips = snapshot.data ?? [];
          if (trips.isEmpty) {
            return const Center(child: Text("Belum ada data wisata."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: trips.length,
            itemBuilder: (context, index) {
              final trip = trips[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      trip.image,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                    ),
                  ),
                  title: Text(trip.title),
                  subtitle: Text("${trip.price}\n${trip.isFeatured ? '★ Featured' : 'Reguler'}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showTripDialog(trip: trip)),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _tripService.deleteTrip(trip.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTripDialog(),
        backgroundColor: Colors.red[700],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
