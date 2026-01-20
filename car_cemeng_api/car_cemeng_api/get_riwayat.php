<?php
include 'koneksi.php';
header("Content-Type: application/json");

// Ambil ID User dari parameter URL
$id_user = isset($_GET['id_user']) ? $_GET['id_user'] : '';

if (empty($id_user)) {
    echo json_encode(["success" => false, "message" => "ID User kosong"]);
    exit();
}

// Query JOIN: Ambil data pesanan DAN data mobil yang sesuai
$query = "SELECT p.*, m.merk, m.model, m.gambar 
          FROM pesanan p 
          JOIN mobil m ON p.id_mobil = m.id_mobil 
          WHERE p.id_user = '$id_user' 
          ORDER BY p.id_sewa DESC";

$result = mysqli_query($connect, $query);

$riwayat = [];
while ($row = mysqli_fetch_assoc($result)) {
    $riwayat[] = $row;
}

echo json_encode([
    "success" => true,
    "data" => $riwayat
]);
?>