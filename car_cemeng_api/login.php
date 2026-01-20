<?php
include 'koneksi.php';
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $json = file_get_contents('php://input');
    $data = json_decode($json, true);

    $email = isset($data['email']) ? $data['email'] : '';
    $password = isset($data['password']) ? $data['password'] : '';

    if (empty($email) || empty($password)) {
        echo json_encode(["success" => false, "message" => "Email dan Password wajib diisi"]);
        exit();
    }

    $hashed_password = md5($password);
    $query = "SELECT * FROM users WHERE email = '$email' AND password = '$hashed_password'";
    $result = mysqli_query($connect, $query);

    if (mysqli_num_rows($result) > 0) {
        $row = mysqli_fetch_assoc($result);
        echo json_encode([
            "success" => true,
            "message" => "Login Berhasil",
            "user" => [
                "id" => $row['id'],
                "username" => $row['username'],
                "email" => $row['email'],
                "phone" => $row['phone'],
                "address" => $row['address'],
                "role" => $row['role'] // <--- TAMBAHAN PENTING INI
            ]
        ]);
    } else {
        echo json_encode(["success" => false, "message" => "Email atau Password salah!"]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Metode salah"]);
}
?>