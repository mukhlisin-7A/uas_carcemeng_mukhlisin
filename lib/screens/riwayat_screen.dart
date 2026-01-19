import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

// IMPORT HALAMAN DETAIL
import 'detail_riwayat_screen.dart';

class RiwayatScreen extends StatefulWidget {
  final Map<String, dynamic>? user;

  const RiwayatScreen({super.key, this.user});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  List _riwayatList = [];
  bool _isLoading = true;

  // CONFIG API (Sesuaikan IP dengan laptopmu)
  final String _baseUrl =  'http://10.0.2.2:8081/car_cemeng_api/';

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _fetchRiwayat();
    }
  }

  // --- AMBIL DATA RIWAYAT ---
  Future<void> _fetchRiwayat() async {
    try {
      final response = await http.get(
        Uri.parse('${_baseUrl}get_riwayat.php?id_user=${widget.user!['id']}'),
        // TAMBAHKAN HEADERS DI SINI
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _riwayatList = data['data'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error ambil riwayat: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

 // --- FUNGSI BATALKAN PESANAN ---
  Future<void> _cancelOrder(String idSewa) async {
    try {
      final response = await http.post(
        Uri.parse('${_baseUrl}cancel_booking.php'),
        // TAMBAHKAN HEADERS DI SINI
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
        body: {'id_sewa': idSewa},
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Pesanan berhasil dibatalkan"),
              backgroundColor: Colors.grey,
            ),
          );
          _fetchRiwayat(); // Refresh data setelah batal
        }
      }
    } catch (e) {
      print("Error cancel: $e");
    }
  }

  void _showCancelDialog(String idSewa) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Batalkan Pesanan?"),
        content: const Text(
          "Apakah Anda yakin ingin membatalkan sewa mobil ini?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Kembali"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _cancelOrder(idSewa);
            },
            child: const Text(
              "Ya, Batalkan",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  String formatRupiah(String price) {
    try {
      final number = double.parse(price);
      return NumberFormat.currency(
        locale: 'id',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(number);
    } catch (e) {
      return "Rp $price";
    }
  }

  String formatDate(String dateStr) {
    try {
      DateTime dt = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Riwayat Transaksi"),
        backgroundColor: const Color(0xFF673AB7),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _fetchRiwayat();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _riwayatList.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _fetchRiwayat,
              child: ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: _riwayatList.length,
                itemBuilder: (context, index) {
                  return _buildHistoryCard(_riwayatList[index]);
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.history, size: 80, color: Colors.grey),
          SizedBox(height: 10),
          Text("Belum ada riwayat sewa", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // --- WIDGET KARTU RIWAYAT ---
  Widget _buildHistoryCard(Map data) {
    String status = data['status'];
    Color statusColor;
    String statusLabel;
    bool canCancel = false;

    // Info Message Optional
    String? infoMessage;
    Color infoColor = Colors.grey;
    IconData infoIcon = Icons.info;

    // --- LOGIKA STATUS SIMPEL ---
    if (status == 'pending') {
      statusColor = Colors.orange;
      statusLabel = "Menunggu Konfirmasi";
      canCancel = true;
    } else if (status == 'konfirmasi') {
      statusColor = Colors.blue;
      statusLabel = "Dikonfirmasi";

      // Pesan cuma buat yang dikonfirmasi/selesai
      infoMessage = "Pesanan disetujui. Silakan ambil unit di kantor.";
      infoColor = Colors.blue;
      infoIcon = Icons.check_circle;
      canCancel = false;
    } else if (status == 'selesai') {
      statusColor = Colors.green;
      statusLabel = "Selesai";

      infoMessage = "Penyewaan selesai. Terima kasih!";
      infoColor = Colors.green;
      infoIcon = Icons.thumb_up;
    } else {
      // STATUS: batal, batal_user, batal_admin
      // Semuanya dianggap "Dibatalkan" dan TIDAK ADA PESAN TAMBAHAN
      statusColor = Colors.red;
      statusLabel = "Dibatalkan";
      infoMessage = null; // Bersih, gak ada pesan
    }

    String? gambarUrl;
    if (data['gambar'] != null && data['gambar'] != "") {
      gambarUrl = '${_baseUrl}uploads/${data['gambar']}';
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailRiwayatScreen(data: data),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
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
            // Header: Tanggal & Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Sewa: ${formatDate(data['tgl_sewa'])}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Body: Info Mobil
            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: gambarUrl != null
                          ? Image.network(
                              gambarUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) =>
                                  const Icon(Icons.broken_image),
                            )
                          : const Icon(Icons.car_rental, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${data['merk']} ${data['model']}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "${data['total_hari']} Hari Sewa",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          formatRupiah(data['total_harga'].toString()),
                          style: const TextStyle(
                            color: Color(0xFF673AB7),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- INFO PESAN TAMBAHAN (Hanya muncul kalau infoMessage != null) ---
            if (infoMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                decoration: BoxDecoration(
                  color: infoColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: infoColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(infoIcon, size: 20, color: infoColor),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        infoMessage,
                        style: TextStyle(
                          fontSize: 12,
                          color: infoColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Footer: Tombol Batal (Hanya muncul jika Pending)
            if (canCancel) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () =>
                          _showCancelDialog(data['id_sewa'].toString()),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        "Batalkan Sewa",
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
