import 'package:flutter/material.dart';
import 'dart:developer';
import 'login_screen.dart'; // Import halaman tujuan (Login)

// Menggunakan StatefulWidget agar dapat menggunakan MouseRegion dan setState
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // State untuk melacak status hover (Hanya berfungsi di Web/Desktop)
  bool _isHovering = false;

  // Warna-warna yang digunakan
  static const Color defaultColor = Color(0xFF1A1C4F); // Navy
  static const Color hoverColor = Color(
    0xFF3F51B5,
  ); // Ungu yang sedikit lebih terang

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        // Latar belakang utama (ungu gelap)
        color: const Color(0xFF673AB7),
        child: Stack(
          children: [
            // --- 1. Elemen Latar Belakang Dekoratif (Lingkaran) ---
            Positioned(
              top: size.height * -0.15,
              left: size.width * -0.1,
              child: CustomPaint(
                painter: PurpleCirclePainter(
                  color: Colors.deepPurple.shade300.withAlpha(127),
                ),
                size: Size(size.width * 0.8, size.width * 0.8),
              ),
            ),
            Positioned(
              bottom: size.height * -0.2,
              right: size.width * -0.2,
              child: CustomPaint(
                painter: PurpleCirclePainter(
                  color: Colors.deepPurple.shade300.withAlpha(127),
                ),
                size: Size(size.width * 0.9, size.width * 0.9),
              ),
            ),

            // --- 2. Konten Utama (Logo, Text, dan Tombol) ---
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 40.0,
                vertical: 80.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(height: size.height * 0.1),

                  _buildLogoSection(size), // Logo "CAR CEMENG"

                  Column(
                    children: [
                      // Slogan
                      const Text(
                        'CEPAT, MUDAH DAN\nSOLUSI KELUARGA',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 50),

                      // Tombol MULAI DENGAN HOVER/CLICK EFFECT
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: MouseRegion(
                          onEnter: (event) {
                            setState(() => _isHovering = true);
                          },
                          onExit: (event) {
                            setState(() => _isHovering = false);
                          },
                          child: ElevatedButton(
                            onPressed: () {
                              log('Tombol MULAI Ditekan! Navigasi ke Login.');
                              // Navigasi ke halaman Login dan menghapus halaman Splash
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              // Warna latar belakang tergantung status hover
                              backgroundColor: _isHovering
                                  ? hoverColor
                                  : defaultColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              // Parameter transitionDuration dihapus
                            ),
                            child: const Text(
                              'MULAI',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget terpisah untuk bagian logo
  Widget _buildLogoSection(Size size) {
    return Column(
      children: [
        Container(
          width: size.width * 0.5,
          height: size.width * 0.5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            color: Colors.transparent,
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'CAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  'CEMENG',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: size.height * 0.25),
      ],
    );
  }
}

// Custom Painter
class PurpleCirclePainter extends CustomPainter {
  final Color color;

  PurpleCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
