<?php
// read_mobil.php
include 'koneksi.php';
header("Content-Type: application/json");

$keyword = isset($_GET['keyword']) ? $_GET['keyword'] : '';
$kategori = isset($_GET['kategori']) ? $_GET['kategori'] : '';

// 1. QUERY DASAR: Hanya tampilkan mobil yang statusnya 'tersedia'
$sql = "SELECT * FROM mobil WHERE status = 'tersedia'";

// 2. Tambahkan Filter Pencarian (Jika ada keyword)
if (!empty($keyword)) {
    $keyword = mysqli_real_escape_string($connect, $keyword); // Amankan input
    $sql .= " AND (merk LIKE '%$keyword%' OR model LIKE '%$keyword%')";
}

// 3. Tambahkan Filter Kategori (Jika ada kategori & bukan 'Semua')
if (!empty($kategori) && $kategori != 'Semua') {
    $kategori = mysqli_real_escape_string($connect, $kategori);
    $sql .= " AND tipe_mobil = '$kategori'";
}

// 4. Urutkan Terbaru
$sql .= " ORDER BY id_mobil DESC";

$result = mysqli_query($connect, $sql);

$mobil = [];
while ($row = mysqli_fetch_assoc($result)) {
    $mobil[] = $row;
}

echo json_encode([
    "success" => true,
    "data" => $mobil
]);
?>