<?php
// update_status_pesanan.php
include 'koneksi.php';
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    
    $id_sewa = $_POST['id_sewa'];
    $status_baru = $_POST['status']; // 'konfirmasi', 'selesai', 'batal_admin', dll.

    if (empty($id_sewa) || empty($status_baru)) {
        echo json_encode(["success" => false, "message" => "Data tidak lengkap"]);
        exit();
    }

    // 1. AMBIL ID MOBIL DARI PESANAN
    $queryGetMobil = mysqli_query($connect, "SELECT id_mobil FROM pesanan WHERE id_sewa = '$id_sewa'");
    $mobilData = mysqli_fetch_assoc($queryGetMobil);
    $id_mobil = $mobilData['id_mobil'];

    // 2. TENTUKAN STATUS MOBIL BARU
    $car_status = '';
    
    // Jika dikonfirmasi, mobil TIDAK BISA DISEWA lagi (status 'disewa')
    if ($status_baru == 'konfirmasi') {
        $car_status = 'disewa';
    } 
    // Jika Selesai atau Dibatalkan (oleh Admin/User), mobil KEMBALI TERSEDIA
    else if ($status_baru == 'selesai' || strpos($status_baru, 'batal') !== false) {
        $car_status = 'tersedia';
    } else {
        // Biarkan status mobil tetap (misal statusnya belum berubah)
        echo json_encode(["success" => false, "message" => "Status tidak dikenali"]);
        exit();
    }

    // 3. UPDATE STATUS DI TABEL PESANAN
    $queryPesanan = "UPDATE pesanan SET status = '$status_baru' WHERE id_sewa = '$id_sewa'";
    mysqli_query($connect, $queryPesanan);

    // 4. UPDATE STATUS DI TABEL MOBIL
    $queryMobil = "UPDATE mobil SET status = '$car_status' WHERE id_mobil = '$id_mobil'";
    
    if (mysqli_query($connect, $queryMobil)) {
        echo json_encode(["success" => true, "message" => "Status berhasil diubah menjadi $status_baru. Mobil sekarang $car_status."]);
    } else {
        echo json_encode(["success" => false, "message" => "Gagal update status mobil: " . mysqli_error($connect)]);
    }

}
?>