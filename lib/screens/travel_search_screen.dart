import 'package:flutter/material.dart';
import '../models/route_model.dart';
import '../services/booking_service.dart';
import '../services/route_service.dart';
import 'seat_selection_screen.dart'; // We reuse your existing seat selection

class TravelSearchScreen extends StatefulWidget {
  const TravelSearchScreen({super.key}); //Konstruktor ini menerima parameter key dari super.key

  @override
  State<TravelSearchScreen> createState() => _TravelSearchScreenState();
} //mengelola kondisi atau status (state) dari layar pencarian perjalanan

//yang bertanggung jawab menangani logika
class _TravelSearchScreenState extends State<TravelSearchScreen> {
  String _fromCity = "Yogyakarta";
  String _toCity = "Madiun";
  final List<String> _cities = ['Madiun', 'Surabaya', 'Yogyakarta', 'Malang'];

  //tanggal default
  DateTime _selectedDate = DateTime.now();
  final BookingService _bookingService = BookingService();
  final RouteService _routeService = RouteService();

  // menampilkan rute berdasarkan input pengguna
  List<TravelRoute> _allRoutes = [];
  List<TravelRoute> _displayRoutes = [];

  @override
  void initState() { //posisi default,menampilkan semua jadwal
    super.initState();
    _loadRoutes();
  }

  void _loadRoutes() {
    _routeService.getRoutes().listen((routes) {
      if (mounted) {
        setState(() {
          _allRoutes = routes;
          _searchRoutes();
        });
      }
    });
  }

  //mencari dan memfilter daftar rute perjalanan sesuai yg di input
  void _searchRoutes() {
    final String searchDate = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
    setState(() { //fungsi memperbarui state
      _displayRoutes = _allRoutes.where((route) { //mencari sesuai inputan
        return route.fromCity.toLowerCase() == _fromCity.toLowerCase() &&
               route.toCity.toLowerCase() == _toCity.toLowerCase() &&
               route.date == searchDate;
      }).toList();
    });
  }

  void _swapLocations() { //tukar nilai yang ada di asal ke tujuan
    setState(() {
      String temp = _fromCity;
      _fromCity = _toCity;
      _toCity = temp;
      _searchRoutes();
    });
  }

  Future<void> _pickDate() async { //memilih tanggal
    final DateTime? picked = await showDatePicker( //menampilkan date picker
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),//tgl awal
      lastDate: DateTime(2030),//Menentukan tanggal akhir yang dapat dipilih.
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _searchRoutes();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar( //app bar
        title: const Text("Cari Travel"),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchHeader(),
          //jika tidak ada rute
          Expanded(
            child: _displayRoutes.isEmpty
                ? const Center(child: Text("Tidak ada rute tersedia"))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _displayRoutes.length,
                    itemBuilder: (context, index) { //
                      return _buildRouteCard(context, _displayRoutes[index]);//membangun tampilan untuk setiap rute dalam daftar.
                    },
                  ),
          ),
        ],
      ),
    );
  }
  //membangun tampilan bagian header pencarian
  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor, //warna serasi tema aplikasi
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // asal dan tujuan input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),

            child: Column( //menampilkan widget secara vertikal.
              children: [
                _buildLocationRow(Icons.my_location, "Dari", _fromCity, (val) {
                  setState(() => _fromCity = val!);
                }), //menampilkan input asal atau tujuan.
                const Divider(height: 1, indent: 40),
                Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    _buildLocationRow(Icons.location_on, "Ke", _toCity, (val) {
                      setState(() => _toCity = val!);
                    }), //mengontrol input teks pada kolom tujuan perjalanan
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: IconButton(
                        icon: const Icon(
                          Icons.swap_vert_circle,
                          color: Colors.blue,
                          size: 32,
                        ),
                        onPressed: _swapLocations,
                        //Fungsi _swapLocations() menukar nilai pada kolom asal dan tujuan, tujuan perjalanan akan dibalik.
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // tampilan tanggal
          Row(
            children: [
              Expanded(
                flex: 2,
                child: InkWell(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2), //Mengatur warna latbel Container menjadi putih.
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white30), //Menambahkan border putih dengan transparansi
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}", //ambil tanggal dll yg dipilih
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              //bagian cari
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  onPressed: _searchRoutes,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    "Cari",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow( //icon input
    IconData icon,
    String label,
    String value,
    void Function(String?) onChanged,
  ) {
    //parameter teks
    return Row(
      children: [
        Icon(icon, color: Colors.grey), //menunjukkan ikon  input ikon lokasi
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: value,
            items: _cities.map((city) => DropdownMenuItem(value: city, child: Text(city))).toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              labelText: label,
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRouteCard(BuildContext context, TravelRoute route) { //membangun widget kartu informasi rute
    return StreamBuilder<Map<int, String>>(
      stream: _bookingService.getBookedSeatsWithGenderStream(route.id),//menunjukkan kursi telah dipesan,ID kursi sebagai key dan informasi jenis kelamin sebagai value.
      builder: (context, snapshot) {
        int totalCapacity = route.seatsAvailable;
        int availableSeats = totalCapacity; //dihitung yg sudah dipesan

      //Mengambil jumlah kursi yang sudah dipesan
        if (snapshot.hasData) {
          availableSeats = totalCapacity - snapshot.data!.length;
        }

        if (availableSeats < 0) {
          availableSeats = 0;
        }
        //card
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 3, //bayangan
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Top Row: kursi & harga
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Menyusun elemen-elemen di dalam Row
                  children: [
                    Row(
                      children: [
                        //seat icon
                        Icon(
                          Icons.event_seat,
                          size: 18,
                          color: availableSeats < 3
                              ? Colors.red
                              : Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "$availableSeats Kursi Tersedia", //Menampilkan jumlah kursi yang tersedia
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: availableSeats < 3
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                      ],
                    ),
                    //harga
                    Text(
                      route.price,
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 30),

                // waktu keberangkatan dan kedatangan
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTimeColumn(route.departTime, route.fromCity),
                    const Icon(Icons.arrow_forward, color: Colors.grey),
                    _buildTimeColumn(route.arriveTime, route.toCity),
                  ],
                ),
                const SizedBox(height: 16),

                // Button
                SizedBox(
                  width: double.infinity, //button full
                  child: ElevatedButton(
                    onPressed: availableSeats == 0 // button hanya jika ada kursi yang tersedia
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SeatSelectionScreen(route: route), //ke proses selanjutnya
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: availableSeats == 0 
                          ? Colors.grey 
                          : Theme.of(context).primaryColor,//jika ada warna maka blm penuh
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    //jika 0 penuh
                    child: Text(
                      availableSeats == 0 ? "Penuh" : "Pilih Jadwal Ini",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeColumn(String time, String city) { //menampilkan dua elemen: waktu dan kota.
    return Column(
      children: [
        Text(
          time,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        //warna kota
        const SizedBox(height: 4),
        Text(city, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
