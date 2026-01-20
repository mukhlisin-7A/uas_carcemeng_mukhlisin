<?php
include 'koneksi.php';
header("Content-Type: application/json");

// Matikan error reporting HTML biar gak ngerusak JSON
error_reporting(0);

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    
    // 1. Coba ambil data dari JSON Body (Raw)
    $json = file_get_contents('php://input');
    $data = json_decode($json, true);

    // 2. Ambil variabel (Prioritas JSON, kalau gak ada baru cek $_POST)
    $id_user = isset($data['id_user']) ? $data['id_user'] : (isset($_POST['id_user']) ? $_POST['id_user'] : '');
    $isi     = isset($data['isi_pesan']) ? $data['isi_pesan'] : (isset($_POST['isi_pesan']) ? $_POST['isi_pesan'] : '');

    // 3. Validasi
    if (empty($id_user) || empty($isi)) {
        echo json_encode([
            "success" => false, 
            "message" => "Data Kosong! ID: $id_user, Pesan: $isi"
        ]);
        exit();
    }

    // 4. Insert ke Database
    $query = "INSERT INTO pesan (id_user, isi_pesan) VALUES ('$id_user', '$isi')";

    if (mysqli_query($connect, $query)) {
        echo json_encode(["success" => true, "message" => "Pesan terkirim"]);
    } else {
        // Kirim pesan error asli dari MySQL
        echo json_encode([
            "success" => false, 
            "message" => "SQL Error: " . mysqli_error($connect)
        ]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Metode Request Salah"]);
}
?>