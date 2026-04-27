import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trip_model.dart';

class TripService {
  final CollectionReference _tripsCollection =
      FirebaseFirestore.instance.collection('trips');

  // Get all trips
  Stream<List<Trip>> getTrips() {
    return _tripsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Trip.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  // Get featured trips
  Stream<List<Trip>> getFeaturedTrips() {
    return _tripsCollection
        .where('isFeatured', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Trip.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  // Add a new trip
  Future<void> addTrip(Trip trip) {
    return _tripsCollection.add(trip.toFirestore());
  }

  // Update a trip
  Future<void> updateTrip(Trip trip) {
    return _tripsCollection.doc(trip.id).update(trip.toFirestore());
  }

  // Delete a trip
  Future<void> deleteTrip(String id) {
    return _tripsCollection.doc(id).delete();
  }
}
