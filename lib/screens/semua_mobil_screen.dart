import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SemuaMobilScreen extends StatefulWidget {
  const SemuaMobilScreen({super.key});

  @override
  State<SemuaMobilScreen> createState() => _SemuaMobilScreenState();
}

class _SemuaMobilScreenState extends State<SemuaMobilScreen> {
  List _cars = [];
  List _filteredCars = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  final String _baseUrl =  'http://10.0.2.2:8081/car_cemeng_api/';

  @override
  void initState() {
    super.initState();
    _fetchCars();
  }

  Future<void> _fetchCars() async {
    try {
      final response = await http.get(
        Uri.parse('${_baseUrl}read_mobil.php'),
        // TAMBAHKAN HEADERS DI SINI
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _cars = data['data'];
            _filteredCars = _cars;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error fetch cars: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _runFilter(String keyword) {
    List results = [];
    if (keyword.isEmpty) {
      results = _cars;
    } else {
      results = _cars
          .where(
            (car) =>
                car['merk'].toLowerCase().contains(keyword.toLowerCase()) ||
                car['model'].toLowerCase().contains(keyword.toLowerCase()),
          )
          .toList();
    }
    setState(() {
      _filteredCars = results;
    });
  }

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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Semua Mobil"),
        backgroundColor: const Color(0xFF673AB7),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              controller: _searchController,
              onChanged: _runFilter,
              decoration: InputDecoration(
                hintText: "Cari mobil...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),

          // List Mobil
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredCars.isEmpty
                ? const Center(child: Text("Tidak ditemukan"))
                : ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount: _filteredCars.length,
                    itemBuilder: (context, index) {
                      final mobil = _filteredCars[index];
                      String? gambarUrl;
                      if (mobil['gambar'] != null && mobil['gambar'] != "") {
                        gambarUrl = '${_baseUrl}uploads/${mobil['gambar']}';
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 15),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Gambar Besar
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(15),
                              ),
                              child: Container(
                                height: 150,
                                width: double.infinity,
                                color: Colors.grey[200],
                                child: gambarUrl != null
                                    ? Image.network(
                                        gambarUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) =>
                                            const Icon(Icons.broken_image),
                                      )
                                    : const Icon(
                                        Icons.car_rental,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${mobil['merk']} ${mobil['model']}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Chip(
                                        label: Text(mobil['tipe_mobil']),
                                        backgroundColor: Colors.orange.shade100,
                                        labelStyle: const TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        formatRupiah(
                                          mobil['harga_sewa'].toString(),
                                        ),
                                        style: const TextStyle(
                                          color: Color(0xFF673AB7),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF673AB7,
                                        ),
                                      ),
                                      onPressed: () {
                                        // Nanti masuk halaman detail sewa
                                      },
                                      child: const Text(
                                        "Lihat Detail",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
