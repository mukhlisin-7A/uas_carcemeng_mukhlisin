<?php
include 'koneksi.php';
header("Content-Type: application/json");

// Hitung semua pesan yang belum dibaca admin (is_read_admin = 0)
$query = "SELECT COUNT(*) as jumlah FROM pesan WHERE is_read_admin = 0";
$result = mysqli_query($connect, $query);
$row = mysqli_fetch_assoc($result);

echo json_encode(["success" => true, "unread" => $row['jumlah']]);
?>