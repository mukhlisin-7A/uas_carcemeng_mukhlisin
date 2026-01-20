<?php
include 'koneksi.php';
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $id_user = $_POST['id_user'];

    // Tandai semua pesan dari user ini sudah dibaca admin
    $query = "UPDATE pesan SET is_read_admin = 1 WHERE id_user = '$id_user'";

    if (mysqli_query($connect, $query)) {
        echo json_encode(["success" => true]);
    } else {
        echo json_encode(["success" => false, "message" => mysqli_error($connect)]);
    }
}
?>