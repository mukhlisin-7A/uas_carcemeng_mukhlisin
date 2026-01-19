import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // Wajib: flutter pub add intl

class AdminLaporanScreen extends StatefulWidget {
  const AdminLaporanScreen({super.key});

  @override
  State<AdminLaporanScreen> createState() => _AdminLaporanScreenState();
}

class _AdminLaporanScreenState extends State<AdminLaporanScreen> {
  bool _isLoading = true;
  
  // Data Default (0 semua)
  Map _stats = {
    "pendapatan": 0,
    "total_selesai": 0,
    "total_proses": 0,
    "total_pending": 0,
    "total_batal": 0
  };

  // CONFIG API (Ganti IP sesuai device)
 final String _baseUrl =  'http://10.0.2.2:8081/car_cemeng_api/';
  @override
  void initState() {
    super.initState();
    _fetchLaporan();
  }

 Future<void> _fetchLaporan() async {
    try {
      final response = await http.get(
        Uri.parse('${_baseUrl}get_laporan.php'),
        // Tambahkan header User-Agent untuk InfinityFree
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _stats = data['data'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error fetch laporan: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Format Rupiah
  String formatRupiah(var number) {
    try {
      double val = double.parse(number.toString());
      return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(val);
    } catch (e) {
      return "Rp 0";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Laporan Keuangan"),
        backgroundColor: const Color(0xFF673AB7),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchLaporan,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Ringkasan Bisnis", 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(height: 15),

                    // 1. KARTU PENDAPATAN (BESAR)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF673AB7), Color(0xFF512DA8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.purple.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Total Pendapatan Bersih", 
                            style: TextStyle(color: Colors.white70, fontSize: 14)
                          ),
                          const SizedBox(height: 10),
                          Text(
                            formatRupiah(_stats['pendapatan']),
                            style: const TextStyle(
                              color: Colors.white, 
                              fontSize: 30, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "*Dihitung dari pesanan status 'Selesai'", 
                            style: TextStyle(color: Colors.white54, fontSize: 10)
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),
                    const Text("Statistik Pesanan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),

                    // 2. GRID KARTU KECIL
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 1.3,
                      children: [
                        _buildStatCard("Sukses", _stats['total_selesai'].toString(), Icons.check_circle, Colors.green),
                        _buildStatCard("Sedang Jalan", _stats['total_proses'].toString(), Icons.car_rental, Colors.blue),
                        _buildStatCard("Menunggu", _stats['total_pending'].toString(), Icons.timer, Colors.orange),
                        _buildStatCard("Dibatalkan", _stats['total_batal'].toString(), Icons.cancel, Colors.red),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Widget Kartu Statistik Kecil
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 28),
              Text(
                value, 
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)
              ),
            ],
          ),
          const Spacer(),
          Text(title, style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}