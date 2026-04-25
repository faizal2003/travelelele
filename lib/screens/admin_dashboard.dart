import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'destination_management_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  //fungsi logout
  void _logout(BuildContext context) async {
    final AuthService authService = AuthService();
    await authService.signOut();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
//tampilan pada admin
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text("Admin Panel"),
        centerTitle: true,
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      //Konten utama halaman yang dalam SingleChildScrollView, memungkinkan tampilan untuk digulirkan ketika konten melebihi ruang layar.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Selamat Datang, Admin",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Kelola operasional travel dan wisata Anda di sini.",
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),

            //GridView.count: Mengatur tampilan item dalam grid (2 kolom)
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _adminMenu(Icons.map, "Kelola\nDestinasi", Colors.orange, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DestinationManagementScreen(),
                    ),
                  );
                }),
                _adminMenu(Icons.directions_bus, "Kelola\nArmada", Colors.blue, () {}),
                _adminMenu(Icons.attach_money, "Kelola\nHarga", Colors.green, () {}),
                _adminMenu(Icons.bar_chart, "Laporan\nKeuangan", Colors.purple, () {}),
                _adminMenu(Icons.people, "Kelola\nPengguna", Colors.red, () {}),
                _adminMenu(Icons.settings, "Pengaturan\nSistem", Colors.grey, () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }

//Fungsi untuk membuat tampilan menu dalam bentuk kartu.
  Widget _adminMenu(IconData icon, String title, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
     //material design
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 32, color: color),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
