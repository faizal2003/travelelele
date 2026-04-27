import 'package:flutter/material.dart';
import '../models/promo_model.dart';
import '../models/trip_model.dart';
import '../services/promo_service.dart';
import '../services/trip_service.dart';

class PromoManagementScreen extends StatefulWidget {
  const PromoManagementScreen({super.key});

  @override
  State<PromoManagementScreen> createState() => _PromoManagementScreenState();
}

class _PromoManagementScreenState extends State<PromoManagementScreen> {
  final PromoService _promoService = PromoService();
  final TripService _tripService = TripService();

  void _showPromoDialog({Promo? promo}) {
    final titleController = TextEditingController(text: promo?.title);
    final imageController = TextEditingController(text: promo?.image);
    final descController = TextEditingController(text: promo?.description);
    final discountController = TextEditingController(text: promo?.discount);
    String? selectedWisataId = promo?.wisataId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(promo == null ? "Tambah Promo" : "Edit Promo"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                StreamBuilder<List<Trip>>(
                  stream: _tripService.getTrips(),
                  builder: (context, snapshot) {
                    final trips = snapshot.data ?? [];
                    return DropdownButtonFormField<String?>(
                      value: selectedWisataId,
                      decoration: const InputDecoration(labelText: "Pilih Wisata (Opsional)"),
                      hint: const Text("Gunakan Wisata Tersedia"),
                      items: [
                        const DropdownMenuItem<String?>(value: null, child: Text("Manual (Tanpa Link)")),
                        ...trips.map((t) => DropdownMenuItem<String?>(value: t.id, child: Text(t.title))),
                      ],
                      onChanged: (val) {
                        setDialogState(() {
                          selectedWisataId = val;
                          if (val != null) {
                            final selected = trips.firstWhere((t) => t.id == val);
                            titleController.text = selected.title;
                            imageController.text = selected.image;
                            descController.text = "Promo Spesial untuk ${selected.title}!";
                          }
                        });
                      },
                    );
                  },
                ),
                const Divider(),
                TextField(controller: titleController, decoration: const InputDecoration(labelText: "Judul Promo")),
                TextField(controller: imageController, decoration: const InputDecoration(labelText: "URL Gambar")),
                TextField(controller: descController, decoration: const InputDecoration(labelText: "Deskripsi")),
                TextField(controller: discountController, decoration: const InputDecoration(labelText: "Diskon (e.g. 50%)")),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
            ElevatedButton(
              onPressed: () {
                final newPromo = Promo(
                  id: promo?.id ?? '',
                  title: titleController.text,
                  image: imageController.text,
                  description: descController.text,
                  discount: discountController.text,
                  wisataId: selectedWisataId,
                );

                if (promo == null) {
                  _promoService.addPromo(newPromo);
                } else {
                  _promoService.updatePromo(newPromo);
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
        title: const Text("Kelola Promo"),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Promo>>(
        stream: _promoService.getPromos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final promos = snapshot.data ?? [];
          if (promos.isEmpty) {
            return const Center(child: Text("Belum ada data promo."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: promos.length,
            itemBuilder: (context, index) {
              final promo = promos[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      promo.image,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                    ),
                  ),
                  title: Text(promo.title),
                  subtitle: Text("Diskon: ${promo.discount}\n${promo.description}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showPromoDialog(promo: promo)),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _promoService.deletePromo(promo.id),
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
        onPressed: () => _showPromoDialog(),
        backgroundColor: Colors.red[700],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
