<?php
/**
 * File: koneksi.php
 * Lokasi: C:\xampp\htdocs\car_cemeng_api\koneksi.php
 */

// Header agar Flutter bisa mengakses API ini (CORS)
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Konfigurasi Database XAMPP
$host = "localhost";    // Tetap localhost karena PHP & MySQL berada di satu komputer
$user = "root";         // Username default XAMPP
$pass = "";             // Password default XAMPP biasanya kosong
$db   = "car_cemeng_db";   // Pastikan nama database ini sama dengan yang ada di phpMyAdmin
$port = 3307;           // Port MySQL yang Anda gunakan

// Membuat koneksi dengan menyertakan port khusus
$connect = mysqli_connect($host, $user, $pass, $db, $port);

// Cek koneksi
if (!$connect) {
    // Jika gagal, kirimkan pesan error dalam format JSON
    echo json_encode([
        "success" => false,
        "message" => "Koneksi ke database gagal: " . mysqli_connect_error()
    ]);
    exit;
}

// Jika berhasil (Opsional: jangan echo apapun agar tidak merusak format JSON di file API lain)
?>