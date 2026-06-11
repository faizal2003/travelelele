# Modul Data Models

Modul ini mendefinisikan struktur data yang digunakan di seluruh aplikasi untuk memastikan konsistensi tipe data.

## 1. Route Model (`route_model.dart`)
Digunakan untuk data perjalanan travel reguler dan rute wisata.
- **`isWisata`**: Boolean penting yang menentukan layout kursi (19 vs 7 kursi) dan format tampilan di tiket.
- **`toCity`**: Menyimpan nama kota tujuan (untuk travel) atau nama paket (untuk wisata).

## 2. Trip Model (`trip_model.dart`)
Digunakan khusus untuk tampilan katalog di layar "Paket Wisata".
- Menyimpan informasi visual seperti gambar (URL), rating, dan harga paket.
