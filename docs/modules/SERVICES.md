# Modul Services (Backend Integration)

Modul ini menangani semua komunikasi antara aplikasi Flutter dengan Firebase.

## 1. Auth Service (`auth_service.dart`)
- **Registrasi**: Menyimpan nama, email, role, dan gender ke Firestore.
- **Login**: Autentikasi Firebase dan pengambilan role pengguna (Admin/Driver/Customer).
- **Reset Password**: Mengirim link pemulihan ke email pengguna.
- **Update Profile**: Mengubah data nama dan telepon dengan validasi.

## 2. Booking Service (`booking_service.dart`)
- **Real-time Seats**: Menggunakan `Stream<Map<int, String>>` untuk memantau kursi yang sudah dipesan beserta gender pemesannya secara langsung.
- **Create Booking**: Menyimpan data transaksi termasuk daftar penumpang, total harga, dan status pembayaran.
