import 'package:flutter/material.dart';
import 'login_screen.dart'; // Pastikan file ini ada
import 'dart:convert'; // Untuk decode JSON
import 'package:http/http.dart' as http; // Wajib: flutter pub add http

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controller untuk input text (Sekarang sudah lengkap 5 data)
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController =
      TextEditingController(); // Baru
  final TextEditingController _addressController =
      TextEditingController(); // Baru
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  // --- KONFIGURASI API ---
  // Ganti '192.168.x.x' dengan IP Laptopmu jika pakai HP asli.
  // Ganti '10.0.2.2' jika pakai Emulator Android Studio.
  // Pastikan port 8081 sesuai dengan settingan Apache kamu.
  // Pastikan nama folder 'car_cemeng_api' sesuai dengan nama folder di htdocs.
  final String _baseUrl =  'http://10.0.2.2:8081/car_cemeng_api/register.php';

  // Warna Utama
  static const Color primaryPurple = Color(0xFF673AB7);
  static const Color darkNavy = Color(0xFF1A1C4F);
  static const Color accentYellow = Color(0xFFFFC107);

  @override
  void dispose() {
    // Bersihkan controller saat halaman ditutup
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

   try {
      print("Mengirim data ke: $_baseUrl"); // Debugging URL

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          // WAJIB: Tambahkan User-Agent agar tidak diblokir sistem keamanan hosting
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
        body: jsonEncode({
          'username': _usernameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text, 
          'address': _addressController.text, 
          'password': _passwordController.text,
        }),
      );

      // ... lanjutkan dengan pengecekan response (jsonDecode)

      print("Response status: ${response.statusCode}"); // Debugging
      print("Response body: ${response.body}"); // Debugging

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Registrasi Sukses
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                data['message'] ?? "Registrasi Berhasil! Silakan Login.",
              ),
              backgroundColor: Colors.green,
            ),
          );

          // Pindah ke Halaman Login agar user bisa masuk
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      } else {
        // Gagal (Misal email sudah ada)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? "Gagal Mendaftar"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error koneksi: $e. Cek IP & Port XAMPP."),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Latar Belakang Ungu
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

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 60, bottom: 40),
              child: Column(
                children: [
                  // Logo (Agar konsisten dengan Login)
                  Container(
                    width: 90,
                    height: 90,
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
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            'CEMENG',
                            style: TextStyle(color: Colors.white, fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Card Form Register
                  Container(
                    width: size.width * 0.85,
                    padding: const EdgeInsets.all(25),
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
                            'Buat Akun Baru',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: darkNavy,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 1. Input Username
                          TextFormField(
                            controller: _usernameController,
                            decoration: _inputDeco('Username', Icons.person),
                            validator: (val) =>
                                val!.isEmpty ? 'Username wajib diisi' : null,
                          ),
                          const SizedBox(height: 15),

                          // 2. Input Email
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDeco('Email', Icons.email),
                            validator: (val) => !val!.contains('@')
                                ? 'Format email salah'
                                : null,
                          ),
                          const SizedBox(height: 15),

                          // 3. Input No HP (Baru)
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: _inputDeco(
                              'No. Handphone',
                              Icons.phone_android,
                            ),
                            validator: (val) =>
                                val!.isEmpty ? 'No HP wajib diisi' : null,
                          ),
                          const SizedBox(height: 15),

                          // 4. Input Alamat (Baru)
                          TextFormField(
                            controller: _addressController,
                            keyboardType: TextInputType.streetAddress,
                            maxLines: 2, // Biar agak tinggi
                            decoration: _inputDeco(
                              'Alamat Lengkap',
                              Icons.home,
                            ),
                            validator: (val) =>
                                val!.isEmpty ? 'Alamat wajib diisi' : null,
                          ),
                          const SizedBox(height: 15),

                          // 5. Input Password
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: _inputDeco('Password', Icons.lock),
                            validator: (val) => val!.length < 6
                                ? 'Password minimal 6 karakter'
                                : null,
                          ),
                          const SizedBox(height: 30),

                          // Tombol Daftar
                          ElevatedButton(
                            onPressed: _isLoading ? null : _registerUser,
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
                                    'DAFTAR SEKARANG',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: darkNavy,
                                    ),
                                  ),
                          ),

                          const SizedBox(height: 15),

                          // Link ke Login
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            child: const Text('Sudah punya akun? Login'),
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

  InputDecoration _inputDeco(String label, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: primaryPurple),
      labelText: label, // Ubah hintText jadi labelText biar lebih rapi
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      alignLabelWithHint:
          true, // Biar label alamat ada di atas (karena multiline)
    );
  }
}
