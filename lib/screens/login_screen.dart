import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// IMPORT FILE HALAMAN LAIN
import 'registration_screen.dart'; // Halaman Daftar
import 'home_screen.dart'; // Halaman User Biasa
import 'admin_home_screen.dart'; // Halaman Admin (Baru)

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Key untuk Validasi Form
  final _formKey = GlobalKey<FormState>();

  // Controller Input Text
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Status Loading
  bool _isLoading = false;

  // --- KONFIGURASI API ---
  // Gunakan 10.0.2.2 jika pakai Emulator Android Studio
  // Gunakan IP Laptop (misal 192.168.1.XX) jika pakai HP Fisik
  // Pastikan Port 8081 (sesuai settingan XAMPP kamu)
  final String _baseUrl =  'http://10.0.2.2:8081/car_cemeng_api/login.php';

  // Warna Tema Aplikasi
  static const Color primaryPurple = Color(0xFF673AB7);
  static const Color darkNavy = Color(0xFF1A1C4F);
  static const Color accentYellow = Color(0xFFFFC107);

  @override
  void dispose() {
    // Bersihkan memori controller saat halaman ditutup
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- FUNGSI LOGIN ---
  Future<void> _loginUser() async {
    // 1. Validasi Input (Gak boleh kosong)
    if (!_formKey.currentState!.validate()) return;

    // 2. Tampilkan Loading
    setState(() => _isLoading = true);

    try {
      // 3. Kirim Data ke Backend
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          // WAJIB: Tambahkan User-Agent agar tidak diblokir InfinityFree
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
        body: jsonEncode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      print("Response API: ${response.body}"); // Cek error di Debug Console

      final data = jsonDecode(response.body);

      // 4. Cek Hasil Login
      if (response.statusCode == 200 && data['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Login Berhasil!"),
              backgroundColor: Colors.green,
            ),
          );

          // --- LOGIKA PEMISAH ADMIN VS USER ---
          // Ambil data user lengkap (termasuk role)
          Map<String, dynamic> userData = data['user'];
          String role =
              userData['role'] ?? 'user'; // Default ke 'user' jika null

          if (role == 'admin') {
            // Arahkan ke Halaman Admin
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => AdminHomeScreen(user: userData),
              ),
            );
          } else {
            // Arahkan ke Halaman User Biasa
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => HomeScreen(user: userData),
              ),
            );
          }
        }
      } else {
        // Jika Password/Email Salah
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? "Login Gagal"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Jika Error Koneksi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal koneksi. Cek XAMPP & IP.\nError: $e"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      // Matikan Loading
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- TAMPILAN UI ---
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Lengkungan Ungu di Atas
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: size.height * 0.4,
              decoration: const BoxDecoration(
                color: primaryPurple,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
            ),
          ),

          // 2. Konten Tengah (Logo & Form)
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 80, bottom: 40),
              child: Column(
                children: [
                  // Logo Lingkaran
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: primaryPurple,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'CAR',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                          Text(
                            'CEMENG',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Card Putih Login
                  Container(
                    width: size.width * 0.85,
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Masuk Aplikasi',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: darkNavy,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Input Email
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDeco('Email', Icons.email),
                            validator: (val) =>
                                val!.isEmpty ? 'Email wajib diisi' : null,
                          ),
                          const SizedBox(height: 15),

                          // Input Password
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: _inputDeco('Password', Icons.lock),
                            validator: (val) =>
                                val!.isEmpty ? 'Password wajib diisi' : null,
                          ),
                          const SizedBox(height: 25),

                          // Tombol Masuk
                          ElevatedButton(
                            onPressed: _isLoading ? null : _loginUser,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentYellow,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: darkNavy,
                                    ),
                                  )
                                : const Text(
                                    'MASUK',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: darkNavy,
                                    ),
                                  ),
                          ),

                          const SizedBox(height: 15),

                          // Link ke Register
                          TextButton(
                            onPressed: () {
                              // Navigasi ke halaman Register
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const RegistrationScreen(),
                                ),
                              );
                            },
                            child: const Text('Belum punya akun? Daftar'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper untuk Desain Input
  InputDecoration _inputDeco(String label, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: primaryPurple),
      hintText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
    );
  }
}
