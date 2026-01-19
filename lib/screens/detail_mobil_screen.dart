import 'package:flutter/material.dart';
import 'booking_screen.dart'; // Wajib import ini buat navigasi ke booking

class DetailMobilScreen extends StatelessWidget {
  final Map<String, dynamic> mobil; // Data mobil
  final Map<String, dynamic> user;  // Data user (PENTING: Ditambahkan)

  const DetailMobilScreen({
    super.key, 
    required this.mobil, 
    required this.user
  });

  // Helper Format Rupiah
  String formatRupiah(String price) {
    try {
      final number = double.parse(price);
      return "Rp ${number.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
    } catch (e) {
      return "Rp $price";
    }
  }

  @override
  Widget build(BuildContext context) {
    // Config URL Gambar (Sesuaikan IP dengan konfigurasi laptopmu)
    const String baseUrl =  'http://10.0.2.2:8081/car_cemeng_api/';
    
    String? gambarUrl;
    if (mobil['gambar'] != null && mobil['gambar'] != "") {
      gambarUrl = '${baseUrl}uploads/${mobil['gambar']}';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Background abu muda
      
      // Menggunakan Stack agar tombol back bisa di atas gambar
      body: Stack(
        children: [
          // 1. GAMBAR HEADER FULL
          Positioned(
            top: 0, left: 0, right: 0,
            height: 300,
            child: gambarUrl != null
                ? Image.network(
                    gambarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(color: Colors.grey, child: const Icon(Icons.broken_image)),
                  )
                : Container(color: Colors.grey[300], child: const Icon(Icons.car_rental, size: 80, color: Colors.grey)),
          ),

          // 2. TOMBOL BACK & FAVORITE (Overlay)
          Positioned(
            top: 40, left: 20, right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCircleButton(context, Icons.arrow_back, onTap: () => Navigator.pop(context)),
                _buildCircleButton(context, Icons.favorite_border, onTap: () {}),
              ],
            ),
          ),

          // 3. KONTEN DETAIL (Sheet Putih Lengkung)
          Positioned.fill(
            top: 270, // Overlap sedikit dengan gambar
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Garis kecil di tengah atas (hiasan)
                  Center(
                    child: Container(
                      width: 50, height: 5,
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Judul & Harga
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${mobil['merk']} ${mobil['model']}",
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 18),
                                const SizedBox(width: 5),
                                Text("4.8 (Review)", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            formatRupiah(mobil['harga_sewa'].toString()),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF673AB7)),
                          ),
                          const Text("/hari", style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // Grid Spesifikasi
                  const Text("Spesifikasi", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSpecItem(Icons.speed, "Transmisi", mobil['transmisi'] ?? '-'),
                      _buildSpecItem(Icons.local_gas_station, "Bahan Bakar", mobil['bahan_bakar'] ?? '-'),
                      _buildSpecItem(Icons.airline_seat_recline_normal, "Kursi", "${mobil['jumlah_kursi']} Seat"),
                      _buildSpecItem(Icons.calendar_today, "Tahun", mobil['tahun_buat'].toString()),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // Deskripsi Scrollable
                  const Text("Deskripsi Mobil", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        mobil['deskripsi'] ?? "Tidak ada deskripsi tersedia.",
                        style: const TextStyle(color: Colors.grey, height: 1.5),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // 4. TOMBOL SEWA SEKARANG (Fixed Bottom)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF673AB7),
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 5,
          ),
          onPressed: () {
            // PERBAIKAN: Kirim data mobil DAN user ke BookingScreen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookingScreen(
                  mobil: mobil, 
                  user: user, // <--- Ini yang penting biar ga error
                ),
              ),
            );
          },
          child: const Text(
            "SEWA SEKARANG",
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
        ),
      ),
    );
  }

  // --- Widget Kecil: Tombol Bulat (Back/Love) ---
  Widget _buildCircleButton(BuildContext context, IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        child: Icon(icon, color: Colors.black87, size: 20),
      ),
    );
  }

  // --- Widget Kecil: Kotak Spesifikasi ---
  Widget _buildSpecItem(IconData icon, String label, String value) {
    return Container(
      width: 75,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF673AB7), size: 24),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
        ],
      ),
    );
  }
}