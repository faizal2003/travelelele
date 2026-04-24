import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/route_model.dart';
import '../services/booking_service.dart';
import 'passenger_details_screen.dart';

class SeatSelectionScreen extends StatefulWidget {
  final TravelRoute route;
  const SeatSelectionScreen({super.key, required this.route});

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> { //fungsi berubah
  final BookingService _bookingService = BookingService();
  final Set<int> _selectedSeats = {}; // menyimpan kursi yang dipilih
  String _userGender = 'Laki-laki'; //informasi jenis kelamin

  @override
  void initState() {//default
    super.initState();
    _fetchUserGender();
  }

  //ambil data jenis kelamin
  void _fetchUserGender() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && mounted) {
        setState(() {
          _userGender = doc.data()?['gender'] ?? 'Laki-laki';
        });
      }
    }
  }

  //layout kursi tour
  List<List<int>> get _seatLayout {
    if (widget.route.isWisata) {
      // Wisata configuration: 2-3-4-3-3-4 (Total 19 seats)
      // 0 means empty space to align seats appropriately (creating an aisle)
      return [
        [1, 2, 0, 0],
        [3, 4, 5, 0],
        [6, 7, 8, 9],
        [10, 11, 12, 0],
        [13, 14, 15, 0],
        [16, 17, 18, 19],
      ];
      //layout kursi travel
    } else {
      // Travel configuration: 1-3-3 (Total 7 seats)
      // 0 means empty space to align seat 1 to the left
      return [
        [1, 0, 0],
        [2, 3, 4],
        [5, 6, 7],
      ];
    }
  }

  bool _isFemaleSeat(int seatNumber) {
    if (widget.route.isWisata) {
      return seatNumber <= 9; // First 9 seats for female (Row 1 to 3)
    } else {
      return seatNumber <= 4; // First 4 seats for female (Row 1 & 2)
    }
  }
 //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.route.isWisata
              ? "Pilih Kursi - ${widget.route.toCity}" //appbar bagian atas
              : "Pilih Kursi - ${widget.route.fromCity} ke ${widget.route.toCity}",
          style: const TextStyle(fontSize: 16),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildLegend(),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<Map<int, String>>( //map int nomor kursi //string gender,status
                stream: _bookingService.getBookedSeatsWithGenderStream(widget.route.id),//informasi kursi yg dipesan dan gender
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  //atasi error
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final bookedSeatsMap = snapshot.data ?? {};

                  // menghapus kursi yang sudah dipilih
                  final toRemove = _selectedSeats.where((seat) => bookedSeatsMap.containsKey(seat)).toList();
                  if (toRemove.isNotEmpty) {
                    _selectedSeats.removeAll(toRemove);
                  }

                  return _buildSeatGrid(bookedSeatsMap);
                },
              ),
            ),
            //pesan jika blm pilih kursi
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_selectedSeats.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Pilih minimal satu kursi")),
                    );
                    return;
                  }
                  //meneruskan ke passengerdetail screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PassengerDetailsScreen( //melanjutkan halaman yg akan dibuka
                        route: widget.route,
                        selectedSeats: _selectedSeats.toList()..sort(),
                      ),
                    ),
                  );
                },
                child: const Text("Lanjut ke Data Penumpang"), //melanjutkan ke data penumpang
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatGrid(Map<int, String> bookedSeatsWithGender) { // parameter apakah kursi sudah dibooking untuk laki-laki atau perempuan)
    return LayoutBuilder(
      builder: (context, constraints) {
        int maxSeatsInRow = widget.route.isWisata ? 4 : 3;
        double spacing = 10.0;
        
        //memastikan bahwa ukuran kursi disesuaikan dengan lebar layar yang tersedia dan jumlah kursi yang ingin ditampilkan dalam satu baris.
        double seatSize = (constraints.maxWidth / maxSeatsInRow) - spacing;
        if (seatSize > 70) seatSize = 70; // dibatasi agar tidak lebih besar dari 70 piksel.

        //membangun grid kursi dinamis dapat digulir secara vertikal menggunakan SingleChildScrollView
        return SingleChildScrollView(
          child: Column(
            children: _seatLayout.map((rowSeats) {
              return Padding(
                padding: EdgeInsets.only(bottom: spacing),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: rowSeats.map((seatNumber) {
                    if (seatNumber == 0) { //Kursi kosong (diwakili dengan 0)
                      // Render empty space
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: spacing / 2),
                        child: SizedBox(width: seatSize, height: seatSize),
                      );
                    }

                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: spacing / 2),//memastikan ada ruang di antara kursi tanpa membuatnya terlalu jauh.
                      child: _buildSeat(seatNumber, bookedSeatsWithGender, seatSize),
                      ////memvisualisasi kursi dalam grid, mempertimbangkan status kursi (sudah dibooking atau tersedia)
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildSeat(int seatNumber, Map<int, String> bookedSeatsWithGender, double size) {
    final isBooked = bookedSeatsWithGender.containsKey(seatNumber); //variabel boolean memeriksa apakah kursi sudah dibooking.
    final isSelected = _selectedSeats.contains(seatNumber); //memeriksa seatNumber ada dalam bookedSeatsWithGender, berarti kursi tersebut sudah dibooking
    final isFemaleArea = _isFemaleSeat(seatNumber); //variabel boolean memeriksa apakah kursi berada di area khusus untuk perempuan.
    final bookedGender = bookedSeatsWithGender[seatNumber]; //menyimpan informasi gender pengguna yang sudah memesan kursi tersebut

    //Menentukan Status Kursi
    int status = 0; // 0=Available
    if (isBooked) {
      status = 2; // 2=Booked
    } else if (isSelected) {
      status = 1; // 1=Selected
    }

    final bool isUserFemale = _userGender == 'Perempuan'; //cek apakah perempuan dengan variabel bool

    //dapat memilih kursi yang kosong, tidak bisa pilih yang sudah dipesan
    return GestureDetector(
      onTap: () {
        if (isBooked) return;

        //memastikan UI akan diperbarui setiap pengguna memilih atau membatalkan pilihan kursi.
        setState(() {
          if (isSelected) {
            _selectedSeats.remove(seatNumber);
          } else {
            _selectedSeats.add(seatNumber);
          }
        });
      },
      //memberikan warna kursi
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: _getSeatColor(status, isFemaleArea, isUserFemale, bookedGender),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
                ? (isUserFemale ? Colors.pink[800]! : Colors.blue[800]!)
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        //icon warna jika dipilih
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chair,
                color: (status == 1 || status == 2) ? Colors.white : Colors.grey[600],
                size: size * 0.35,
              ),
              //penomoran kursi
              const SizedBox(height: 4),
              Text(
                "$seatNumber",
                style: TextStyle(
                  fontSize: size * 0.25,
                  fontWeight: FontWeight.bold,
                  color: (status == 1 || status == 2) ? Colors.white : Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
//fungsi getseat memberikan warna berdasarkan faktor
  Color _getSeatColor(int status, bool isFemaleArea, bool isUserFemale, String? bookedGender) {
    if (status == 2) {
      // Booked: Color based on the gender of the person who booked it
      return (bookedGender == 'Perempuan') ? Colors.pink[200]! : Colors.blue[200]!;
    }
    if (status == 1) return isUserFemale ? Colors.pink[500]! : Colors.blue[500]!; // Selected
    return Colors.green[50]!; // tersedia hijau
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        _legendItem(Colors.green[50]!, "Tersedia"), //hijau untuk tersedia
        _legendItem(Colors.pink[500]!, "Terpilih (P)"),//pink tua untuk terpilih perempuan
        _legendItem(Colors.blue[500]!, "Terpilih (L)"),
        _legendItem(Colors.pink[200]!, "Dipesan (P)"),
        _legendItem(Colors.blue[200]!, "Dipesan (L)"),
      ],
    );
  }

  Widget _legendItem(Color color, String label) { //Fungsi _legendItem  widget membangun item dalam tampilan warna status kursi dan label
    return Row(//horizontal
      mainAxisSize: MainAxisSize.min, //menampung konten, kotak warna dan teks. memastikan tampilan tidak terlalu lebar.
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey[400]!),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)), //menampilkan label, yang merupakan teks yang menjelaskan warna kursi
      ],
    );
  }
}
