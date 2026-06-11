# Modul Customer Screens

Modul ini berisi layar yang berinteraksi langsung dengan pelanggan.

## 1. Pemilihan Kursi (`seat_selection_screen.dart`)
- **Layout Dinamis**: Menampilkan 7 kursi (layout 1-3-3) untuk Travel dan 19 kursi (layout 2-3-4-3-3-4) untuk Wisata.
- **Warna Berbasis Gender**: 
  - Hijau: Tersedia.
  - Pink: Terpilih/Dipesan oleh Perempuan.
  - Biru: Terpilih/Dipesan oleh Laki-laki.

## 2. Data Penumpang (`passenger_details_screen.dart`)
- Input nama dan telepon untuk setiap kursi yang dipilih.
- Memiliki validasi ketat (Nama: Huruf saja, Telepon: Angka 10-13 digit).

## 3. Pembayaran (`payment_screen.dart`)
- Menampilkan QRIS untuk simulasi pembayaran.
- **Success Card**: Popup animasi "Pemesanan Berhasil" setelah transaksi sukses.

## 4. Tiket (`booked_ticket_screen.dart` & `ticket_detail_screen.dart`)
- Menampilkan daftar tiket yang dibeli.
- Khusus Wisata, hanya menampilkan nama Paket Wisata sebagai judul tiket.
