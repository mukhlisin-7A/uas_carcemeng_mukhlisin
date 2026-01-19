import 'package:flutter/material.dart';

// IMPORT SEMUA HALAMAN FITUR ADMIN
import 'profil_screen.dart';
import 'kelola_mobil_screen.dart';
import 'add_admin_screen.dart';
import 'admin_pesanan_screen.dart';
import 'admin_riwayat_screen.dart';
import 'admin_laporan_screen.dart';
import 'admin_chat_list_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const AdminHomeScreen({super.key, required this.user});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color primaryPurple = const Color(0xFF673AB7);
    Color bgGrey = const Color(0xFFF5F5F5);

    final List<Widget> widgetOptions = [
      _buildAdminDashboard(primaryPurple), // Tab 0: Dashboard Menu
      ProfilScreen(user: widget.user), // Tab 1: Profil Akun
    ];

    return Scaffold(
      backgroundColor: bgGrey,

      // Body berubah sesuai tab navigasi bawah
      body: widgetOptions.elementAt(_selectedIndex),

      // Navigasi Bawah
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts),
            label: 'Akun Saya',
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

  // --- TAMPILAN DASHBOARD ADMIN ---
  Widget _buildAdminDashboard(Color primaryPurple) {
    String initial = (widget.user['username'] ?? "A")[0].toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: primaryPurple,
        elevation: 0,
        toolbarHeight: 80,
        automaticallyImplyLeading: false, // Hilangkan tombol back default
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.admin_panel_settings,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Administrator",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Control Panel",
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 22,
              child: Text(
                initial,
                style: TextStyle(
                  color: primaryPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              decoration: BoxDecoration(
                color: primaryPurple,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    "Selamat Datang, ${widget.user['username']}!",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Kelola aplikasi rental mobil Anda dengan mudah dari sini.",
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Grid Menu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.0,
                children: [
                  // 1. KELOLA MOBIL
                  _buildAdminMenuCard(
                    icon: Icons.directions_car_filled,
                    title: "Kelola Mobil",
                    subtitle: "Tambah & Edit Unit",
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const KelolaMobilScreen(),
                        ),
                      );
                    },
                  ),

                  // 2. DAFTAR PESANAN
                  _buildAdminMenuCard(
                    icon: Icons.assignment,
                    title: "Daftar Pesanan",
                    subtitle: "Cek Status Sewa",
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminPesananScreen(),
                        ),
                      );
                    },
                  ),

                  // 3. TAMBAH ADMIN
                  _buildAdminMenuCard(
                    icon: Icons.person_add,
                    title: "Tambah Admin",
                    subtitle: "Registrasi Staff",
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddAdminScreen(),
                        ),
                      );
                    },
                  ),

                  // 4. ARSIP RIWAYAT
                  _buildAdminMenuCard(
                    icon: Icons.history_edu,
                    title: "Arsip Riwayat",
                    subtitle: "Log Transaksi",
                    color: Colors.purple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminRiwayatScreen(),
                        ),
                      );
                    },
                  ),

                  // 5. PESAN MASUK
                  _buildAdminMenuCard(
                    icon: Icons.chat_bubble,
                    title: "Pesan Masuk",
                    subtitle: "Layanan Pelanggan",
                    color: Colors.pink,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminChatListScreen(),
                        ),
                      );
                    },
                  ),

                  // 6. LAPORAN
                  _buildAdminMenuCard(
                    icon: Icons.bar_chart,
                    title: "Laporan",
                    subtitle: "Statistik Keuangan",
                    color: Colors.teal,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminLaporanScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- WIDGET KARTU MENU (FINAL FIX CENTERING) ---
  Widget _buildAdminMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    int badgeCount = 0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          elevation: 4,
          shadowColor: Colors.black12,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: SizedBox(
                // PENTING: Membungkus Column agar mendapatkan lebar penuh
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 32, color: color),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey[600], fontSize: 11),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Tampilkan Badge Merah
        if (badgeCount > 0)
          Positioned(
            right: 10,
            top: 10,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                badgeCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }
}
