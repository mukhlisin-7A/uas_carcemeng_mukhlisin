<?php
include 'koneksi.php';
header("Content-Type: application/json");

$id_user = isset($_GET['id_user']) ? $_GET['id_user'] : '';

// Hitung pesan yang:
// 1. Punya user tersebut
// 2. Sudah dibalas admin (balasan_admin TIDAK NULL)
// 3. Statusnya masih belum dibaca (is_read = 0)
$query = "SELECT COUNT(*) as jumlah FROM pesan 
          WHERE id_user = '$id_user' 
          AND balasan_admin IS NOT NULL 
          AND is_read = 0";

$result = mysqli_query($connect, $query);
$row = mysqli_fetch_assoc($result);

echo json_encode(["success" => true, "unread" => $row['jumlah']]);
?>