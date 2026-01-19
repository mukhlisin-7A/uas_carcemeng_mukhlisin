import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class KontakScreen extends StatefulWidget {
  // Kita butuh data user (ID) untuk kirim pesan
  final Map<String, dynamic>? user;

  const KontakScreen({super.key, this.user});

  @override
  State<KontakScreen> createState() => _KontakScreenState();
}

class _KontakScreenState extends State<KontakScreen> {
  final TextEditingController _msgController = TextEditingController();
  List _chatList = [];
  bool _isLoading = true;

  // CONFIG API (Sesuaikan IP dengan laptopmu)
  // Emulator: 10.0.2.2 | HP Fisik: 192.168.1.XX
  final String _baseUrl = 'http://10.0.2.2:8081/car_cemeng_api/';

  @override
  void initState() {
    super.initState();
    // Cek jika user ada, baru ambil pesan. Jika tidak, matikan loading.
    if (widget.user != null) {
      _fetchMessages();
      _markAsRead(); // <--- PENTING: Tandai pesan sudah dibaca saat halaman dibuka
    } else {
      setState(() => _isLoading = false);
    }
  }

 // --- FUNGSI BARU: TANDAI SUDAH DIBACA ---
  Future<void> _markAsRead() async {
    try {
      await http.post(
        Uri.parse('${_baseUrl}mark_read.php'),
        // TAMBAHKAN HEADERS DI SINI
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
        body: {'id_user': widget.user!['id'].toString()},
      );
      print("Pesan ditandai sudah dibaca.");
    } catch (e) {
      print("Gagal mark read: $e");
    }
  }

  // --- AMBIL DATA PESAN ---
  Future<void> _fetchMessages() async {
    try {
      final response = await http.get(
        Uri.parse('${_baseUrl}get_pesan.php?id_user=${widget.user!['id']}'),
        // TAMBAHKAN HEADERS DI SINI
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _chatList = data['data'];
          });
        }
      } else {
        print("Gagal ambil pesan: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetch pesan: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal memuat pesan: $e"),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      // PENTING: Loading harus berhenti apapun yang terjadi
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- KIRIM PESAN (FIXED JSON) ---
  Future<void> _sendMessage() async {
    if (_msgController.text.isEmpty) return;

    String pesan = _msgController.text;

    // Debug: Pastikan ID User ada
    if (widget.user == null || widget.user!['id'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error: User ID tidak ditemukan. Login ulang."),
        ),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${_baseUrl}kirim_pesan.php'),
        // GABUNGKAN HEADERS DI SINI
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
        // Tetap gunakan jsonEncode untuk body
        body: jsonEncode({
          'id_user': widget.user!['id'], 
          'isi_pesan': pesan
        }),
      );

      print("Response Kirim: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          _msgController.clear(); // Bersihkan input jika sukses
          _fetchMessages(); // Refresh daftar chat
        } else {
          // Tampilkan pesan error dari PHP
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Gagal: ${data['message']}"),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      print("Error kirim: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error koneksi: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Layanan Pelanggan"),
        backgroundColor: const Color(0xFF673AB7),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _fetchMessages();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. INFO KONTAK LENGKAP
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildContactRow(
                  Icons.chat,
                  "WhatsApp Admin",
                  "082133515128",
                  Colors.green,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(height: 1),
                ),
                _buildContactRow(
                  Icons.email,
                  "Email Support",
                  "carcemeng@gmail.com",
                  Colors.orange,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(height: 1),
                ),
                _buildContactRow(
                  Icons.location_on,
                  "Alamat Kantor",
                  "Jl. Jenderal Sudirman No. Kav 50, Jakarta Pusat",
                  Colors.blue,
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 2. LIST CHAT (AREA PESAN)
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _chatList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 60,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Belum ada pesan. Tanyakan sesuatu!",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount: _chatList.length,
                    itemBuilder: (context, index) {
                      final chat = _chatList[index];
                      return Column(
                        children: [
                          // Bubble User (Kanan)
                          _buildChatBubble(
                            chat['isi_pesan'],
                            true,
                            chat['waktu_kirim'],
                          ),

                          // Bubble Admin (Kiri - Cuma muncul kalau sudah dibalas)
                          if (chat['balasan_admin'] != null)
                            _buildChatBubble(
                              chat['balasan_admin'],
                              false,
                              chat['waktu_balas'] ?? "Baru saja",
                            ),
                        ],
                      );
                    },
                  ),
          ),

          // 3. INPUT FIELD (BAWAH)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: InputDecoration(
                      hintText: "Tulis pesan ke admin...",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: const Color(0xFF673AB7),
                  radius: 22,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET: Baris Informasi Kontak
  Widget _buildContactRow(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget Bubble Chat
  Widget _buildChatBubble(String text, bool isUser, String time) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF673AB7) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: isUser ? const Radius.circular(15) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(15),
          ),
          boxShadow: [
            if (!isUser)
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser)
              const Text(
                "Admin Support",
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),

            Text(
              text,
              style: TextStyle(color: isUser ? Colors.white : Colors.black87),
            ),
            const SizedBox(height: 3),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                _formatTime(time),
                style: TextStyle(
                  fontSize: 10,
                  color: isUser ? Colors.white70 : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String dateTime) {
    try {
      DateTime dt = DateTime.parse(dateTime);
      return DateFormat('HH:mm').format(dt);
    } catch (e) {
      return "";
    }
  }
}
