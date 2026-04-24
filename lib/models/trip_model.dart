class Trip { //kelas trip
  final String title;
  final String image;
  final String price;
  final double rating;

  Trip({ //konstruktor
    required this.title,
    required this.image,
    required this.price,
    required this.rating,
  });
}

// Dummy Data (mendefinisikan model perjalanan)
final List<Trip> trips = [
  Trip(
      title: 'Trip to Bali',
      image: 'https://images.unsplash.com/photo-1537996194471-e657df975ab4',
      price: 'Rp 300.000',
      rating: 4.8),
  Trip(
      title: 'Yogyakarta Tour',
      image: 'https://images.unsplash.com/photo-1584810359583-96fc3448beaa',
      price: 'Rp 250.000',
      rating: 4.5),
  Trip(
      title: 'Labuan Bajo',
      image: 'https://static.uc.ac.id/htb/2019/01/maxresdefault.jpg',
      price: 'Rp 1.500.000',
      rating: 5.0),
];