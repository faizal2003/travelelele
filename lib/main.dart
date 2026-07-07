import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Core
import 'package:intl/date_symbol_data_local.dart';
import 'screens/splash_screen.dart';

void main() async {
  //fungsi main
  WidgetsFlutterBinding.ensureInitialized(); // Diperlukan untuk async
  await Firebase.initializeApp(); // menginisiasi firebase
  await initializeDateFormatting('id_ID', null);
  runApp(const SmartTravelApp()); //menjalankan aplikasi Flutter
}

class SmartTravelApp extends StatelessWidget {
  //kelas
  const SmartTravelApp({super.key});

  @override
  Widget build(BuildContext context) {
    //fungsi
    return MaterialApp(
      title: 'PEMESANAN TIKET',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'PlusJakartaSans',
        primaryColor: const Color(0xFF154c79),
        scaffoldBackgroundColor: const Color(0xFFF5F6F8), //latbel aplikasi
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF154c79),
        ), //
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          //button
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF154c79),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
      home: const SplashScreen(), //Menentukan halaman pertama yang ditampilkan
    );
  }
}
