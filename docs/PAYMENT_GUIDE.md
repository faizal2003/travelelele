# Panduan Integrasi Midtrans Core API (QRIS) & Webhook

Aplikasi ini menggunakan Midtrans Core API untuk pembayaran QRIS dengan arsitektur **Pre-Booking**. Booking dibuat di Firestore dengan status `pending` sebelum pembayaran dilakukan, kemudian diupdate secara otomatis melalui **Webhook**.

## 1. Flow Arsitektur
1.  **Frontend**: Membuat dokumen booking di Firestore dengan status `pending`. ID dokumen ini digunakan sebagai `order_id`.
2.  **Frontend**: Meminta URL gambar QR dari backend (`getQrisImageUrl`).
3.  **Backend**: Memanggil Midtrans `/v2/charge`.
4.  **Frontend**: Menampilkan QR dan mendengarkan (listening) perubahan status dokumen di Firestore.
5.  **Midtrans**: Mengirim HTTP Post (Webhook) ke backend Anda setelah user membayar.
6.  **Backend (Webhook)**: Memverifikasi tanda tangan (signature), lalu mengupdate status booking di Firestore menjadi `paid`.
7.  **Frontend**: Otomatis mendeteksi perubahan status ke `paid` dan menampilkan layar sukses.

## 2. Implementasi Webhook (Node.js/Express)

Endpoint ini harus didaftarkan di Dashboard Midtrans -> Settings -> Configuration -> **Payment Notification URL**.

```javascript
const crypto = require('crypto');
const admin = require('firebase-admin'); // Gunakan firebase-admin untuk update Firestore

app.post('/api/midtrans-webhook', async (req, res) => {
  const data = req.body;
  const serverKey = 'YOUR_MIDTRANS_SERVER_KEY';

  // 1. Verifikasi Signature Key (Keamanan)
  const hash = crypto.createHash('sha512')
    .update(data.order_id + data.status_code + data.gross_amount + serverKey)
    .digest('hex');

  if (hash !== data.signature_key) {
    return res.status(403).json({ message: 'Invalid Signature' });
  }

  // 2. Logika Update Firestore
  const orderId = data.order_id;
  const transactionStatus = data.transaction_status;
  const fraudStatus = data.fraud_status;

  let finalStatus = 'pending';

  if (transactionStatus == 'capture' || transactionStatus == 'settlement') {
    if (fraudStatus == 'accept') {
      finalStatus = 'paid';
    }
  } else if (transactionStatus == 'cancel' || transactionStatus == 'deny' || transactionStatus == 'expire') {
    finalStatus = transactionStatus; // 'cancel' atau 'expire'
  }

  try {
    // Update status di koleksi bookings Firestore
    await admin.firestore().collection('bookings').doc(orderId).update({
      status: finalStatus,
      midtrans_transaction_id: data.transaction_id,
      payment_type: data.payment_type,
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });

    res.status(200).send('OK');
  } catch (error) {
    console.error('Firestore Update Error:', error);
    res.status(500).send('Internal Server Error');
  }
});
```

## 3. Keuntungan Arsitektur Ini
*   **Keamanan Tinggi**: Verifikasi signature memastikan data benar-benar berasal dari Midtrans.
*   **Otomatisasi**: User tidak perlu menekan tombol apapun; aplikasi akan otomatis berpindah ke layar tiket begitu pembayaran sukses.
*   **Data Konsisten**: Menghindari "ghost bookings" karena status `pending` sudah tercatat di sistem sejak awal.

## 4. Setup Backend Node.js

Saya telah membuatkan template backend di folder `C:\Users\faiza\Documents\midtrans-backend\`. Ikuti langkah ini untuk menjalankannya:

1.  **Install Dependencies**:
    Buka terminal di folder backend dan jalankan:
    ```bash
    npm install
    ```

2.  **Konfigurasi Firebase Admin**:
    *   Buka [Firebase Console](https://console.firebase.google.com/).
    *   Pilih proyek Anda -> Project Settings -> **Service Accounts**.
    *   Klik **Generate New Private Key**.
    *   Simpan file JSON tersebut dengan nama `serviceAccountKey.json` di dalam folder `midtrans-backend/`.

3.  **Konfigurasi Environment**:
    Edit file `.env` di folder backend dan isi dengan Server Key & Client Key dari Dashboard Midtrans Anda.

4.  **Jalankan Server**:
    ```bash
    npm start
    ```

5.  **Expose ke Internet (Opsional untuk Testing Webhook)**:
    Jika Anda ingin mengetes Webhook dari komputer lokal, Anda bisa menggunakan **ngrok**:
    ```bash
    ngrok http 3000
    ```
    Lalu daftarkan URL ngrok tersebut di Dashboard Midtrans sebagai Notification URL (e.g., `https://xxxx.ngrok-free.app/api/midtrans-webhook`).

---
**Tips Keamanan:**
*   Pastikan `serviceAccountKey.json` dan `.env` masuk ke dalam `.gitignore`.
*   Gunakan environment variables untuk menyimpan kredensial sensitif di server production.
