<?php
include 'koneksi.php';
header("Content-Type: application/json");

$id_user = isset($_GET['id_user']) ? $_GET['id_user'] : '';

$query = "SELECT * FROM pesan WHERE id_user = '$id_user' ORDER BY waktu_kirim ASC";
$result = mysqli_query($connect, $query);

$data = [];
while ($row = mysqli_fetch_assoc($result)) {
    $data[] = $row;
}

echo json_encode(["success" => true, "data" => $data]);
?>