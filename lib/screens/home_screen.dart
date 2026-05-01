import 'package:flutter/material.dart';
import 'booked_ticket_screen.dart';
import 'travel_search_screen.dart';
import '../models/trip_model.dart';
import '../models/promo_model.dart';
import '../services/trip_service.dart';
import '../services/promo_service.dart';
import 'travel_list_screen.dart';
import 'detail_screen.dart';
import 'profile_screen.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeContent(),
    const TicketBookedScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFF154c79),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number),
            label: "Tickets",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final TripService tripService = TripService();
  final PromoService promoService = PromoService();

  String _calculateDiscountedPrice(String originalPrice, String discount) {
    try {
      int price = int.parse(originalPrice.replaceAll(RegExp(r'[^0-9]'), ''));
      if (discount.contains('%')) {
        int percent = int.parse(discount.replaceAll(RegExp(r'[^0-9]'), ''));
        int discounted = (price * (100 - percent) / 100).round();
        return _formatRupiah(discounted);
      } else {
        int amount = int.parse(discount.replaceAll(RegExp(r'[^0-9]'), ''));
        int discounted = price - amount;
        return _formatRupiah(discounted > 0 ? discounted : 0);
      }
    } catch (e) {
      return originalPrice;
    }
  }

  String _formatRupiah(int amount) {
    String formatted = amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return "Rp $formatted";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SVARGADWIPA"),
      ),
      body: StreamBuilder<List<Promo>>(
        stream: promoService.getPromos(),
        builder: (context, promoSnapshot) {
          final promos = promoSnapshot.data ?? [];
          
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Section (Featured Wisata)
                StreamBuilder<List<Trip>>(
                  stream: tripService.getFeaturedTrips(),
                  builder: (context, tripSnapshot) {
                    if (tripSnapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
                    }
                    final featured = tripSnapshot.data ?? [];
                    if (featured.isEmpty) {
                      return const SizedBox(height: 200, child: Center(child: Text("Belum ada konten unggulan")));
                    }
                    return _buildHeroSection(featured, promos);
                  },
                ),
                
                // Categories
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildCategoryCard(
                          context,
                          "Cari Travel",
                          Icons.directions_bus,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildCategoryCard(
                          context,
                          "Cari Wisata",
                          Icons.landscape,
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Promo Section
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Promo Special",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 180,
                  child: promos.isEmpty
                      ? const Center(child: Text("Belum ada promo."))
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: promos.length,
                          itemBuilder: (context, index) => _buildPromoCard(context, promos[index]),
                        ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroSection(List<Trip> featuredTrips, List<Promo> promos) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 200.0,
        autoPlay: true,
        enlargeCenterPage: false,
        viewportFraction: 1.0,
        autoPlayInterval: const Duration(seconds: 5),
      ),
      items: featuredTrips.map((trip) {
        // Find if this trip has an active promo
        final promo = promos.where((p) => p.wisataId == trip.id).firstOrNull;
        final String displayPrice = promo != null 
            ? _calculateDiscountedPrice(trip.price, promo.discount)
            : trip.price;

        return Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DetailScreen(trip: trip, promo: promo)),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    trip.image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            promo != null ? "Promo ${promo.discount}" : "Featured",
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          trip.title,
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            Text(
                              displayPrice,
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            if (promo != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                trip.price,
                                style: const TextStyle(
                                  color: Colors.white70, 
                                  fontSize: 12, 
                                  decoration: TextDecoration.lineThrough
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        if (title == "Cari Travel") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TravelSearchScreen()),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TravelListScreen()),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            const BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              radius: 24,
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoCard(BuildContext context, Promo promo) {
    return InkWell(
      onTap: () {
        if (promo.wisataId != null) {
          tripService.getTrips().first.then((trips) {
            final trip = trips.where((t) => t.id == promo.wisataId).firstOrNull;
            if (trip != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DetailScreen(trip: trip, promo: promo)),
              );
            }
          });
        }
      },
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                promo.image,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(promo.title, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
                        child: Text(promo.discount, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  Text(promo.description, style: const TextStyle(color: Colors.grey, fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

