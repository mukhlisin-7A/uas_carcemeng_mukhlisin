import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'form_mobil_screen.dart'; // Pastikan file form ada

class KelolaMobilScreen extends StatefulWidget {
  const KelolaMobilScreen({super.key});

  @override
  State<KelolaMobilScreen> createState() => _KelolaMobilScreenState();
}

class _KelolaMobilScreenState extends State<KelolaMobilScreen> {
  List _listMobil = [];
  bool _isLoading = true;

  // Sesuaikan IP Address
  // Emulator: 10.0.2.2
  // HP Fisik: 192.168.1.XX
  final String _baseUrl =  'http://10.0.2.2:8081/car_cemeng_api/';

  @override
  void initState() {
    super.initState();
    _getDataMobil();
  }

 // --- AMBIL DATA ---
  Future<void> _getDataMobil() async {
    try {
      final response = await http.get(
        Uri.parse(
          '${_baseUrl}read_mobil.php?t=${DateTime.now().millisecondsSinceEpoch}',
        ),
        // TAMBAHKAN HEADERS DI SINI
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _listMobil = data['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error ambil data: $e");
      setState(() => _isLoading = false);
    }
  }

// --- FUNGSI HAPUS MOBIL ---
  Future<void> _deleteMobil(String idMobil) async {
    try {
      final response = await http.post(
        Uri.parse('${_baseUrl}delete_mobil.php'),
        // TAMBAHKAN HEADERS DI SINI
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
        body: {'id_mobil': idMobil},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Mobil berhasil dihapus"),
                backgroundColor: Colors.green,
              ),
            );
          }
          _getDataMobil();
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
      }
    } catch (e) {
      print("Error hapus: $e");
    }
  }

  // --- DIALOG KONFIRMASI HAPUS ---
  void _confirmDelete(String idMobil, String namaMobil) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Hapus Mobil?"),
          content: Text(
            "Anda yakin ingin menghapus data '$namaMobil'? Data yang dihapus tidak bisa dikembalikan.",
          ),
          actions: [
            TextButton(
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text(
                "Hapus",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
                _deleteMobil(idMobil); // Jalankan fungsi hapus
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kelola Mobil"),
        backgroundColor: const Color(0xFF673AB7),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _getDataMobil();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _listMobil.isEmpty
          ? const Center(child: Text("Belum ada data mobil"))
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _listMobil.length,
              itemBuilder: (context, index) {
                final mobil = _listMobil[index];

                // Construct URL Gambar
                String? gambarUrl;
                if (mobil['gambar'] != null && mobil['gambar'] != "") {
                  gambarUrl = '${_baseUrl}uploads/${mobil['gambar']}';
                }

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    // GAMBAR
                    leading: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: gambarUrl != null
                            ? Image.network(
                                gambarUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, stack) => const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                              )
                            : const Icon(
                                Icons.car_rental,
                                size: 40,
                                color: Colors.grey,
                              ),
                      ),
                    ),

                    // DETAIL TEXT
                    title: Text(
                      "${mobil['merk']} ${mobil['model']}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Text("Plat: ${mobil['nomor_plat']}"),
                        Text(
                          "Rp ${mobil['harga_sewa']} / hari",
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    // TOMBOL AKSI (EDIT & HAPUS)
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min, // Supaya gak makan tempat
                      children: [
                        // Tombol Edit
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    FormMobilScreen(mobil: mobil),
                              ),
                            );
                            _getDataMobil();
                          },
                        ),
                        // Tombol Hapus
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            // Panggil dialog konfirmasi dulu
                            _confirmDelete(
                              mobil['id_mobil'].toString(),
                              mobil['model'],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF673AB7),
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormMobilScreen()),
          );
          _getDataMobil();
        },
      ),
    );
  }
}
