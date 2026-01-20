<?php
// register.php
include 'koneksi.php'; // Ini sudah bawa error_reporting(0) dari file koneksi di atas

// Pastikan Content-Type JSON (Redundant biar aman)
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    
    // Tangkap input JSON raw (kadang Flutter ngirim raw body)
    $json = file_get_contents('php://input');
    $data = json_decode($json, true);

    // Kalau data dikirim via JSON Body (Raw), pakai $data. Kalau Form-Data, pakai $_POST
    $username = isset($data['username']) ? $data['username'] : $_POST['username'];
    $email    = isset($data['email'])    ? $data['email']    : $_POST['email'];
    $password = isset($data['password']) ? $data['password'] : $_POST['password'];
    $address  = isset($data['address'])  ? $data['address']  : $_POST['address'];
    $phone    = isset($data['phone'])    ? $data['phone']    : $_POST['phone'];

    if (empty($username) || empty($email) || empty($password) || empty($address) || empty($phone)) {
        echo json_encode(["success" => false, "message" => "Lengkapi semua data!"]);
        exit();
    }

    // Cek Email
    $cekEmail = mysqli_query($connect, "SELECT * FROM users WHERE email = '$email'");
    if (mysqli_num_rows($cekEmail) > 0) {
        echo json_encode(["success" => false, "message" => "Email sudah terdaftar!"]);
        exit();
    }

    // Insert
    $passHash = md5($password);
    $query = "INSERT INTO users (username, email, password, address, phone) VALUES ('$username', '$email', '$passHash', '$address', '$phone')";

    if (mysqli_query($connect, $query)) {
        echo json_encode(["success" => true, "message" => "Registrasi Berhasil!"]);
    } else {
        echo json_encode(["success" => false, "message" => "Database Error: " . mysqli_error($connect)]);
    }

} else {
    echo json_encode(["success" => false, "message" => "Metode request salah"]);
}
?>