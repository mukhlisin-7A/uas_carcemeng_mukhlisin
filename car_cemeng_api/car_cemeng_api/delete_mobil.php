<?php
include 'koneksi.php';
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    
    $id = $_POST['id_mobil'];

    // 1. Ambil nama gambar dulu sebelum dihapus datanya
    $queryCek = "SELECT gambar FROM mobil WHERE id_mobil = '$id'";
    $resultCek = mysqli_query($connect, $queryCek);
    $data = mysqli_fetch_assoc($resultCek);

    // 2. Hapus file gambar di folder 'uploads' jika ada
    if ($data && $data['gambar'] != null && $data['gambar'] != "") {
        $path = "uploads/" . $data['gambar'];
        if (file_exists($path)) {
            unlink($path); // Hapus file fisik
        }
    }

    // 3. Hapus data di database
    $queryDelete = "DELETE FROM mobil WHERE id_mobil = '$id'";

    if (mysqli_query($connect, $queryDelete)) {
        echo json_encode(["success" => true, "message" => "Mobil berhasil dihapus!"]);
    } else {
        echo json_encode(["success" => false, "message" => "Gagal hapus: " . mysqli_error($connect)]);
    }

} else {
    echo json_encode(["success" => false, "message" => "Metode salah"]);
}
?>