import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/route_model.dart';

class RouteService {
  final CollectionReference _routesCollection =
      FirebaseFirestore.instance.collection('routes');

  // Get all routes
  Stream<List<TravelRoute>> getRoutes() {
    return _routesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return TravelRoute.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  // Add a new route
  Future<void> addRoute(TravelRoute route) {
    return _routesCollection.add(route.toFirestore());
  }

  // Update a route
  Future<void> updateRoute(TravelRoute route) {
    return _routesCollection.doc(route.id).update(route.toFirestore());
  }

  // Delete a route
  Future<void> deleteRoute(String id) {
    return _routesCollection.doc(id).delete();
  }
}
