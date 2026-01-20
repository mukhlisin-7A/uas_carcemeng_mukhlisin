<?php
include 'koneksi.php';
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    
    // Ambil data (bisa JSON atau POST biasa)
    $json = file_get_contents('php://input');
    $data = json_decode($json, true);

    $username = isset($data['username']) ? $data['username'] : $_POST['username'];
    $email    = isset($data['email']) ? $data['email'] : $_POST['email'];
    $password = isset($data['password']) ? $data['password'] : $_POST['password'];
    $phone    = isset($data['phone']) ? $data['phone'] : $_POST['phone'];
    $address  = isset($data['address']) ? $data['address'] : $_POST['address'];

    // Validasi
    if (empty($username) || empty($email) || empty($password)) {
        echo json_encode(["success" => false, "message" => "Data tidak lengkap"]);
        exit();
    }

    // Cek Email Kembar
    $cek = mysqli_query($connect, "SELECT * FROM users WHERE email='$email'");
    if (mysqli_num_rows($cek) > 0) {
        echo json_encode(["success" => false, "message" => "Email sudah terdaftar"]);
        exit();
    }

    // Hash Password
    $hashed_pass = md5($password);

    // INSERT dengan ROLE = 'admin'
    $query = "INSERT INTO users (username, email, password, phone, address, role) 
              VALUES ('$username', '$email', '$hashed_pass', '$phone', '$address', 'admin')";

    if (mysqli_query($connect, $query)) {
        echo json_encode(["success" => true, "message" => "Admin baru berhasil ditambahkan!"]);
    } else {
        echo json_encode(["success" => false, "message" => "Gagal: " . mysqli_error($connect)]);
    }
}
?>