<?php
include 'koneksi.php';
header("Content-Type: application/json");

// Ambil daftar user & hitung pesan yang belum dibaca ADMIN (is_read_admin = 0)
$query = "SELECT u.id, u.username, u.email, 
          MAX(p.waktu_kirim) as last_time,
          SUM(CASE WHEN p.is_read_admin = 0 THEN 1 ELSE 0 END) as unread
          FROM pesan p
          JOIN users u ON p.id_user = u.id
          GROUP BY p.id_user
          ORDER BY last_time DESC";

$result = mysqli_query($connect, $query);

$data = [];
while ($row = mysqli_fetch_assoc($result)) {
    $data[] = $row;
}

echo json_encode(["success" => true, "data" => $data]);
?>