import 'package:flutter/material.dart';

class TicketDetailScreen extends StatelessWidget {
  final Map<String, dynamic> ticketData;
  final String ticketId;

  const TicketDetailScreen({
    Key? key,
    required this.ticketData,
    required this.ticketId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fromCity = ticketData['fromCity'] ?? 'Unknown';
    final toCity = ticketData['toCity'] ?? 'Unknown';
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
            _buildTicketHeader(fromCity, toCity, status),
            const SizedBox(height: 24),
            _buildTripInfo(departTime, arriveTime, seats),
            const SizedBox(height: 24),
            _buildPassengerList(passengers),
            const SizedBox(height: 24),
            _buildPaymentInfo(totalPrice),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketHeader(String from, String to, String status) {
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
          Row(
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
          const Divider(height: 32),
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
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: passengers.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final passenger = passengers[index];
              final seat = passenger['seat'];
              final name = passenger['name'] ?? 'Unknown';
              final phone = passenger['phone'] ?? '-';

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
                title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(phone),
              );
            },
          ),
        ],
      ),
    );
  }

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
