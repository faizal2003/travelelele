import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/route_model.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // menyimpan kursi yang sudah dipesan, dengan gender
  Stream<Map<int, String>> getBookedSeatsWithGenderStream(String routeId) {
    return _firestore //ambil data booking di firestore
        .collection('bookings')
        .where('routeId', isEqualTo: routeId) //Menyaring data hanya mengambil pemesanan
        .where('status', isEqualTo: 'paid')//ambil paid
        .snapshots()
        .map((snapshot) {
      Map<int, String> bookedSeats = {}; //Menyimpan nomor kursi dipesan dan gender pengguna
      for (var doc in snapshot.docs) { //iterasi pengulangan berisi pemesanan kursi
        final data = doc.data(); //menyimpan informasi pemesanan
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

  // Get a specific booking stream
  Stream<DocumentSnapshot> getBookingStream(String bookingId) {
    return _firestore.collection('bookings').doc(bookingId).snapshots();
  }

  // Update booking status
  Future<void> updateBookingStatus(String bookingId, String status) {
    return _firestore.collection('bookings').doc(bookingId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Create a pending booking
  Future<String> createBooking({
    required TravelRoute route,
    required List<int> selectedSeats,
    required List<String> passengerNames,
    required List<String> passengerPhones,
    required int totalPrice,
    String status = 'pending', // Default to pending for Webhook flow
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userGender = userDoc.data()?['gender'] ?? 'Laki-laki';

    List<Map<String, dynamic>> passengers = [];
    for (int i = 0; i < selectedSeats.length; i++) {
      passengers.add({
        'seat': selectedSeats[i],
        'name': passengerNames[i],
        'phone': passengerPhones[i],
      });
    }

    final docRef = await _firestore.collection('bookings').add({
      'userId': user.uid,
      'userGender': userGender,
      'routeId': route.id,
      'fromCity': route.fromCity,
      'toCity': route.toCity,
      'date': route.date,
      'departTime': route.departTime,
      'arriveTime': route.arriveTime,
      'isWisata': route.isWisata,
      'seats': selectedSeats,
      'passengers': passengers,
      'totalPrice': totalPrice,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  // Validasi dan gunakan tiket (invalidate)
  Future<Map<String, dynamic>> validateAndUseTicket(String ticketId) async {
    final docRef = _firestore.collection('bookings').doc(ticketId);
    final doc = await docRef.get();

    if (!doc.exists) {
      throw Exception("Tiket tidak ditemukan");
    }

    final data = doc.data()!;
    final status = data['status'] ?? 'Unknown';

    if (status != 'paid') {
      throw Exception("Tiket sudah tidak valid atau sudah digunakan (Status: $status)");
    }

    // Update status menjadi 'used' untuk menginvalidasi tiket
    final user = _auth.currentUser;
    await docRef.update({
      'status': 'used',
      'usedAt': FieldValue.serverTimestamp(),
      'driverId': user?.uid,
    });

    return data;
  }
}
