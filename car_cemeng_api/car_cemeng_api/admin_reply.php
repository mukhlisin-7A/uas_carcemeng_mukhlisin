<?php
include 'koneksi.php';
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $id_user = $_POST['id_user'];
    $balasan = $_POST['balasan'];

    if (empty($id_user) || empty($balasan)) {
        echo json_encode(["success" => false, "message" => "Pesan kosong"]);
        exit();
    }

    // Cari pesan terakhir dari user ini yang BELUM dibalas
    // Kalau semua sudah dibalas, kita update pesan paling terakhir saja (tumpuk chat)
    // atau idealnya table strukturnya diubah, tapi untuk skenario ini kita update row terakhir.

    $query = "UPDATE pesan SET balasan_admin = '$balasan', waktu_balas = NOW() 
              WHERE id_user = '$id_user' AND balasan_admin IS NULL 
              ORDER BY id_pesan DESC LIMIT 1";

    $run = mysqli_query($connect, $query);

    // Cek apakah ada baris yang terupdate (affected rows)
    if (mysqli_affected_rows($connect) > 0) {
        echo json_encode(["success" => true, "message" => "Balasan terkirim"]);
    } else {
        // Jika tidak ada pesan pending (user belum chat lagi), kita update row terakhir user tsb
        // (Opsional, biar admin tetap bisa chat walau user diam)
        $queryForce = "UPDATE pesan SET balasan_admin = CONCAT(balasan_admin, '\n\n(Admin): $balasan'), waktu_balas = NOW() 
                       WHERE id_user = '$id_user' ORDER BY id_pesan DESC LIMIT 1";
        mysqli_query($connect, $queryForce);

        echo json_encode(["success" => true, "message" => "Balasan ditambahkan ke pesan terakhir"]);
    }
}
?>