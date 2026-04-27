class Trip { //kelas trip
  final String id;
  final String title;
  final String image;
  final String price;
  final bool isFeatured;

  Trip({ //konstruktor
    required this.id,
    required this.title,
    required this.image,
    required this.price,
    this.isFeatured = false,
  });

  factory Trip.fromFirestore(Map<String, dynamic> data, String id) {
    return Trip(
      id: id,
      title: data['title'] ?? '',
      image: data['image'] ?? '',
      price: data['price'] ?? '',
      isFeatured: data['isFeatured'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'image': image,
      'price': price,
      'isFeatured': isFeatured,
    };
  }
}

// Dummy Data (mendefinisikan model perjalanan)
final List<Trip> trips = [
  Trip(
      id: '1',
      title: 'Trip to Bali',
      image: 'https://images.unsplash.com/photo-1537996194471-e657df975ab4',
      price: 'Rp 300.000',
      isFeatured: true),
  Trip(
      id: '2',
      title: 'Yogyakarta Tour',
      image: 'https://images.unsplash.com/photo-1584810359583-96fc3448beaa',
      price: 'Rp 250.000',
      isFeatured: true),
  Trip(
      id: '3',
      title: 'Labuan Bajo',
      image: 'https://static.uc.ac.id/htb/2019/01/maxresdefault.jpg',
      price: 'Rp 1.500.000',
      isFeatured: true),
];