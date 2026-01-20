<?php
include 'koneksi.php';
header("Content-Type: application/json");

// 1. Hitung Total Pendapatan (Hanya yang statusnya 'selesai')
$queryIncome = "SELECT SUM(total_harga) as total_uang FROM pesanan WHERE status='selesai'";
$resultIncome = mysqli_query($connect, $queryIncome);
$rowIncome = mysqli_fetch_assoc($resultIncome);
$pendapatan = $rowIncome['total_uang'] ?? 0;

// 2. Hitung Jumlah Pesanan per Status
$queryCount = "SELECT status, COUNT(*) as jumlah FROM pesanan GROUP BY status";
$resultCount = mysqli_query($connect, $queryCount);

// Default nilai 0
$stats = [
    'pending' => 0,
    'konfirmasi' => 0,
    'selesai' => 0,
    'batal' => 0,
    'batal_user' => 0,
    'batal_admin' => 0
];

while($row = mysqli_fetch_assoc($resultCount)) {
    $stats[$row['status']] = $row['jumlah'];
}

// Gabungkan semua jenis pembatalan jadi satu angka
$total_batal = $stats['batal'] + $stats['batal_user'] + $stats['batal_admin'];

echo json_encode([
    "success" => true,
    "data" => [
        "pendapatan" => $pendapatan,
        "total_selesai" => $stats['selesai'],
        "total_proses" => $stats['konfirmasi'],
        "total_pending" => $stats['pending'],
        "total_batal" => $total_batal
    ]
]);
?>