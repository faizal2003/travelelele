import 'package:cloud_firestore/cloud_firestore.dart';

class Promo {
  final String id;
  final String title;
  final String image;
  final String description;
  final String discount;
  final String? wisataId;

  Promo({
    required this.id,
    required this.title,
    required this.image,
    required this.description,
    required this.discount,
    this.wisataId,
  });

  factory Promo.fromFirestore(Map<String, dynamic> data, String id) {
    return Promo(
      id: id,
      title: data['title'] ?? '',
      image: data['image'] ?? '',
      description: data['description'] ?? '',
      discount: data['discount'] ?? '',
      wisataId: data['wisataId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'image': image,
      'description': description,
      'discount': discount,
      'wisataId': wisataId,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
