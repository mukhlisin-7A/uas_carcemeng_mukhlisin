import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class AdminPesananScreen extends StatefulWidget {
  const AdminPesananScreen({super.key});

  @override
  State<AdminPesananScreen> createState() => _AdminPesananScreenState();
}

class _AdminPesananScreenState extends State<AdminPesananScreen> {
  List _orders = [];
  bool _isLoading = true;

  // CONFIG API (Sesuaikan IP)
  final String _baseUrl =  'http://10.0.2.2:8081/car_cemeng_api/';

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

 // --- AMBIL DATA PESANAN AKTIF ---
  Future<void> _fetchOrders() async {
    try {
      final response = await http.get(
        Uri.parse('${_baseUrl}get_all_pesanan.php'),
        // Tambahkan header untuk InfinityFree
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // FILTER: Cuma ambil yang Pending (Menunggu) & Konfirmasi (Sedang Jalan)
        List activeOrders = (data['data'] as List).where((item) {
          return item['status'] == 'pending' || item['status'] == 'konfirmasi';
        }).toList();

        if (mounted) {
          setState(() {
            _orders = activeOrders;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error fetch orders: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- UPDATE STATUS (TERIMA / TOLAK / SELESAI) ---
  Future<void> _updateStatus(String idSewa, String newStatus) async {
    // Tampilkan loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Panggil API update_status_pesanan.php
      final response = await http.post(
        Uri.parse('${_baseUrl}update_status_pesanan.php'),
        // Tambahkan header untuk InfinityFree
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
        body: {'id_sewa': idSewa, 'status': newStatus},
      );

      if (!mounted) return;
      Navigator.pop(context); // Tutup loading

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Status berhasil diubah ke: ${newStatus.toUpperCase()}"),
            backgroundColor: newStatus == 'batal_admin' ? Colors.red : Colors.green,
          ),
        );
        _fetchOrders(); // Refresh data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal: ${data['message']}"))
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      print("Error update: $e");
    }
  }

  // Helper Format Rupiah
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

  // Helper Format Tanggal
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
        title: const Text("Pesanan Aktif"),
        backgroundColor: const Color(0xFF673AB7),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _fetchOrders();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: Colors.green,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Tidak ada pesanan aktif",
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    "Semua pekerjaan beres!",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchOrders,
              child: ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  return _buildOrderCard(_orders[index]);
                },
              ),
            ),
    );
  }

  Widget _buildOrderCard(Map data) {
    String status = data['status'];
    Color statusColor = status == 'pending' ? Colors.orange : Colors.blue;
    String statusLabel = status == 'pending'
        ? "Menunggu Konfirmasi"
        : "Sedang Disewa";

    String? gambarUrl;
    if (data['gambar'] != null && data['gambar'] != "") {
      gambarUrl = '${_baseUrl}uploads/${data['gambar']}';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          // HEADER: Status & Tanggal
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Order #${data['id_sewa']}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                Text(
                  statusLabel.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar Mobil
                Container(
                  width: 80,
                  height: 80,
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
                // Info Detail
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
                        "Penyewa: ${data['username']}",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        "HP: ${data['phone']}",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${formatDate(data['tgl_sewa'])} - ${formatDate(data['tgl_kembali'])}",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${data['total_hari']} Hari | Total: ${formatRupiah(data['total_harga'].toString())}",
                        style: const TextStyle(
                          fontSize: 12,
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

          // FOOTER: Tombol Aksi (Hanya muncul jika status Pending/Konfirmasi)
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                // Tombol TOLAK / BATAL
                Expanded(
                  child: OutlinedButton.icon(
                    // PENTING: Statusnya 'batal_admin'
                    onPressed: () => _updateStatus(
                      data['id_sewa'].toString(),
                      'batal_admin',
                    ),
                    icon: const Icon(Icons.cancel, color: Colors.red, size: 18),
                    label: const Text(
                      "Tolak",
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Tombol TERIMA / SELESAI
                if (status == 'pending')
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus(
                        data['id_sewa'].toString(),
                        'konfirmasi',
                      ),
                      icon: const Icon(Icons.check_circle, size: 18),
                      label: const Text("Terima"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  )
                else if (status == 'konfirmasi')
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _updateStatus(data['id_sewa'].toString(), 'selesai'),
                      icon: const Icon(Icons.flag, size: 18),
                      label: const Text("Selesaikan"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
