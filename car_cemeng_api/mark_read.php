<?php
include 'koneksi.php';
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $id_user = $_POST['id_user'];

    // Update semua pesan milik user ini yang ada balasan adminnya menjadi 'sudah dibaca' (1)
    $query = "UPDATE pesan SET is_read = 1 
              WHERE id_user = '$id_user' AND balasan_admin IS NOT NULL";

    if (mysqli_query($connect, $query)) {
        echo json_encode(["success" => true, "message" => "Pesan ditandai sudah dibaca"]);
    } else {
        echo json_encode(["success" => false, "message" => mysqli_error($connect)]);
    }
}
?>