import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailRiwayatScreen extends StatelessWidget {
  final Map data; // Data riwayat yang dikirim dari halaman sebelumnya

  const DetailRiwayatScreen({super.key, required this.data});

  // Helper Format Rupiah
  String formatRupiah(String price) {
    try {
      final number = double.parse(price);
      return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(number);
    } catch (e) {
      return "Rp $price";
    }
  }

  // Helper Format Tanggal
  String formatDate(String dateStr) {
    try {
      DateTime dt = DateTime.parse(dateStr);
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(dt); // Butuh inisialisasi locale id kalau mau bahasa indo, default inggris
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Config URL Gambar
    const String baseUrl =  'http://10.0.2.2:8081/car_cemeng_api/';
    
    // Warna Status
    Color statusColor = Colors.grey;
    String statusText = data['status'];
    if (statusText == 'pending') { statusColor = Colors.orange; statusText = "Menunggu Konfirmasi"; }
    else if (statusText == 'konfirmasi') { statusColor = Colors.blue; statusText = "Sedang Berjalan"; }
    else if (statusText == 'selesai') { statusColor = Colors.green; statusText = "Selesai"; }
    else if (statusText == 'batal') { statusColor = Colors.red; statusText = "Dibatalkan"; }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Detail Pesanan"),
        backgroundColor: const Color(0xFF673AB7),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // KARTU UTAMA (INVOICE STYLE)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15, offset: const Offset(0, 5))],
              ),
              child: Column(
                children: [
                  // HEADER STATUS
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Column(
                      children: [
                        Text("Status Pesanan", style: TextStyle(color: statusColor, fontSize: 12)),
                        const SizedBox(height: 5),
                        Text(
                          statusText.toUpperCase(),
                          style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // FOTO MOBIL
                        Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(15),
                            image: (data['gambar'] != null && data['gambar'] != "")
                                ? DecorationImage(
                                    image: NetworkImage('${baseUrl}uploads/${data['gambar']}'),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: (data['gambar'] == null) ? const Icon(Icons.car_rental, size: 50, color: Colors.grey) : null,
                        ),
                        const SizedBox(height: 20),

                        // NAMA MOBIL
                        Text(
                          "${data['merk']} ${data['model']}",
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          data['nomor_plat'] ?? "-",
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 10),

                        // DETAIL TANGGAL
                        _buildRowDetail("Tanggal Sewa", formatDate(data['tgl_sewa'])),
                        const SizedBox(height: 10),
                        _buildRowDetail("Tanggal Kembali", formatDate(data['tgl_kembali'])),
                        const SizedBox(height: 10),
                        _buildRowDetail("Durasi", "${data['total_hari']} Hari"),
                        
                        const SizedBox(height: 10),
                        const Divider(),
                        const SizedBox(height: 10),

                        // TOTAL HARGA
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Total Bayar", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text(
                              formatRupiah(data['total_harga'].toString()),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF673AB7)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // INFO TAMBAHAN
            if (data['status'] == 'pending')
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline, color: Colors.orange),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Mohon tunggu admin mengkonfirmasi pesanan Anda. Silakan datang ke kantor untuk pengambilan kunci.",
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRowDetail(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}