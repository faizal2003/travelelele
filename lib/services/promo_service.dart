import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/promo_model.dart';

class PromoService {
  final CollectionReference _promosCollection =
      FirebaseFirestore.instance.collection('promos');

  // Get all promos
  Stream<List<Promo>> getPromos() {
    return _promosCollection.orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Promo.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  // Add a new promo
  Future<void> addPromo(Promo promo) {
    return _promosCollection.add(promo.toFirestore());
  }

  // Update a promo
  Future<void> updatePromo(Promo promo) {
    return _promosCollection.doc(promo.id).update(promo.toFirestore());
  }

  // Delete a promo
  Future<void> deletePromo(String id) {
    return _promosCollection.doc(id).delete();
  }
}
