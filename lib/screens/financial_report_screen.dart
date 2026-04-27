import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FinancialReportScreen extends StatefulWidget {
  const FinancialReportScreen({super.key});

  @override
  State<FinancialReportScreen> createState() => _FinancialReportScreenState();
}

class _FinancialReportScreenState extends State<FinancialReportScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _formatRupiah(int amount) {
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text("Laporan Keuangan"),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('bookings').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final docs = snapshot.data?.docs ?? [];
          
          int totalRevenue = 0;
          int travelRevenue = 0;
          int wisataRevenue = 0;
          int totalBookings = docs.length;
          int travelCount = 0;
          int wisataCount = 0;

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final price = data['totalPrice'] ?? 0;
            final isWisata = data['isWisata'] ?? false;

            totalRevenue += price as int;
            if (isWisata) {
              wisataRevenue += price;
              wisataCount++;
            } else {
              travelRevenue += price;
              travelCount++;
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards
                _buildSummaryCard(
                  "Total Pendapatan", 
                  _formatRupiah(totalRevenue), 
                  Icons.payments, 
                  Colors.green
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildSmallSummaryCard(
                        "Travel", 
                        _formatRupiah(travelRevenue), 
                        "$travelCount Tiket",
                        Colors.blue
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSmallSummaryCard(
                        "Wisata", 
                        _formatRupiah(wisataRevenue), 
                        "$wisataCount Paket",
                        Colors.orange
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                const Text(
                  "Transaksi Terakhir",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                // Transaction List
                if (docs.isEmpty)
                  const Center(child: Text("Belum ada transaksi."))
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final date = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
                      final price = data['totalPrice'] ?? 0;
                      final isWisata = data['isWisata'] ?? false;
                      final route = "${data['fromCity']} → ${data['toCity']}";

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isWisata ? Colors.orange[50] : Colors.blue[50],
                            child: Icon(
                              isWisata ? Icons.landscape : Icons.directions_bus,
                              color: isWisata ? Colors.orange : Colors.blue,
                            ),
                          ),
                          title: Text(route, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text(DateFormat('dd MMM yyyy, HH:mm').format(date)),
                          trailing: Text(
                            _formatRupiah(price),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSmallSummaryCard(String title, String value, String subValue, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(subValue, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }
}
