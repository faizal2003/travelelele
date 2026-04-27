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

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  final BookingService _bookingService = BookingService();
  final Set<int> _selectedSeats = {}; 
  String _userGender = 'Laki-laki'; 

  @override
  void initState() {
    super.initState();
    _fetchUserGender();
  }

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

  // Layout kursi dinamis berdasarkan tipe (Wisata = 7, Travel = 19)
  List<List<int>> get _seatLayout {
    if (widget.route.isWisata) {
      // Wisata configuration: 1-3-3 (Total 7 seats)
      return [
        [1, 0, 0],
        [2, 3, 4],
        [5, 6, 7],
      ];
    } else {
      // Travel configuration: 2-3-4-3-3-4 (Total 19 seats)
      return [
        [1, 2, 0, 0],
        [3, 4, 5, 0],
        [6, 7, 8, 9],
        [10, 11, 12, 0],
        [13, 14, 15, 0],
        [16, 17, 18, 19],
      ];
    }
  }

  bool _isFemaleSeat(int seatNumber) {
    if (widget.route.isWisata) {
      return seatNumber <= 4; // Seats 1-4 for female in 7-seat config
    } else {
      return seatNumber <= 9; // Seats 1-9 for female in 19-seat config
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.route.isWisata
              ? "Pilih Kursi Wisata - ${widget.route.toCity}"
              : "Pilih Kursi Travel - ${widget.route.fromCity} ke ${widget.route.toCity}",
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
              child: StreamBuilder<Map<int, String>>(
                stream: _bookingService.getBookedSeatsWithGenderStream(widget.route.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final bookedSeatsMap = snapshot.data ?? {};

                  final toRemove = _selectedSeats.where((seat) => bookedSeatsMap.containsKey(seat)).toList();
                  if (toRemove.isNotEmpty) {
                    _selectedSeats.removeAll(toRemove);
                  }

                  return _buildSeatGrid(bookedSeatsMap);
                },
              ),
            ),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PassengerDetailsScreen(
                        route: widget.route,
                        selectedSeats: _selectedSeats.toList()..sort(),
                      ),
                    ),
                  );
                },
                child: const Text("Lanjut ke Data Penumpang"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatGrid(Map<int, String> bookedSeatsWithGender) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int maxSeatsInRow = widget.route.isWisata ? 3 : 4;
        double spacing = 10.0;
        
        double seatSize = (constraints.maxWidth / maxSeatsInRow) - spacing;
        if (seatSize > 70) seatSize = 70;

        return SingleChildScrollView(
          child: Column(
            children: _seatLayout.map((rowSeats) {
              return Padding(
                padding: EdgeInsets.only(bottom: spacing),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: rowSeats.map((seatNumber) {
                    if (seatNumber == 0) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: spacing / 2),
                        child: SizedBox(width: seatSize, height: seatSize),
                      );
                    }

                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: spacing / 2),
                      child: _buildSeat(seatNumber, bookedSeatsWithGender, seatSize),
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
    final isBooked = bookedSeatsWithGender.containsKey(seatNumber);
    final isSelected = _selectedSeats.contains(seatNumber);
    final isFemaleArea = _isFemaleSeat(seatNumber);
    final bookedGender = bookedSeatsWithGender[seatNumber];

    int status = 0; 
    if (isBooked) {
      status = 2; 
    } else if (isSelected) {
      status = 1; 
    }

    final bool isUserFemale = _userGender == 'Perempuan';

    return GestureDetector(
      onTap: () {
        if (isBooked) return;

        setState(() {
          if (isSelected) {
            _selectedSeats.remove(seatNumber);
          } else {
            _selectedSeats.add(seatNumber);
          }
        });
      },
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chair,
                color: (status == 1 || status == 2) ? Colors.white : Colors.grey[600],
                size: size * 0.35,
              ),
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

  Color _getSeatColor(int status, bool isFemaleArea, bool isUserFemale, String? bookedGender) {
    if (status == 2) {
      return (bookedGender == 'Perempuan') ? Colors.pink[200]! : Colors.blue[200]!;
    }
    if (status == 1) return isUserFemale ? Colors.pink[500]! : Colors.blue[500]!; 
    return Colors.green[50]!; 
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        _legendItem(Colors.green[50]!, "Tersedia"),
        _legendItem(Colors.pink[500]!, "Terpilih (P)"),
        _legendItem(Colors.blue[500]!, "Terpilih (L)"),
        _legendItem(Colors.pink[200]!, "Dipesan (P)"),
        _legendItem(Colors.blue[200]!, "Dipesan (L)"),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
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
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
