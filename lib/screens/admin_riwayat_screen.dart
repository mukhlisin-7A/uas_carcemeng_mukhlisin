import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'detail_riwayat_screen.dart';

class AdminRiwayatScreen extends StatefulWidget {
  const AdminRiwayatScreen({super.key});

  @override
  State<AdminRiwayatScreen> createState() => _AdminRiwayatScreenState();
}

class _AdminRiwayatScreenState extends State<AdminRiwayatScreen> {
  List _allData = [];
  bool _isLoading = true;
  double _totalIncome = 0;

  // CONFIG API (Sesuaikan IP)
  final String _baseUrl =  'http://10.0.2.2:8081/car_cemeng_api/';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

Future<void> _fetchData() async {
    try {
      final response = await http.get(
        Uri.parse('${_baseUrl}get_admin_riwayat.php'),
        // TAMBAHKAN HEADER UNTUK INFINITYFREE
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        List fetchedData = data['data'];
        
        // FILTER ARSIP: Hanya Selesai & Batal
        List archiveData = fetchedData.where((item) {
          String s = item['status'];
          return s == 'selesai' || s == 'batal' || s == 'batal_user' || s == 'batal_admin';
        }).toList();

        double income = 0;
        for (var item in archiveData) {
          if (item['status'] == 'selesai') {
            income += double.tryParse(item['total_harga'].toString()) ?? 0;
          }
        }

        if (mounted) {
          setState(() {
            _allData = archiveData;
            _totalIncome = income;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error fetch riwayat: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String formatRupiah(double number) {
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(number);
  }

  String formatDate(String dateStr) {
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(dateStr));
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Arsip Riwayat"),
        backgroundColor: const Color(0xFF673AB7),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // SUMMARY CARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFF673AB7),
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Total Pendapatan (Selesai)", style: TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 5),
                      Text(formatRupiah(_totalIncome), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text("${_allData.length} Arsip Tersimpan", style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // LIST ARSIP
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount: _allData.length,
                    itemBuilder: (context, index) {
                      return _buildAdminHistoryCard(_allData[index]);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAdminHistoryCard(Map data) {
    String status = data['status'];
    Color statusColor;
    String statusLabel;

    if (status == 'selesai') {
      statusColor = Colors.green;
      statusLabel = "Selesai";
    } else {
      statusColor = Colors.red;
      statusLabel = "Dibatalkan";
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => DetailRiwayatScreen(data: data)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 3))],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 5),
                    Text(data['username'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
                  child: Text(statusLabel.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${data['merk']} ${data['model']}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text("Plat: ${data['nomor_plat']}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 5),
                      Text(formatDate(data['tgl_sewa']), style: const TextStyle(fontSize: 12, color: Colors.black87)),
                    ],
                  ),
                ),
                Text(
                  formatRupiah(double.tryParse(data['total_harga'].toString()) ?? 0),
                  style: const TextStyle(color: Color(0xFF673AB7), fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}