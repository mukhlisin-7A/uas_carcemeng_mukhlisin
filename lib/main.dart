import 'package:flutter/material.dart';
import 'screens/splash_screen.dart'; // Import halaman awal

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Properti ini digunakan untuk menghilangkan tulisan DEBUG di pojok kanan atas
      debugShowCheckedModeBanner: false,
      title: 'APLIKASI SEWA MOBIL',
      theme: ThemeData(
        // Skema warna utama
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Montserrat',
        useMaterial3: true,
      ),
      // Halaman pertama yang dimuat saat aplikasi dijalankan
      home: const SplashScreen(),
    );
  }
}
