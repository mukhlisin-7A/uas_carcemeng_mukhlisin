<?php
include 'koneksi.php';
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    
    // Ambil Data JSON dari Flutter
    $json = file_get_contents('php://input');
    $data = json_decode($json, true);

    $id_user     = $data['id_user'];
    $id_mobil    = $data['id_mobil'];
    $tgl_sewa    = $data['tgl_sewa'];    // Format: YYYY-MM-DD
    $tgl_kembali = $data['tgl_kembali']; // Format: YYYY-MM-DD
    $total_hari  = $data['total_hari'];
    $total_harga = $data['total_harga'];

    // Validasi Sederhana
    if (empty($id_user) || empty($id_mobil) || empty($tgl_sewa) || empty($tgl_kembali)) {
        echo json_encode(["success" => false, "message" => "Data tidak lengkap!"]);
        exit();
    }

    // Query Insert Pesanan
    $query = "INSERT INTO pesanan (id_user, id_mobil, tgl_sewa, tgl_kembali, total_hari, total_harga, status) 
              VALUES ('$id_user', '$id_mobil', '$tgl_sewa', '$tgl_kembali', '$total_hari', '$total_harga', 'pending')";

    if (mysqli_query($connect, $query)) {
        // (Opsional) Update status mobil jadi 'disewa' jika mau
        // mysqli_query($connect, "UPDATE mobil SET status='disewa' WHERE id_mobil='$id_mobil'");

        echo json_encode(["success" => true, "message" => "Booking Berhasil! Menunggu Konfirmasi."]);
    } else {
        echo json_encode(["success" => false, "message" => "Gagal Booking: " . mysqli_error($connect)]);
    }

} else {
    echo json_encode(["success" => false, "message" => "Metode Salah"]);
}
?>