import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TicketDetailScreen extends StatelessWidget { //kelas tiket detail
  final Map<String, dynamic> ticketData;
  final String ticketId;

  //menerima parameter (ticketData dan ticketId) memberikan informasi tiket yang dipilih
  const TicketDetailScreen({ //konstruktor untuk kirim data
    Key? key,
    required this.ticketData,
    required this.ticketId,
  }) : super(key: key);

  //mengambil informasi terkait tiket dari ticketData, memastikan bahwa jika ada data yang tidak ada (null),diberikan nilai default
  @override
  Widget build(BuildContext context) {
    final fromCity = ticketData['fromCity'] ?? 'Unknown';
    final toCity = ticketData['toCity'] ?? 'Unknown';
    final isWisata = ticketData['isWisata'] ?? false;
    final departTime = ticketData['departTime'] ?? '--:--';
    final arriveTime = ticketData['arriveTime'] ?? '--:--';
    final status = ticketData['status'] ?? 'Unknown';
    final seats = List<int>.from(ticketData['seats'] ?? []);
    final passengers = List<Map<String, dynamic>>.from(ticketData['passengers'] ?? []);
    final totalPrice = ticketData['totalPrice']?.toString() ?? '0';


    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Detail Tiket'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTicketHeader(fromCity, toCity, status, isWisata), //menampilkan header tiket, mencakup informasi
            const SizedBox(height: 24),
            _buildTripInfo(departTime, arriveTime, seats), //menampilkan informasi perjalanan
            const SizedBox(height: 24),
            _buildQrSection(ticketId),
            const SizedBox(height: 24),
            _buildPassengerList(passengers), //menampilkan daftar penumpang
            const SizedBox(height: 24),
            _buildPaymentInfo(totalPrice), //menampilkan informasi pembayaran
          ],
        ),
      ),
    );
  }

  //menampilkan informasi tiket. menerima empat parameter:
  Widget _buildTicketHeader(String from, String to, String status, bool isWisata) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration( //ui container
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row( //menampilkan dua elemen secara berdampingan
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ID Tiket:',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              Chip(
                label: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    color: status == 'paid' ? Colors.green[800] : Colors.grey[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: status == 'paid' ? Colors.green[100] : Colors.grey[200],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            ticketId,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          // jika mengenai paket wisata detail akan ditampilkan
          const Divider(height: 32),
          if (isWisata)
            Column(
              children: [
                const Text(
                  "Paket Wisata",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  to,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            )
            //informasi keberangkatan & tujuan
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCityColumn(from, "Keberangkatan"),
                const Icon(Icons.arrow_forward_rounded, color: Colors.blue, size: 32),
                _buildCityColumn(to, "Tujuan"),
              ],
            ),
        ],
      ),
    );
  }
  //ui nama kota & tujuan
  Widget _buildCityColumn(String city, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          city,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }
  //tampilan informasi perjalanan tiket dalam sebuah Container
  Widget _buildTripInfo(String departTime, String arriveTime, List<int> seats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      //icon label
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(Icons.schedule, 'Berangkat', departTime),
          _buildInfoItem(Icons.event_seat, 'Kursi', seats.join(', ')),
          _buildInfoItem(Icons.schedule, 'Tiba', arriveTime),
        ],
      ),
    );
  }

  //
  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue[300]),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildQrSection(String ticketId) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "QR Tiket",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Center(
            child: QrImageView(
              data: ticketId,
              version: QrVersions.auto,
              size: 200.0,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Tunjukkan QR ini kepada petugas",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  //container daftar penumpang
  Widget _buildPassengerList(List<Map<String, dynamic>> passengers) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      // daftar penumpang
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              "Daftar Penumpang",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          //
          const Divider(height: 1),
          ListView.separated( //menampilkan elemen-elemen dalam daftar dengan pemisah di antara setiap item.
            shrinkWrap: true,//menampilkan item-item, tanpa memperluas seluruh layar.
            physics: const NeverScrollableScrollPhysics(),
            itemCount: passengers.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final passenger = passengers[index];
              final seat = passenger['seat'];
              final name = passenger['name'] ?? 'Unknown';
              final phone = passenger['phone'] ?? '-';

              //memberikan elemen visual yang menarik nomor kursi,menampilkan nama,nomor telepon
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue[50],
                  child: Text(
                    "$seat",
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),//nama bold
                subtitle: Text(phone),
              );
            },
          ),
        ],
      ),
    );
  }
  //total pembayaran
  Widget _buildPaymentInfo(String totalPrice) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Total Pembayaran",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            "Rp $totalPrice",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}
