import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Wajib: flutter pub add intl
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_screen.dart'; // Buat navigasi balik ke home

class BookingScreen extends StatefulWidget {
  final Map<String, dynamic> mobil;
  final Map<String, dynamic> user;

  const BookingScreen({super.key, required this.mobil, required this.user});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  int _totalDays = 0;
  int _totalPrice = 0;
  bool _isLoading = false;

  // CONFIG API (Ganti IP sesuai device kamu)
  // Emulator: 10.0.2.2 | HP Fisik: 192.168.1.XX
 final String _baseUrl =  'http://10.0.2.2:8081/car_cemeng_api/';

  // Fungsi Pilih Tanggal
  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF673AB7)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
            _totalDays = 0;
            _totalPrice = 0;
          }
        } else {
          _endDate = picked;
        }
        _calculateTotal();
      });
    }
  }

  // Hitung Hari & Harga
  void _calculateTotal() {
    if (_startDate != null && _endDate != null) {
      final difference = _endDate!.difference(_startDate!).inDays;
      _totalDays = difference > 0 ? difference : 1;

      // PERBAIKAN: Gunakan double.tryParse agar bisa baca format "300000.00"
      double tempPrice =
          double.tryParse(widget.mobil['harga_sewa'].toString()) ?? 0.0;
      int pricePerDay = tempPrice.toInt();

      _totalPrice = _totalDays * pricePerDay;
    } else {
      _totalDays = 0;
      _totalPrice = 0;
    }
  }

  // Kirim Data Booking ke API
  Future<void> _submitBooking() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pilih tanggal sewa & kembali dulu!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tanggal kembali tidak valid!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${_baseUrl}booking.php'),
        headers: {
          'Content-Type': 'application/json',
          // Wajib ditambahkan untuk InfinityFree
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
        body: jsonEncode({
          'id_user': widget.user['id'],
          'id_mobil': widget.mobil['id_mobil'],
          'tgl_sewa': DateFormat('yyyy-MM-dd').format(_startDate!),
          'tgl_kembali': DateFormat('yyyy-MM-dd').format(_endDate!),
          'total_hari': _totalDays,
          'total_harga': _totalPrice,
        }),
      );
      
     

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Booking Berhasil!",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Pesanan Anda telah diterima.\nSilakan cek menu Riwayat.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // Navigasi Balik ke Home
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (ctx) => HomeScreen(user: widget.user),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text(
                    "OK, Mengerti",
                    style: TextStyle(
                      color: Color(0xFF673AB7),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
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
    } catch (e) {
      print("Error booking: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Terjadi kesalahan koneksi"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Format Rupiah Helper
  String formatRupiah(int number) {
    return NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(number);
  }

  @override
  Widget build(BuildContext context) {
    // Ambil harga untuk ditampilkan di UI (PERBAIKAN UTAMA DI SINI)
    double tempPriceUI =
        double.tryParse(widget.mobil['harga_sewa'].toString()) ?? 0.0;
    int pricePerDayUI = tempPriceUI.toInt();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Formulir Sewa"),
        backgroundColor: const Color(0xFF673AB7),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. INFO MOBIL RINGKAS
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                      image:
                          widget.mobil['gambar'] != null &&
                              widget.mobil['gambar'] != ""
                          ? DecorationImage(
                              image: NetworkImage(
                                '${_baseUrl}uploads/${widget.mobil['gambar']}',
                              ),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child:
                        (widget.mobil['gambar'] == null ||
                            widget.mobil['gambar'] == "")
                        ? const Icon(
                            Icons.car_rental,
                            size: 40,
                            color: Colors.grey,
                          )
                        : null,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${widget.mobil['merk']} ${widget.mobil['model']}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          // Tampilkan Harga yang sudah diperbaiki
                          "${formatRupiah(pricePerDayUI)} / hari",
                          style: const TextStyle(
                            color: Color(0xFF673AB7),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          widget.mobil['nomor_plat'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 2. PILIH TANGGAL SEWA
            const Text(
              "Pilih Jadwal Sewa",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: _buildDateSelector(
                    "Mulai Sewa",
                    _startDate,
                    () => _selectDate(context, true),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildDateSelector(
                    "Selesai Sewa",
                    _endDate,
                    () => _selectDate(context, false),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // 3. RINCIAN BIAYA
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Rincian Pembayaran",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 15),
                  _buildSummaryRow("Durasi Sewa", "$_totalDays Hari"),
                  _buildSummaryRow("Biaya Sewa", formatRupiah(_totalPrice)),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Akhir",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        formatRupiah(_totalPrice),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF673AB7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // 4. TOMBOL BOOKING
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF673AB7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                onPressed: _isLoading ? null : _submitBooking,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "KONFIRMASI SEWA",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Kotak Tanggal
  Widget _buildDateSelector(String label, DateTime? date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: date != null
                ? const Color(0xFF673AB7)
                : Colors.grey.shade300,
            width: date != null ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: date != null ? const Color(0xFF673AB7) : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  date != null
                      ? DateFormat('dd MMM yyyy').format(date)
                      : "Pilih Tgl",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: date != null ? Colors.black : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
