import 'package:flutter/material.dart';
import 'booked_ticket_screen.dart';
import 'travel_search_screen.dart';
import '../models/trip_model.dart';
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
  int _currentIndex = 0;//menu

  final List<Widget> _screens = [
    const HomeContent(),//home
    const TicketBookedScreen(),//tiket
    const ProfileScreen(),//profile
  ];

  //menampilkan tiga item yang memungkinkan pengguna beralih (home,tiket,profil)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar( //navigasi
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFF154c79),//bottom dipilih warna biru
        unselectedItemColor: Colors.grey,//menu tdk dipilih berwarna abu
        items: const [

          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),//icon home
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

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SVARGADWIPA"),//judul layar svargadwipa
      ),
      //card pencarian
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroSection(),
            Padding( //jarak
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded( //memastikan katergori card lebarnya sama
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),//padding kanan kiri 16
              child: Text(
                "Promo Special",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            //menampilkan daftar perjalanan promo dalam bentuk kartu secara horizontal
            const SizedBox(height: 10),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,//digesar kanan-kiri
                padding: const EdgeInsets.only(left: 16),
                itemCount: trips.length,
                itemBuilder: (context, index) =>//yang akan ditampilkan
                    _buildPromoCard(context, trips[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //untuk gambar slider bagian atas
  Widget _buildHeroSection() {
    final List<Trip> featuredTrips = trips.take(3).toList();
  //hanya mengambil 3 perjalanan
    return CarouselSlider(//slide secara otomatis
      options: CarouselOptions(
        height: 200.0,
        autoPlay: true,
        enlargeCenterPage: false,//gambar akan sama semua
        viewportFraction: 1.0, // Full width
        autoPlayInterval: const Duration(seconds: 5),//otomatis slide waktu 5 detik
      ),

      items: featuredTrips.map((trip) {
        return Builder(
          builder: (BuildContext context) {
            return GestureDetector( //deteksi gestur pengguna
              onTap: () => Navigator.push( //navigasi layar ketika diketuk
                context,
                MaterialPageRoute(builder: (_) => DetailScreen(trip: trip)),
                //navigasi ke DetailScreen
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. The Image
                  Image.network(
                    trip.image, //menampilkan gambar yang diambil dari URL yang disediakan dalam trip image
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),

                  // 2. Dark Overlay Gradient (for readable text)
                  //menambahkan gradien gelap di atas gambar, memastikan teks yang diletakkan di atasnya lebih terbaca.
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

                  // 3. Text Content
                  // tulisan dalam gambar (featured).
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(//jarak teks
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(//warna
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "Featured",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),//untuk memberi jarak vertikal antara widget.
                        Text(
                          trip.title,//judul perjalanan.
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          trip.price,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
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

  Widget _buildCategoryCard( //fungsi yang digunakan untuk membuat kartu kategori
    BuildContext context,
    String title, //Judul kategori yang ditampilkan di kartu
    IconData icon,//Ikon yang digunakan untuk mewakili kategori
    Color color,
  ) {
    return InkWell(
      // NEW
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
      child: Container(//icon
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            const BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(//tampilan lingkaran icon
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

  Widget _buildPromoCard(BuildContext context, Trip trip) { //menampilkan detail perjalanan dari promo yang dapat diketuk
    return GestureDetector( //gesture ketukan
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailScreen(trip: trip)),
      ),
      //kontainer detail perjalanan
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                trip.image,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            //menampilkan judul perjalanan dan harga perjalanan dengan tata letak yang terstruktur (sdh dipencet)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                  ),
                  Text(
                    trip.price,
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
