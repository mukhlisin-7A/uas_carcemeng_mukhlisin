import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Wajib: flutter pub add image_picker
import 'package:http/http.dart' as http;

class FormMobilScreen extends StatefulWidget {
  // Kalau null berarti mode TAMBAH, kalau ada isi berarti mode EDIT
  final Map<String, dynamic>? mobil;

  const FormMobilScreen({super.key, this.mobil});

  @override
  State<FormMobilScreen> createState() => _FormMobilScreenState();
}

class _FormMobilScreenState extends State<FormMobilScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controller Text Field
  final _merkController = TextEditingController();
  final _modelController = TextEditingController();
  final _nopolController = TextEditingController();
  final _hargaController = TextEditingController();
  final _kursiController = TextEditingController();
  final _tahunController = TextEditingController();
  final _descController = TextEditingController();

  // Variabel Dropdown
  String? _selectedTransmisi;
  String? _selectedBBM;
  String? _selectedTipe;

  // Variabel Gambar
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;

  // CONFIG API (Ganti IP sesuai device kamu)
  // Emulator: 10.0.2.2
  // HP Fisik: 192.168.1.XX
  final String _baseUrl =  'http://10.0.2.2:8081/car_cemeng_api/';

  @override
  void initState() {
    super.initState();
    // Jika mode EDIT, isi form dengan data lama
    if (widget.mobil != null) {
      _merkController.text = widget.mobil!['merk'];
      _modelController.text = widget.mobil!['model'];
      _nopolController.text = widget.mobil!['nomor_plat'];
      _hargaController.text = widget.mobil!['harga_sewa'].toString();
      _kursiController.text = widget.mobil!['jumlah_kursi'].toString();
      _tahunController.text = widget.mobil!['tahun_buat'].toString();
      _descController.text = widget.mobil!['deskripsi'];

      _selectedTransmisi = widget.mobil!['transmisi'];
      _selectedBBM = widget.mobil!['bahan_bakar'];
      _selectedTipe = widget.mobil!['tipe_mobil'];
    }
  }

  @override
  void dispose() {
    _merkController.dispose();
    _modelController.dispose();
    _nopolController.dispose();
    _hargaController.dispose();
    _kursiController.dispose();
    _tahunController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // --- FUNGSI PILIH GAMBAR ---
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // --- FUNGSI SUBMIT (SIMPAN/UPDATE) ---
  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Tentukan mau ke API add atau update
    String url = widget.mobil == null
        ? '${_baseUrl}add_mobil.php'
        : '${_baseUrl}update_mobil.php';

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Jika EDIT, Wajib kirim ID Mobil (Convert ke String biar gak error!)
      if (widget.mobil != null) {
        request.fields['id_mobil'] = widget.mobil!['id_mobil'].toString();
      }

      // Kirim Data Teks
      request.fields['merk'] = _merkController.text;
      request.fields['model'] = _modelController.text;
      request.fields['nomor_plat'] = _nopolController.text;
      request.fields['harga_sewa'] = _hargaController.text;
      request.fields['jumlah_kursi'] = _kursiController.text;
      request.fields['tahun_buat'] = _tahunController.text;
      request.fields['deskripsi'] = _descController.text;

      // Kirim Data Dropdown (Kasih default value kalau null)
      request.fields['transmisi'] = _selectedTransmisi ?? 'Manual';
      request.fields['bahan_bakar'] = _selectedBBM ?? 'Bensin';
      request.fields['tipe_mobil'] = _selectedTipe ?? 'MPV';

      // Kirim File Gambar (Jika User memilih gambar baru)
      if (_imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('gambar', _imageFile!.path),
        );
      }

      // Eksekusi Request
      var response = await request.send();

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Data Berhasil Disimpan!"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(
            context,
            true,
          ); // Kembali ke halaman sebelumnya & refresh
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Gagal menyimpan data"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print("Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error Koneksi: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- TAMPILAN UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mobil == null ? "Tambah Mobil Baru" : "Edit Mobil"),
        backgroundColor: const Color(0xFF673AB7),
      ),
      // SafeArea biar gak ketutup poni HP
      body: SafeArea(
        child: SingleChildScrollView(
          // Padding Bawah Gede biar tombol gak ketutup layar
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. AREA UPLOAD FOTO
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: _imageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.file(_imageFile!, fit: BoxFit.cover),
                            )
                          : (widget.mobil != null &&
                                widget.mobil!['gambar'] != null)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                '${_baseUrl}uploads/${widget.mobil!['gambar']}',
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, _, __) => const Icon(
                                  Icons.broken_image,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.add_a_photo,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Tap untuk ambil foto",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // 2. FORM IDENTITAS MOBIL
                const Text(
                  "Identitas Mobil",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 15),

                Row(
                  children: [
                    Expanded(
                      child: _buildInput(
                        _merkController,
                        "Merk",
                        Icons.branding_watermark,
                        "Cth: Toyota",
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildInput(
                        _modelController,
                        "Model",
                        Icons.car_rental,
                        "Cth: Avanza",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                _buildInput(
                  _nopolController,
                  "Nomor Plat",
                  Icons.confirmation_number,
                  "Cth: B 1234 ABC",
                ),

                const SizedBox(height: 25),
                const Text(
                  "Detail & Harga",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 15),

                // 3. DROPDOWN SPESIFIKASI
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedTransmisi,
                        decoration: _inputDeco("Transmisi", Icons.settings),
                        items: ['Manual', 'Matic']
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedTransmisi = v),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedBBM,
                        decoration: _inputDeco(
                          "Bahan Bakar",
                          Icons.local_gas_station,
                        ),
                        items: ['Bensin', 'Solar', 'Listrik']
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _selectedBBM = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                Row(
                  children: [
                    Expanded(
                      child: _buildInput(
                        _kursiController,
                        "Kursi",
                        Icons.chair,
                        "7",
                        type: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildInput(
                        _tahunController,
                        "Tahun",
                        Icons.calendar_today,
                        "2023",
                        type: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                DropdownButtonFormField<String>(
                  value: _selectedTipe,
                  decoration: _inputDeco("Tipe Mobil", Icons.category),
                  items: ['MPV', 'SUV', 'Sedan', 'LCGC', 'Mewah', 'Bus']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedTipe = v),
                ),
                const SizedBox(height: 15),

                _buildInput(
                  _hargaController,
                  "Harga Sewa (Per Hari)",
                  Icons.attach_money,
                  "Cth: 350000",
                  type: TextInputType.number,
                ),

                const SizedBox(height: 25),

                // 4. DESKRIPSI
                TextFormField(
                  controller: _descController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: "Deskripsi Kondisi",
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(
                        bottom: 60,
                      ), // Biar ikon ada di atas
                      child: Icon(Icons.description),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // 5. TOMBOL SIMPAN
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF673AB7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _isLoading ? null : _submitData,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            widget.mobil == null
                                ? "SIMPAN DATA BARU"
                                : "UPDATE DATA MOBIL",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- HELPER UNTUK TEXT FIELD ---
  Widget _buildInput(
    TextEditingController controller,
    String label,
    IconData icon,
    String hint, {
    TextInputType type = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      decoration: _inputDeco(label, icon, hint: hint),
      validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
    );
  }

  // --- HELPER DEKORASI INPUT ---
  InputDecoration _inputDeco(String label, IconData icon, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
    );
  }
}
