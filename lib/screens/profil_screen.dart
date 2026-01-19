import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilScreen extends StatefulWidget {
  // Terima data lengkap user (Map)
  final Map<String, dynamic> user;

  const ProfilScreen({super.key, required this.user});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _locController; // Untuk Alamat
  late TextEditingController _phoneController;
  late TextEditingController _passController;

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // URL API Update Profile (Ganti IP sesuai device)
  final String _apiUrl =
       'http://10.0.2.2:8081/car_cemeng_api/update_profile.php';

  @override
  void initState() {
    super.initState();
    // 1. ISI DATA OTOMATIS DARI DATABASE (Login -> Home -> Profil)
    _nameController = TextEditingController(text: widget.user['username']);
    _emailController = TextEditingController(text: widget.user['email']);
    _locController = TextEditingController(text: widget.user['address'] ?? "");
    _phoneController = TextEditingController(text: widget.user['phone'] ?? "");
    _passController = TextEditingController(); // Password kosong defaultnya
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _locController.dispose();
    _phoneController.dispose();
    _passController.dispose();
    super.dispose();
  }

  // FUNGSI UPDATE PROFIL KE DATABASE
  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);

   try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          // WAJIB: Tambahkan User-Agent untuk hosting InfinityFree
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
        body: jsonEncode({
          'id': widget.user['id'], 
          'username': _nameController.text,
          'email': _emailController.text,
          'address': _locController.text,
          'phone': _phoneController.text,
          'password': _passController.text, 
        }),
      );
      
      // ... lanjutkan dengan pengecekan response.body dan jsonDecode

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Data berhasil diperbarui!"),
              backgroundColor: Colors.green,
            ),
          );
          // Update data di widget biar tampilan langsung berubah
          setState(() {
            widget.user['username'] = _nameController.text;
            widget.user['email'] = _emailController.text;
            widget.user['address'] = _locController.text;
            widget.user['phone'] = _phoneController.text;
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Gagal: ${data['message']}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error koneksi: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // BACKGROUND GRADIENT
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8E54E9), Color(0xFF4776E6)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
          ),
          // Hiasan Bulat
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 100,
            right: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // FOTO PROFIL (DIGANTI ICON ORANG)
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white, // Background putih biar bersih
                      borderRadius: BorderRadius.circular(25),
                      // border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person, // Logo Orang
                      size: 60,
                      color: Color(0xFF673AB7), // Warna Ungu
                    ),
                  ),
                  const SizedBox(height: 15),

                  // NAMA & EMAIL HEADER
                  Text(
                    _nameController.text.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    _emailController.text,
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),

                  const SizedBox(height: 40),

                  // FORM INPUT
                  _buildTextField(
                    controller: _nameController,
                    icon: Icons.person_outline,
                    hint: "Nama Lengkap",
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    controller: _emailController,
                    icon: Icons.email_outlined,
                    hint: "Alamat Email",
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    controller: _locController,
                    icon: Icons.location_on_outlined,
                    hint: "Alamat / Lokasi",
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    controller: _phoneController,
                    icon: Icons.phone_android_outlined,
                    hint: "Nomor HP",
                    inputType: TextInputType.phone,
                  ),
                  const SizedBox(height: 15),

                  // Password Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: _passController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: Colors.grey,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () => setState(
                            () => _isPasswordVisible = !_isPasswordVisible,
                          ),
                        ),
                        hintText: "Ubah Password (Opsional)",
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // TOMBOL SIMPAN PERUBAHAN
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.orange, // Warna beda buat simpan
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                      onPressed: _isLoading ? null : _updateProfile,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "SIMPAN PERUBAHAN",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // TOMBOL KELUAR
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D1B42),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "KELUAR",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextInputType inputType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
      ),
    );
  }
}
