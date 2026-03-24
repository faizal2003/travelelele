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

  List<List<int>> get _seatLayout {
    if (widget.route.isWisata) {
      // Wisata configuration: 1-3-3 (Total 7 seats)
      // 0 means empty space to align seat 1 to the left
      return [
        [1, 0, 0],
        [2, 3, 4],
        [5, 6, 7],
      ];
    } else {
      // Travel configuration: 2-3-4-3-3-4 (Total 19 seats)
      // 0 means empty space to align seats appropriately (creating an aisle)
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
      return seatNumber <= 4; // First 4 seats for female (Row 1 & 2)
    } else {
      return seatNumber <= 9; // First 9 seats for female (Row 1 to 3)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Pilih Kursi - ${widget.route.fromCity} ke ${widget.route.toCity}",
          style: const TextStyle(fontSize: 16),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildLegend(),
            const SizedBox(height: 16),
            const Text(
              "Catatan: Area depan untuk Perempuan, area belakang untuk Laki-laki.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<List<int>>(
                stream: _bookingService.getBookedSeatsStream(widget.route.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final bookedSeats = snapshot.data ?? [];

                  // Remove locally selected seats if they were booked by someone else
                  final toRemove = _selectedSeats.where((seat) => bookedSeats.contains(seat)).toList();
                  if (toRemove.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        _selectedSeats.removeAll(toRemove);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Kursi yang Anda pilih baru saja dipesan.")),
                      );
                    });
                  }

                  return _buildSeatGrid(bookedSeats);
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

  Widget _buildSeatGrid(List<int> bookedSeats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int maxSeatsInRow = widget.route.isWisata ? 3 : 4;
        double spacing = 10.0;
        
        // Calculate seat size based on the max seats in a row
        double seatSize = (constraints.maxWidth / maxSeatsInRow) - spacing;
        if (seatSize > 70) seatSize = 70; // Cap the maximum size of a seat

        return SingleChildScrollView(
          child: Column(
            children: _seatLayout.map((rowSeats) {
              return Padding(
                padding: EdgeInsets.only(bottom: spacing),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: rowSeats.map((seatNumber) {
                    if (seatNumber == 0) {
                      // Render empty space
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: spacing / 2),
                        child: SizedBox(width: seatSize, height: seatSize),
                      );
                    }

                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: spacing / 2),
                      child: _buildSeat(seatNumber, bookedSeats, seatSize),
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

  Widget _buildSeat(int seatNumber, List<int> bookedSeats, double size) {
    final isBooked = bookedSeats.contains(seatNumber);
    final isSelected = _selectedSeats.contains(seatNumber);
    final isFemale = _isFemaleSeat(seatNumber);

    int status = 0; // 0=Available
    if (isBooked) {
      status = 2; // 2=Booked
    } else if (isSelected) {
      status = 1; // 1=Selected
    }

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
          color: _getSeatColor(status, isFemale),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
                ? (isFemale ? Colors.pink[800]! : Colors.blue[800]!)
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
                color: status == 1 ? Colors.white : Colors.grey[600],
                size: size * 0.35,
              ),
              const SizedBox(height: 4),
              Text(
                "$seatNumber",
                style: TextStyle(
                  fontSize: size * 0.25,
                  fontWeight: FontWeight.bold,
                  color: status == 1 ? Colors.white : Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getSeatColor(int status, bool isFemale) {
    if (status == 2) return Colors.grey[300]!; // Booked
    if (status == 1) return isFemale ? Colors.pink[500]! : Colors.blue[500]!; // Selected
    return isFemale ? Colors.pink[50]! : Colors.blue[50]!; // Available
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        _legendItem(Colors.pink[50]!, "Tersedia (P)"),
        _legendItem(Colors.blue[50]!, "Tersedia (L)"),
        _legendItem(Colors.pink[500]!, "Terpilih (P)"),
        _legendItem(Colors.blue[500]!, "Terpilih (L)"),
        _legendItem(Colors.grey[300]!, "Dipesan"),
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
