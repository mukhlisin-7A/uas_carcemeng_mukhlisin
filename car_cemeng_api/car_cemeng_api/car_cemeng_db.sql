-- phpMyAdmin SQL Dump
-- version 4.8.5
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3307
-- Waktu pembuatan: 19 Jan 2026 pada 11.53
-- Versi server: 10.1.38-MariaDB
-- Versi PHP: 7.3.2

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `car_cemeng_db`
--

-- --------------------------------------------------------

--
-- Struktur dari tabel `mobil`
--

CREATE TABLE `mobil` (
  `id_mobil` int(11) NOT NULL,
  `merk` varchar(50) NOT NULL,
  `model` varchar(100) NOT NULL,
  `nomor_plat` varchar(20) NOT NULL,
  `harga_sewa` decimal(10,2) NOT NULL,
  `tipe_mobil` varchar(50) NOT NULL,
  `transmisi` varchar(20) NOT NULL,
  `bahan_bakar` varchar(20) NOT NULL,
  `jumlah_kursi` int(2) NOT NULL,
  `tahun_buat` int(4) NOT NULL,
  `deskripsi` text,
  `gambar` varchar(255) DEFAULT NULL,
  `status` enum('tersedia','disewa','servis') DEFAULT 'tersedia',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data untuk tabel `mobil`
--

INSERT INTO `mobil` (`id_mobil`, `merk`, `model`, `nomor_plat`, `harga_sewa`, `tipe_mobil`, `transmisi`, `bahan_bakar`, `jumlah_kursi`, `tahun_buat`, `deskripsi`, `gambar`, `status`, `created_at`) VALUES
(1, 'toyota', 'avanza', 'r1234me', '200000.00', 'MPV', 'Manual', 'Bensin', 5, 2005, 'terkendali', '692ae97d18777.jpg', 'tersedia', '2025-11-27 05:27:50'),
(2, 'toyota', 'kijang', 'r1234me', '300000.00', 'SUV', 'Manual', 'Bensin', 7, 20012, 'aman', '692aeb16f3d7a.jpg', 'tersedia', '2025-11-29 12:40:35');

-- --------------------------------------------------------

--
-- Struktur dari tabel `pesan`
--

CREATE TABLE `pesan` (
  `id_pesan` int(11) NOT NULL,
  `id_user` int(11) NOT NULL,
  `isi_pesan` text NOT NULL,
  `balasan_admin` text,
  `waktu_kirim` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `waktu_balas` datetime DEFAULT NULL,
  `is_read` int(1) DEFAULT '0',
  `is_read_admin` int(1) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data untuk tabel `pesan`
--

INSERT INTO `pesan` (`id_pesan`, `id_user`, `isi_pesan`, `balasan_admin`, `waktu_kirim`, `waktu_balas`, `is_read`, `is_read_admin`) VALUES
(1, 2, 'p', 'Ada Yang biasa dibantu?', '2025-11-29 14:19:19', '2025-11-29 22:20:55', 1, 1),
(2, 2, 'cek', 'iya', '2025-11-29 15:21:54', '2025-11-29 22:24:45', 1, 1),
(3, 2, 'iya', NULL, '2025-11-29 15:25:12', NULL, 0, 1),
(4, 2, 'p', 'p', '2025-11-29 15:31:25', '2025-11-29 22:31:46', 1, 1),
(5, 2, 'p', 'cekcek', '2025-11-29 15:45:37', '2025-11-29 23:10:39', 1, 1),
(6, 2, 'p', 'p', '2025-11-29 15:48:38', '2025-11-29 22:49:02', 1, 1),
(7, 2, 'yoo', NULL, '2025-11-29 16:11:10', NULL, 0, 1);

-- --------------------------------------------------------

--
-- Struktur dari tabel `pesanan`
--

CREATE TABLE `pesanan` (
  `id_sewa` int(11) NOT NULL,
  `id_user` int(11) NOT NULL,
  `id_mobil` int(11) NOT NULL,
  `tgl_sewa` date NOT NULL,
  `tgl_kembali` date NOT NULL,
  `total_hari` int(11) NOT NULL,
  `total_harga` decimal(15,2) NOT NULL,
  `status` enum('pending','konfirmasi','selesai','batal') DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data untuk tabel `pesanan`
--

INSERT INTO `pesanan` (`id_sewa`, `id_user`, `id_mobil`, `tgl_sewa`, `tgl_kembali`, `total_hari`, `total_harga`, `status`, `created_at`) VALUES
(1, 2, 2, '2025-11-29', '2025-12-02', 3, '900000.00', 'selesai', '2025-11-29 13:48:45'),
(2, 2, 1, '2025-11-29', '2025-12-01', 2, '400000.00', 'batal', '2025-11-29 13:52:48'),
(3, 2, 1, '2025-11-29', '2025-12-03', 4, '800000.00', 'batal', '2025-11-29 14:58:27'),
(4, 2, 2, '2025-12-04', '2025-12-06', 2, '600000.00', 'batal', '2025-11-29 14:58:54'),
(5, 2, 2, '2025-11-29', '2025-12-03', 4, '1200000.00', 'selesai', '2025-11-29 15:05:51'),
(6, 2, 2, '2025-11-29', '2025-12-01', 2, '600000.00', 'selesai', '2025-11-29 15:39:56');

-- --------------------------------------------------------

--
-- Struktur dari tabel `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `address` text,
  `phone` varchar(20) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `role` enum('admin','user') NOT NULL DEFAULT 'user'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data untuk tabel `users`
--

INSERT INTO `users` (`id`, `username`, `email`, `password`, `address`, `phone`, `created_at`, `role`) VALUES
(1, 'user', 'user@gmail.com', 'e10adc3949ba59abbe56e057f20f883e', 'purwokerto', '234243243254352', '2025-11-27 04:49:42', 'admin'),
(2, 'biasa', 'biasa@gmail.com', 'e10adc3949ba59abbe56e057f20f883e', 'cilongok', '89329829080893', '2025-11-27 05:43:21', 'user'),
(3, 'admin1', 'admin1@gmail.com', 'e10adc3949ba59abbe56e057f20f883e', 'banyumas', '0848348974892423', '2025-11-29 15:11:32', 'admin');

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `mobil`
--
ALTER TABLE `mobil`
  ADD PRIMARY KEY (`id_mobil`);

--
-- Indeks untuk tabel `pesan`
--
ALTER TABLE `pesan`
  ADD PRIMARY KEY (`id_pesan`),
  ADD KEY `id_user` (`id_user`);

--
-- Indeks untuk tabel `pesanan`
--
ALTER TABLE `pesanan`
  ADD PRIMARY KEY (`id_sewa`),
  ADD KEY `id_user` (`id_user`),
  ADD KEY `id_mobil` (`id_mobil`);

--
-- Indeks untuk tabel `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `mobil`
--
ALTER TABLE `mobil`
  MODIFY `id_mobil` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT untuk tabel `pesan`
--
ALTER TABLE `pesan`
  MODIFY `id_pesan` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT untuk tabel `pesanan`
--
ALTER TABLE `pesanan`
  MODIFY `id_sewa` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT untuk tabel `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `pesan`
--
ALTER TABLE `pesan`
  ADD CONSTRAINT `pesan_ibfk_1` FOREIGN KEY (`id_user`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `pesanan`
--
ALTER TABLE `pesanan`
  ADD CONSTRAINT `pesanan_ibfk_1` FOREIGN KEY (`id_user`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `pesanan_ibfk_2` FOREIGN KEY (`id_mobil`) REFERENCES `mobil` (`id_mobil`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
