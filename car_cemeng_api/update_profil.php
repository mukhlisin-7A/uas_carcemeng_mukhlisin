<?php
// update_profile.php
include 'koneksi.php';

header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    
    $json = file_get_contents('php://input');
    $data = json_decode($json, true);

    $id       = $data['id']; // ID User (PENTING)
    $username = $data['username'];
    $email    = $data['email'];
    $address  = $data['address'];
    $phone    = $data['phone'];
    $password = isset($data['password']) ? $data['password'] : '';

    if (empty($id)) {
        echo json_encode(["success" => false, "message" => "ID User tidak ditemukan"]);
        exit();
    }

    // Cek apakah user mau ganti password?
    if (!empty($password)) {
        // Kalau password diisi, enkripsi baru
        $passHash = md5($password);
        $query = "UPDATE users SET username='$username', email='$email', address='$address', phone='$phone', password='$passHash' WHERE id='$id'";
    } else {
        // Kalau password kosong, jangan update kolom password
        $query = "UPDATE users SET username='$username', email='$email', address='$address', phone='$phone' WHERE id='$id'";
    }

    if (mysqli_query($connect, $query)) {
        // Kirim balik data terbaru biar aplikasi langsung update tanpa login ulang
        echo json_encode([
            "success" => true, 
            "message" => "Profil Berhasil Diupdate!",
            "user" => [
                "id" => $id,
                "username" => $username,
                "email" => $email,
                "phone" => $phone,
                "address" => $address
            ]
        ]);
    } else {
        echo json_encode(["success" => false, "message" => "Gagal update: " . mysqli_error($connect)]);
    }

} else {
    echo json_encode(["success" => false, "message" => "Metode salah"]);
}
?>