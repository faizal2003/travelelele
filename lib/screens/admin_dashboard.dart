import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        children: [
          _adminMenu(Icons.map, "Kelola Destinasi", Colors.orange),
          _adminMenu(Icons.directions_bus, "Kelola Armada", Colors.blue),
          _adminMenu(Icons.attach_money, "Kelola Harga", Colors.green),
          _adminMenu(Icons.bar_chart, "Laporan Keuangan", Colors.purple),
        ],
      ),
    );
  }

  Widget _adminMenu(IconData icon, String title, Color color) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: () {},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}