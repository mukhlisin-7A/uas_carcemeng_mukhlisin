<?php
include 'koneksi.php';
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    
    $id_sewa = $_POST['id_sewa'];

    // Update status jadi 'batal'
    $query = "UPDATE pesanan SET status = 'batal' WHERE id_sewa = '$id_sewa'";

    if (mysqli_query($connect, $query)) {
        echo json_encode(["success" => true, "message" => "Pesanan berhasil dibatalkan."]);
    } else {
        echo json_encode(["success" => false, "message" => "Gagal membatalkan."]);
    }
}
?>