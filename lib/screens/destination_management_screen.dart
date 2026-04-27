import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/route_model.dart';
import '../services/route_service.dart';

class DestinationManagementScreen extends StatefulWidget {
  const DestinationManagementScreen({super.key});

  @override
  State<DestinationManagementScreen> createState() => _DestinationManagementScreenState();
}

class _DestinationManagementScreenState extends State<DestinationManagementScreen> {
  final RouteService _routeService = RouteService();
  final List<String> _cities = ['Madiun', 'Surabaya', 'Yogyakarta', 'Malang'];

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

  void _showRouteDialog({TravelRoute? route}) {
    String? selectedFrom = route?.fromCity;
    String? selectedTo = route?.toCity;
    
    // Ensure initial values are in the list or null
    if (selectedFrom != null && !_cities.contains(selectedFrom)) selectedFrom = null;
    if (selectedTo != null && !_cities.contains(selectedTo)) selectedTo = null;

    final dateController = TextEditingController(text: route?.date);
    final departController = TextEditingController(text: route?.departTime);
    final arriveController = TextEditingController(text: route?.arriveTime);
    // Strip non-digits for numeric input
    final priceController = TextEditingController(text: route?.price.replaceAll(RegExp(r'[^0-9]'), ''));
    bool isWisata = route?.isWisata ?? false;

    Future<void> _selectDate(BuildContext context, TextEditingController controller, StateSetter setDialogState) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2030),
      );
      if (picked != null) {
        final String formattedDate = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        setDialogState(() {
          controller.text = formattedDate;
        });
      }
    }

    Future<void> _selectTime(BuildContext context, TextEditingController controller, StateSetter setDialogState) async {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (picked != null) {
        final String formattedTime = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
        setDialogState(() {
          controller.text = formattedTime;
        });
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(route == null ? "Tambah Destinasi" : "Edit Destinasi"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedFrom,
                  decoration: const InputDecoration(labelText: "Dari Kota"),
                  items: _cities.map((city) => DropdownMenuItem(value: city, child: Text(city))).toList(),
                  onChanged: (val) => setDialogState(() => selectedFrom = val),
                ),
                DropdownButtonFormField<String>(
                  value: selectedTo,
                  decoration: const InputDecoration(labelText: "Ke Kota"),
                  items: _cities.map((city) => DropdownMenuItem(value: city, child: Text(city))).toList(),
                  onChanged: (val) => setDialogState(() => selectedTo = val),
                ),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(labelText: "Tanggal (YYYY-MM-DD)", suffixIcon: Icon(Icons.calendar_today)),
                  readOnly: true,
                  onTap: () => _selectDate(context, dateController, setDialogState),
                ),
                TextField(
                  controller: departController,
                  decoration: const InputDecoration(labelText: "Waktu Berangkat (HH:mm)", suffixIcon: Icon(Icons.access_time)),
                  readOnly: true,
                  onTap: () => _selectTime(context, departController, setDialogState),
                ),
                TextField(
                  controller: arriveController,
                  decoration: const InputDecoration(labelText: "Waktu Tiba (HH:mm)", suffixIcon: Icon(Icons.access_time)),
                  readOnly: true,
                  onTap: () => _selectTime(context, arriveController, setDialogState),
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: "Harga (Contoh: 100000)", prefixText: "Rp "),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
            ElevatedButton(
              onPressed: () {
                if (selectedFrom == null || selectedTo == null || dateController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Pilih kota asal, tujuan, dan tanggal")),
                  );
                  return;
                }
                final newRoute = TravelRoute(
                  id: route?.id ?? '',
                  fromCity: selectedFrom!,
                  toCity: selectedTo!,
                  date: dateController.text,
                  departTime: departController.text,
                  arriveTime: arriveController.text,
                  price: _formatRupiah(priceController.text),
                  seatsAvailable: 19, // Always 19 for Travel
                  isWisata: false, // Always Travel
                );

                if (route == null) {
                  _routeService.addRoute(newRoute);
                } else {
                  _routeService.updateRoute(newRoute);
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
        title: const Text("Kelola Travel"),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<TravelRoute>>(
        stream: _routeService.getRoutes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final routes = snapshot.data ?? [];
          if (routes.isEmpty) {
            return const Center(child: Text("Belum ada destinasi."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: routes.length,
            itemBuilder: (context, index) {
              final route = routes[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text("${route.fromCity} → ${route.toCity}"),
                  subtitle: Text("${route.date} | ${route.departTime} - ${route.arriveTime}\n${route.price} | Kursi: ${route.seatsAvailable} | Travel"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showRouteDialog(route: route)),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _routeService.deleteRoute(route.id),
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
        onPressed: () => _showRouteDialog(),
        backgroundColor: Colors.red[700],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
