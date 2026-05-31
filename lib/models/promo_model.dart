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

  /// Calculates the discounted price and returns it as a formatted Rupiah string.
  static String calculateDiscountedPrice(String originalPrice, String discount) {
    try {
      int price = int.parse(originalPrice.replaceAll(RegExp(r'[^0-9]'), ''));
      if (discount.contains('%')) {
        int percent = int.parse(discount.replaceAll(RegExp(r'[^0-9]'), ''));
        int discounted = (price * (100 - percent) / 100).round();
        return formatRupiah(discounted);
      } else {
        int amount = int.parse(discount.replaceAll(RegExp(r'[^0-9]'), ''));
        int discounted = price - amount;
        return formatRupiah(discounted > 0 ? discounted : 0);
      }
    } catch (e) {
      return originalPrice;
    }
  }

  static String formatRupiah(int amount) {
    String formatted = amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return "Rp $formatted";
  }
}

