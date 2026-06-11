# Aturan Validasi dan Keamanan Input

Aplikasi menerapkan validasi berlapis untuk memastikan integritas data.

## 1. Validasi Email & Password
- Menggunakan Regex `^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$` untuk format email.
- Password minimal 6 karakter.
- Tombol "Show/Hide Password" untuk kenyamanan pengguna.

## 2. Pembatasan Input Teks
- **Nama**: Hanya menerima huruf dan spasi (menggunakan `FilteringTextInputFormatter`). Minimal 3 karakter.
- **Telepon**: Hanya menerima angka. Panjang wajib antara 10 sampai 13 digit.

## 3. Logika Gender
- Gender dipilih saat registrasi (Laki-laki/Perempuan).
- Data gender ini digunakan secara otomatis untuk mewarnai kursi saat pemilihan, memudahkan identifikasi area penumpang.
