import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ticket_detail_screen.dart'; // Import the newly created detail screen

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
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            // Because Firestore requires an index when ordering alongside a where query on different fields,
            // we'll handle the case where the index isn't ready.
            if (snapshot.error.toString().contains('FAILED_PRECONDITION')) {
              // Fallback query without sorting if index is missing
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

  Widget _buildTicketList(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    final bookings = snapshot.data?.docs ?? [];

    if (bookings.isEmpty) {
      return const Center(child: Text('No tickets found.'));
    }

    // Build a list of tickets
    return ListView.builder(
      itemCount: bookings.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final doc = bookings[index];
        final data = doc.data() as Map<String, dynamic>;

        // Extract fields based on your Firestore structure
        final fromCity = data['fromCity'] ?? 'Unknown';
        final toCity = data['toCity'] ?? 'Unknown';
        final isWisata = data['isWisata'] ?? false;
        final departTime = data['departTime'] ?? '--:--';
        final arriveTime = data['arriveTime'] ?? '--:--';
        final status = data['status'] ?? 'Unknown';
        final seats = List<int>.from(data['seats'] ?? []);

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isWisata ? toCity : '$fromCity → $toCity',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
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
