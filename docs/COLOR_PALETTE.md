# Panduan Kode Warna & Skema Desain - SVARGADWIPA

Dokumen ini berisi rincian kode warna (Hex & Flutter Palette) yang digunakan di setiap layar aplikasi untuk keperluan desain.

## 1. Warna Utama (Brand Colors)
Warna-warna ini adalah identitas utama aplikasi yang didefinisikan di `main.dart`.
- **Primary Deep Blue**: `#154C79` (Digunakan untuk Button Utama, Header, dan Identitas Brand).
- **Scaffold Background**: `#F5F6F8` (Abu-abu sangat muda untuk latar belakang layar agar terlihat bersih).
- **Secondary Orange**: `Colors.orange` / `#FF9800` (Digunakan untuk harga, badge promo, dan aksen perhatian).

---

## 2. Layar Pelanggan (Customer Screens)

### A. Login & Registrasi
- **Background**: `#154C79` (Warna brand penuh).
- **Input Card**: `#FFFFFF` (Putih bersih).
- **Hint Text**: `Colors.grey` / `#9E9E9E`.
- **Error Message**: `Colors.red` / `#F44336`.

### B. Pemilihan Kursi (Seat Selection)
Warna ini krusial untuk logika gender:
- **Tersedia (Available)**: `#E8F5E9` (`Colors.green[50]`).
- **Terpilih - User Perempuan**: `#E91E63` (`Colors.pink[500]`).
- **Terpilih - User Laki-laki**: `#2196F3` (`Colors.blue[500]`).
- **Sudah Dipesan - Perempuan**: `#F8BBD0` (`Colors.pink[200]`).
- **Sudah Dipesan - Laki-laki**: `#BBDEFB` (`Colors.blue[200]`).
- **Border Kursi**: `#E0E0E0` (`Colors.grey[300]`).

### C. Tiket & Pembayaran
- **Status Paid (Lunas)**: Background `#E8F5E9`, Teks `#2E7D32` (`Colors.green[800]`).
- **Summary Box**: `#E3F2FD` (`Colors.blue[50]`) dengan Border `#BBDEFB`.
- **Success Icon**: `Colors.green` / `#4CAF50`.

---

## 3. Layar Manajemen (Dashboards)

### A. Admin Dashboard (Tema Merah)
- **AppBar**: `#D32F2F` (`Colors.red[700]`).
- **Icon Menu**: Beragam untuk navigasi cepat:
  - Destinasi: Orange.
  - Armada: Blue.
  - Harga: Green.
  - Laporan: Purple.

### B. Driver Dashboard (Tema Biru)
- **AppBar & Header**: `#1565C0` (`Colors.blue[800]`).
- **Card Stats**: `#FFFFFF` dengan Shadow halus (Opacity 0.05 Black).
- **Icon Menu**: Teal, Indigo, Orange, Blue.

---

## 4. Tipografi & Elemen UI
- **Teks Utama**: `#212121` (Hampir hitam).
- **Teks Sekunder**: `#757575` (Abu-abu sedang).
- **Shadow**: `Colors.black.withOpacity(0.05)` (Soft shadow untuk card).
- **Radius Sudut (BorderRadius)**: Rata-rata menggunakan `12.0` hingga `16.0` untuk tampilan modern yang membulat.
