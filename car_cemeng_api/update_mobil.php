<?php
include 'koneksi.php';
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    
    // Tangkap ID Mobil yang mau diedit
    $id = $_POST['id_mobil']; 

    // Tangkap Data Lain
    $merk = $_POST['merk'];
    $model = $_POST['model'];
    $nopol = $_POST['nomor_plat'];
    $harga = $_POST['harga_sewa'];
    $tipe = $_POST['tipe_mobil'];
    $transmisi = $_POST['transmisi'];
    $bbm = $_POST['bahan_bakar'];
    $kursi = $_POST['jumlah_kursi'];
    $tahun = $_POST['tahun_buat'];
    $desc = $_POST['deskripsi'];

    // Cek apakah Admin upload gambar baru?
    if (isset($_FILES['gambar']['name']) && $_FILES['gambar']['name'] != '') {
        // Upload Gambar Baru
        $namaFile = $_FILES['gambar']['name'];
        $tmpName = $_FILES['gambar']['tmp_name'];
        $ext = pathinfo($namaFile, PATHINFO_EXTENSION);
        $gambarNama = uniqid() . "." . $ext;
        
        move_uploaded_file($tmpName, 'uploads/' . $gambarNama);
        
        // Query Update DENGAN Ganti Gambar
        $query = "UPDATE mobil SET merk='$merk', model='$model', nomor_plat='$nopol', harga_sewa='$harga', tipe_mobil='$tipe', transmisi='$transmisi', bahan_bakar='$bbm', jumlah_kursi='$kursi', tahun_buat='$tahun', deskripsi='$desc', gambar='$gambarNama' WHERE id_mobil='$id'";
    } else {
        // Query Update TANPA Ganti Gambar (Gambar lama tetap dipakai)
        $query = "UPDATE mobil SET merk='$merk', model='$model', nomor_plat='$nopol', harga_sewa='$harga', tipe_mobil='$tipe', transmisi='$transmisi', bahan_bakar='$bbm', jumlah_kursi='$kursi', tahun_buat='$tahun', deskripsi='$desc' WHERE id_mobil='$id'";
    }

    if (mysqli_query($connect, $query)) {
        echo json_encode(["success" => true, "message" => "Data Mobil Berhasil Diupdate!"]);
    } else {
        echo json_encode(["success" => false, "message" => "Gagal Update: " . mysqli_error($connect)]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Metode Request Salah"]);
}
?>