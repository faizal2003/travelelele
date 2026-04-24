class TravelRoute {
  final String id; //properti
  final String fromCity;
  final String toCity;
  final String departTime;
  final String arriveTime;
  final String price;
  final int seatsAvailable;
  final bool isWisata;

  TravelRoute({ //konstruktor
    required this.id,
    required this.fromCity,
    required this.toCity,
    required this.departTime,
    required this.arriveTime,
    required this.price,
    required this.seatsAvailable,
    this.isWisata = false,
  });
}

// Dummy Data mewakili berbagai rute perjalanan
final List<TravelRoute> dummyRoutes = [
  TravelRoute(
    id: '1',
    fromCity: 'Madiun',
    toCity: 'Surabaya',
    departTime: '01:00',
    arriveTime: '04:30',
    price: 'Rp 100.000',
    seatsAvailable: 5,
  ),
  TravelRoute(
    id: '2',
    fromCity: 'Surabaya',
    toCity: 'Madiun',
    departTime: '19:30',
    arriveTime: '22:15',
    price: 'Rp 135.000',
    seatsAvailable: 2,
  ),
  TravelRoute(
    id: '3',
    fromCity: 'Madiun',
    toCity: 'Yogyakarta',
    departTime: '11:00',
    arriveTime: '14:30',
    price: 'Rp 100.000',
    seatsAvailable: 8,
  ),
  TravelRoute(
    id: '4',
    fromCity: 'Yogyakarta',
    toCity: 'Madiun',
    departTime: '15:00',
    arriveTime: '18:30',
    price: 'Rp 105.000',
    seatsAvailable: 4,
  ),
  TravelRoute(
    id: '5',
    fromCity: 'Madiun',
    toCity: 'Malang',
    departTime: '15:00',
    arriveTime: '18:30',
    price: 'Rp 105.000',
    seatsAvailable: 4,
  ),
  TravelRoute(
    id: '6',
    fromCity: 'Malang',
    toCity: 'Madiun',
    departTime: '15:00',
    arriveTime: '18:30',
    price: 'Rp 105.000',
    seatsAvailable: 4,
  ),
];
