<?php
include 'koneksi.php';
header("Content-Type: application/json");
error_reporting(0); // Matikan warning HTML

// Query ambil semua data (JOIN 3 Tabel)
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