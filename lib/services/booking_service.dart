import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/route_model.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Listen to booked seats for a specific route with gender info
  Stream<Map<int, String>> getBookedSeatsWithGenderStream(String routeId) {
    return _firestore
        .collection('bookings')
        .where('routeId', isEqualTo: routeId)
        .where('status', isEqualTo: 'paid')
        .snapshots()
        .map((snapshot) {
      Map<int, String> bookedSeats = {};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final gender = data['userGender'] ?? 'Laki-laki';
        if (data['seats'] != null) {
          final seats = List<int>.from(data['seats']);
          for (var seat in seats) {
            bookedSeats[seat] = gender;
          }
        }
      }
      return bookedSeats;
    });
  }

  // Save the booking with user gender
  Future<void> createBooking({
    required TravelRoute route,
    required List<int> selectedSeats,
    required List<String> passengerNames,
    required List<String> passengerPhones,
    required int totalPrice,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    // Fetch user gender
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userGender = userDoc.data()?['gender'] ?? 'Laki-laki';

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
      'userGender': userGender,
      'routeId': route.id,
      'fromCity': route.fromCity,
      'toCity': route.toCity,
      'departTime': route.departTime,
      'arriveTime': route.arriveTime,
      'isWisata': route.isWisata,
      'seats': selectedSeats,
      'passengers': passengers,
      'totalPrice': totalPrice,
      'status': 'paid',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
