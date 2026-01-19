import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddAdminScreen extends StatefulWidget {
  const AddAdminScreen({super.key});

  @override
  State<AddAdminScreen> createState() => _AddAdminScreenState();
}

class _AddAdminScreenState extends State<AddAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers untuk input text
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addrController = TextEditingController();

  bool _isLoading = false;
  
  // CONFIG API (Sesuaikan IP dengan konfigurasi laptopmu)
  // Emulator: 10.0.2.2
  // HP Fisik: 192.168.1.XX
  final String _baseUrl = 'http://10.0.2.2/car_cemeng_api/';

  @override
  void dispose() {
    // Bersihkan controller saat halaman ditutup
    _nameController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _phoneController.dispose();
    _addrController.dispose();
    super.dispose();
  }

  // Fungsi Tambah Admin
  Future<void> _submitAdmin() async {
    // 1. Cek validasi form
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 2. Kirim data ke Backend
      final response = await http.post(
        Uri.parse('${_baseUrl}add_admin.php'),
        headers: {
  'Content-Type': 'application/json',
  'User-Agent': 'Mozilla/5.0 ...' // Ini nilai User-Agent-nya
},
        body: jsonEncode({
          'username': _nameController.text,
          'email': _emailController.text,
          'password': _passController.text,
          'phone': _phoneController.text,
          'address': _addrController.text,
        }),
      );

      print("Response: ${response.body}"); // Debugging

      final data = jsonDecode(response.body);

      // 3. Cek hasil respon
      if (response.statusCode == 200 && data['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Admin Berhasil Ditambahkan!"), 
              backgroundColor: Colors.green
            ),
          );
          Navigator.pop(context); // Kembali ke halaman dashboard admin
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? "Gagal menambahkan admin"), 
              backgroundColor: Colors.red
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error koneksi: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Tambah Admin Baru"),
        backgroundColor: const Color(0xFF673AB7),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Header Icon
              const Icon(Icons.admin_panel_settings, size: 80, color: Color(0xFF673AB7)),
              const SizedBox(height: 10),
              const Text(
                "Buat Akun Pengelola Baru",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              // Form Input
              _buildTextField("Username", _nameController, Icons.person),
              const SizedBox(height: 15),
              _buildTextField("Email", _emailController, Icons.email, type: TextInputType.emailAddress),
              const SizedBox(height: 15),
              _buildTextField("Password", _passController, Icons.lock, isObscure: true),
              const SizedBox(height: 15),
              _buildTextField("No. Handphone", _phoneController, Icons.phone, type: TextInputType.phone),
              const SizedBox(height: 15),
              _buildTextField("Alamat", _addrController, Icons.home),
              
              const SizedBox(height: 40),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF673AB7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                  ),
                  onPressed: _isLoading ? null : _submitAdmin,
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "SIMPAN ADMIN", 
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Helper untuk Text Field yang rapi
  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool isObscure = false, TextInputType type = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF673AB7)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (val) => val!.isEmpty ? '$label wajib diisi' : null,
    );
  }
}