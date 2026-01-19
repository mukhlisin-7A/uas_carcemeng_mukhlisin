import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http; // Wajib import http
import 'dart:async'; // Untuk Timer

// IMPORT FILE HALAMAN LAIN
import 'riwayat_screen.dart';
import 'kontak_screen.dart';
import 'profil_screen.dart';
import 'detail_mobil_screen.dart'; // <--- File Detail Mobil (Wajib Ada)

class HomeScreen extends StatefulWidget {
  // TERIMA DATA USER LENGKAP DARI LOGIN
  final Map<String, dynamic> user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // 0: Home, 1: Riwayat, 2: Kontak, 3: Profil

  // Variabel untuk Data Mobil
  List _cars = [];
  bool _isLoadingCars = true;

  // Filter Aktif
  String _selectedCategory = "Semua";
  final TextEditingController _searchController = TextEditingController();

  // Notifikasi
  int _unreadCount = 0;
  Timer? _timer;

  // CONFIG API (Ganti IP sesuai device kamu)
  // Emulator: 10.0.2.2 | HP Fisik: 192.168.1.XX (Sesuaikan dengan IP Laptop)
  final String _baseUrl =  'http://10.0.2.2:8081/car_cemeng_api/';

  @override
  void initState() {
    super.initState();
    _fetchCars(); // Ambil data mobil saat aplikasi dibuka
    _checkUnreadMessages(); // Cek pesan

    // Cek pesan baru setiap 5 detik
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_selectedIndex != 2) {
        // Cuma cek kalau gak lagi buka kontak
        _checkUnreadMessages();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // --- CEK NOTIFIKASI PESAN ---
  Future<void> _checkUnreadMessages() async {
    try {
      final response = await http.get(
        Uri.parse(
          '${_baseUrl}get_unread_count.php?id_user=${widget.user['id']}',
        ),
        // TAMBAHKAN HEADERS DI SINI
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _unreadCount = int.tryParse(data['unread'].toString()) ?? 0;
          });
        }
      }
    } catch (e) {
      print("Error cek notif: $e");
    }
  }

  // --- FUNGSI UTAMA: AMBIL DATA DARI DATABASE (SERVER SIDE FILTER) ---
  Future<void> _fetchCars({
    String keyword = "",
    String category = "Semua",
  }) async {
    setState(() => _isLoadingCars = true);

    try {
      // Susun URL dengan Parameter Query
      // Contoh hasil: read_mobil.php?keyword=avanza&kategori=MPV
      String url =
          '${_baseUrl}read_mobil.php?keyword=$keyword&kategori=$category';

      print("Request ke API: $url"); // Debugging di Console

      final response = await http.get(
        Uri.parse(url),
        // TAMBAHKAN HEADERS DI SINI
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _cars = data['data']; // Data langsung dari hasil query database
            _isLoadingCars = false;
          });
        }
      }
    } catch (e) {
      print("Error ambil data: $e");
      if (mounted) setState(() => _isLoadingCars = false);
    }}

  // --- LOGIKA GANTI KATEGORI ---
  void _onCategoryTap(String category) {
    setState(() {
      _selectedCategory = category; // Update UI tombol warna kuning
    });
    // Request ke Database sesuai kategori baru & keyword yang ada
    _fetchCars(keyword: _searchController.text, category: category);
  }

  // --- LOGIKA KETIK SEARCH ---
  void _onSearchChanged(String value) {
    // Request ke Database sesuai keyword baru & kategori yang aktif
    _fetchCars(keyword: value, category: _selectedCategory);
  }

  // Fungsi ganti tab navigasi bawah
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      // Jika klik tab kontak, hilangkan badge
      if (index == 2) {
        _unreadCount = 0;
      }
    });
  }

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
    const Color primaryPurple = Color(0xFF673AB7);
    const Color bgGrey = Color(0xFFF5F5F5);
    String displayName = widget.user['username'] ?? "User";

    // --- DAFTAR HALAMAN ---
    final List<Widget> widgetOptions = [
      // 1. Tampilan Home (Dashboard lokal dengan Data API)
      _buildHomeView(primaryPurple, displayName),

      // 2. Tampilan Riwayat (Kirim Data User)
      RiwayatScreen(user: widget.user),

      // 3. Tampilan Kontak (Kirim Data User)
      KontakScreen(user: widget.user),

      // 4. Tampilan Profil (Kirim Data User)
      ProfilScreen(user: widget.user),
    ];

    return Scaffold(
      backgroundColor: bgGrey,
      body: widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Riwayat',
          ),

          // Badge Notifikasi di Kontak
          BottomNavigationBarItem(
            icon: _unreadCount > 0
                ? Badge(
                    label: Text(_unreadCount.toString()),
                    backgroundColor: Colors.red,
                    child: const Icon(Icons.support_agent),
                  )
                : const Icon(Icons.support_agent),
            label: 'Kontak',
          ),

          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: primaryPurple,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        elevation: 10,
      ),
    );
  }

  // ==========================================================
  // VIEW DASHBOARD HOME (Tab Index 0)
  // ==========================================================
  Widget _buildHomeView(Color primaryPurple, String username) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: primaryPurple,
        elevation: 0,
        toolbarHeight: 70,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Lokasi Anda",
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
            Row(
              children: const [
                Icon(Icons.location_on, size: 16, color: Colors.white),
                SizedBox(width: 5),
                Text(
                  "Jakarta, Indonesia",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                username.isNotEmpty ? username[0].toUpperCase() : "U",
                style: TextStyle(
                  color: primaryPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        // Biar bisa tarik layar buat refresh data
        onRefresh: () => _fetchCars(
          keyword: _searchController.text,
          category: _selectedCategory,
        ),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER UNGU & SEARCH ---
              Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                decoration: BoxDecoration(
                  color: primaryPurple,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Halo, $username 👋",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Mau sewa mobil apa hari ini?",
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                    const SizedBox(height: 25),

                    // INPUT PENCARIAN (LANGSUNG KE DATABASE)
                    TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged, // Panggil fungsi saat ngetik
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Cari merk (Avanza, Brio)...",
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // --- KATEGORI MOBIL ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Text(
                  "Kategori",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 15),

              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildCategoryChip("Semua"),
                    _buildCategoryChip("MPV"),
                    _buildCategoryChip("SUV"),
                    _buildCategoryChip("Sedan"),
                    _buildCategoryChip("LCGC"),
                    _buildCategoryChip("Mewah"),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // --- DAFTAR MOBIL ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Text(
                  "Daftar Mobil",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              // LIST BUILDER (Data Realtime dari API)
              _isLoadingCars
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : _cars.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.search_off,
                            size: 60,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Mobil tidak ditemukan\nKategori: $_selectedCategory",
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics:
                          const NeverScrollableScrollPhysics(), // Scroll ikut parent
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _cars.length,
                      itemBuilder: (context, index) {
                        // PERBAIKAN: Gunakan fungsi build yang aman type datanya
                        return _buildCarCard(_cars[index]);
                      },
                    ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET CHIP KATEGORI ---
  Widget _buildCategoryChip(String label) {
    bool isActive = _selectedCategory == label;
    return GestureDetector(
      onTap: () => _onCategoryTap(label),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFFC107) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isActive ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.black : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET KARTU MOBIL (FIXED TYPE) ---
  Widget _buildCarCard(dynamic mobilData) {
    // 1. Konversi data mobil menjadi Map<String, dynamic> yang aman
    final Map<String, dynamic> mobil = Map<String, dynamic>.from(mobilData);

    // Construct URL Gambar
    String? gambarUrl;
    if (mobil['gambar'] != null && mobil['gambar'] != "") {
      gambarUrl = '${_baseUrl}uploads/${mobil['gambar']}';
    }

    return GestureDetector(
      onTap: () {
        // Navigasi ke Detail Mobil
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailMobilScreen(
              mobil: mobil, // Data Mobil (Sudah di-cast)
              user: widget.user, // Data User (Wajib ada)
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(12),
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
        child: Row(
          children: [
            // Gambar Mobil
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: gambarUrl != null
                    ? Image.network(
                        gambarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) =>
                            const Icon(Icons.broken_image, color: Colors.grey),
                      )
                    : const Icon(
                        Icons.car_rental,
                        size: 40,
                        color: Colors.grey,
                      ),
              ),
            ),
            const SizedBox(width: 15),

            // Info Mobil
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          mobil['tipe_mobil'] ?? 'Umum',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${mobil['jumlah_kursi']} Kursi",
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "${mobil['merk']} ${mobil['model']}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text.rich(
                    TextSpan(
                      text: formatRupiah(mobil['harga_sewa'].toString()),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF673AB7),
                      ),
                      children: const [
                        TextSpan(
                          text: "/hari",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tombol Panah
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
