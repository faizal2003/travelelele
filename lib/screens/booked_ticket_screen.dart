import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ticket_detail_screen.dart'; // Import the newly created detail screen

class TicketBookedScreen extends StatelessWidget {
  const TicketBookedScreen({Key? key}) : super(key: key);

  //mengambil ID pengguna yang sedang login dari Firebase Authentication (uid).
  @override
  Widget build(BuildContext context) {
    // Get the current logged-in user's ID
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      return const Center(child: Text("Please log in to view tickets."));
    }
    return Scaffold(
      //untuk judul tiket
      appBar: AppBar(
        title: const Text('Tickets'),
        centerTitle: true,
      ),

      //Menampilkan daftar pemesanan (booking) urut terbaru
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('userId', isEqualTo: currentUserId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {

          if (snapshot.hasError) {
            //menangani error yang mungkin terjadi, indeks untuk melakukan pengurutan data

            if (snapshot.error.toString().contains('FAILED_PRECONDITION')) {
              //Jika indeks yang diperlukan belum tersedia (dengan kesalahan FAILED_PRECONDITION),
              // aplikasi akan menampilkan data tanpa pengurutan terlebih dahulu sebagai alternatif.

              //Menampilkan daftar pemesanan (booking) tanpa pengurutan
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('bookings')
                    .where('userId', isEqualTo: currentUserId)
                    .snapshots(),
                builder: (context, fallbackSnapshot) {
                  return _buildTicketList(context, fallbackSnapshot);
                },
              );
            }
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return _buildTicketList(context, snapshot);
        },
      ),
    );
  }
//pengambilan data dari Firestore untuk menampilkan daftar tiket yang dipesan oleh pengguna yang sedang login.

  //cek koneksi, nunggu data dari firestore
  Widget _buildTicketList(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    // ambil data booking dari firestore
    final allBookings = snapshot.data?.docs ?? [];
    final now = DateTime.now();

    // Filter out expired tickets (passed arrival time)
    final bookings = allBookings.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final date = data['date'];
      final arriveTime = data['arriveTime'];

      if (date == null || arriveTime == null) return true;

      try {
        final arrivalDateTime = DateTime.parse("$date $arriveTime:00");
        return arrivalDateTime.isAfter(now);
      } catch (e) {
        return true; // Keep if parsing fails
      }
    }).toList();

    //jika data kosong- no tiket
    if (bookings.isEmpty) {
      return const Center(child: Text('No active tickets found.'));
    }

    //menampilkan daftar tiket
    return ListView.builder(
      itemCount: bookings.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        //ambil tiket data firestore
        final doc = bookings[index];
        final data = doc.data() as Map<String, dynamic>;

        // mengekstrak data dari firestore
        final fromCity = data['fromCity'] ?? 'Unknown';
        final toCity = data['toCity'] ?? 'Unknown';
        final isWisata = data['isWisata'] ?? false;
        final date = data['date'] ?? 'Unknown Date';
        final departTime = data['departTime'] ?? '--:--';
        final arriveTime = data['arriveTime'] ?? '--:--';
        final status = data['status'] ?? 'Unknown';
        final seats = List<int>.from(data['seats'] ?? []);

        //membuat tampilan daftar tiket dalam bentuk kartu yang dapat diketuk.
        //Saat kartu diklik, pengguna diarahkan ke layar detail tiket
        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TicketDetailScreen(
                    ticketId: doc.id,
                    ticketData: data,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              //Column & row agar menyusun elemen terstruktur.
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //menampilkan informasi tentang kota asal dan tujuan atau hanya kota tujuan.
                      Text(
                        isWisata ? toCity : '$fromCity → $toCity',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),

                      //menampilkan status tiket dengan warna yang berbeda untuk menunjukkan status pembayaran (paid).
                      Chip(
                        label: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            color: status == 'paid'
                                ? Colors.green[800]
                                : Colors.grey[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: status == 'paid'
                            ? Colors.green[100]
                            : Colors.grey[200],
                      ),
                    ],
                  ),
                  const Divider(),//rute,status/ waktu, kursi
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoColumn('Date', date),
                      _buildInfoColumn('Depart', departTime),//waktu keberangkatan
                      _buildInfoColumn('Arrive', arriveTime),//waktu sampai
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildInfoColumn('Seats', seats.join(', ')),//daftar kursi yang dipilih
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper widget to keep the code clean
  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
