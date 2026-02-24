import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/route_model.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Listen to booked seats for a specific route
  Stream<List<int>> getBookedSeatsStream(String routeId) {
    return _firestore
        .collection('bookings')
        .where('routeId', isEqualTo: routeId)
        .where('status', isEqualTo: 'paid')
        .snapshots()
        .map((snapshot) {
      List<int> bookedSeats = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['seats'] != null) {
          bookedSeats.addAll(List<int>.from(data['seats']));
        }
      }
      return bookedSeats;
    });
  }

  // Save the booking
  Future<void> createBooking({
    required TravelRoute route,
    required List<int> selectedSeats,
    required List<String> passengerNames,
    required List<String> passengerPhones,
    required int totalPrice,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    // Combine passengers details for easier querying
    List<Map<String, dynamic>> passengers = [];
    for (int i = 0; i < selectedSeats.length; i++) {
      passengers.add({
        'seat': selectedSeats[i],
        'name': passengerNames[i],
        'phone': passengerPhones[i],
      });
    }

    await _firestore.collection('bookings').add({
      'userId': user.uid,
      'routeId': route.id,
      'fromCity': route.fromCity,
      'toCity': route.toCity,
      'departTime': route.departTime,
      'arriveTime': route.arriveTime,
      'seats': selectedSeats,
      'passengers': passengers,
      'totalPrice': totalPrice,
      'status': 'paid',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
