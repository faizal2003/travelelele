import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TicketBookedScreen extends StatelessWidget {
  const TicketBookedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the current logged-in user's ID
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      return const Center(child: Text("Please log in to view tickets."));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tickets'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Query the 'bookings' collection for this user
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('userId', isEqualTo: currentUserId)
        // Optional: Order by creation date if you indexed it
        // .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final bookings = snapshot.data!.docs;

          if (bookings.isEmpty) {
            return const Center(child: Text('No tickets found.'));
          }

          // Build a list of tickets
          return ListView.builder(
            itemCount: bookings.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final data = bookings[index].data() as Map<String, dynamic>;

              // Extract fields based on your Firestore structure
              final fromCity = data['fromCity'] ?? 'Unknown';
              final toCity = data['toCity'] ?? 'Unknown';
              final departTime = data['departTime'] ?? '--:--';
              final arriveTime = data['arriveTime'] ?? '--:--';
              final status = data['status'] ?? 'Unknown';
              final seats = List<int>.from(data['seats'] ?? []);

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$fromCity → $toCity',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Chip(
                            label: Text(
                              status.toUpperCase(),
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: status == 'paid'
                                ? Colors.green.shade100
                                : Colors.grey.shade200,
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoColumn('Depart', departTime),
                          _buildInfoColumn('Arrive', arriveTime),
                          _buildInfoColumn('Seats', seats.join(', ')),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
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