<?php
include 'koneksi.php';
header("Content-Type: application/json");

// Ambil semua pesanan, diurutkan dari yang terbaru
// JOIN ke tabel mobil (ambil merk/model/gambar)
// JOIN ke tabel users (ambil username/phone)
$query = "SELECT p.*, m.merk, m.model, m.gambar, u.username, u.phone 
          FROM pesanan p 
          JOIN mobil m ON p.id_mobil = m.id_mobil 
          JOIN users u ON p.id_user = u.id 
          ORDER BY p.id_sewa DESC";

$result = mysqli_query($connect, $query);

$data = [];
while ($row = mysqli_fetch_assoc($result)) {
    $data[] = $row;
}

echo json_encode(["success" => true, "data" => $data]);
?>