import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'qr_scanner_screen.dart';
import 'driver_map_screen.dart';

class DriverDashboard extends StatelessWidget {
  const DriverDashboard({super.key});
//logout pada driver
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
  
  void _openScanner(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QrScannerScreen()),
    );
  }

  //judul appbar
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text("Driver Panel"),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          //logout button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      //header
      //header bawah melengkung
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue[800],
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              //teks sambutan driver
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Selamat Datang, Driver",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Siap untuk perjalanan hari ini? Tetap utamakan keselamatan.",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),

            // menu utama
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,//2 grid menu
                mainAxisSpacing: 16,//spasi 16 px hori
                crossAxisSpacing: 16,//spasi 16 px verti
                childAspectRatio: 1.1,
                children: [
                  _driverMenu(Icons.qr_code_scanner, "Scan Barcode\nTiket", Colors.blue, () => _openScanner(context)),
                  _driverMenu(Icons.map, "Maps\nPengguna", Colors.teal, () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const DriverMapScreen()));
                  }),
                  _driverMenu(Icons.person, "Profile\nDriver", Colors.indigo, () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
//dasboard
  Widget _driverMenu(IconData icon, String title, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      //kode ui dasboard
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16), //lengkung
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
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}