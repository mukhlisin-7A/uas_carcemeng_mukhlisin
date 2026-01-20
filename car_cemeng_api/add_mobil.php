<?php
include 'koneksi.php';
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    
    // Ambil Data Teks
    $merk = $_POST['merk'];
    $model = $_POST['model'];
    $nopol = $_POST['nomor_plat'];
    $harga = $_POST['harga_sewa'];
    $tipe = $_POST['tipe_mobil'];
    $transmisi = $_POST['transmisi'];
    $bbm = $_POST['bahan_bakar'];
    $kursi = $_POST['jumlah_kursi'];
    $tahun = $_POST['tahun_buat'];
    $desc = $_POST['deskripsi'];

    // Proses Upload Gambar
    $gambarNama = null;
    if (isset($_FILES['gambar']['name'])) {
        $namaFile = $_FILES['gambar']['name'];
        $tmpName = $_FILES['gambar']['tmp_name'];
        
        // Bikin nama unik biar gak bentrok
        $ekstensi = pathinfo($namaFile, PATHINFO_EXTENSION);
        $gambarNama = uniqid() . "." . $ekstensi;
        
        // Pindahkan file ke folder uploads
        move_uploaded_file($tmpName, 'uploads/' . $gambarNama);
    }

    $query = "INSERT INTO mobil (merk, model, nomor_plat, harga_sewa, tipe_mobil, transmisi, bahan_bakar, jumlah_kursi, tahun_buat, deskripsi, gambar) 
              VALUES ('$merk', '$model', '$nopol', '$harga', '$tipe', '$transmisi', '$bbm', '$kursi', '$tahun', '$desc', '$gambarNama')";

    if (mysqli_query($connect, $query)) {
        echo json_encode(["success" => true, "message" => "Mobil berhasil ditambahkan!"]);
    } else {
        echo json_encode(["success" => false, "message" => "Gagal: " . mysqli_error($connect)]);
    }
}
?>