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
  final int _totalSeats = 16; // Simple 4x4 grid

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Pilih Kursi - ${widget.route.fromCity} ke ${widget.route.toCity}",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildLegend(),
            const SizedBox(height: 30),
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

                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _totalSeats,
                    itemBuilder: (context, index) {
                      final seatNumber = index + 1;
                      final isBooked = bookedSeats.contains(seatNumber);
                      final isSelected = _selectedSeats.contains(seatNumber);

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
                          decoration: BoxDecoration(
                            color: _getSeatColor(status),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.chair,
                              color: status == 1 ? Colors.white : Colors.grey[600],
                            ),
                          ),
                        ),
                      );
                    },
                  );
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

  Color _getSeatColor(int status) {
    if (status == 2) return Colors.grey[300]!; // Booked
    if (status == 1) return const Color(0xFF154c79); // Selected
    return Colors.white; // Available
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _legendItem(Colors.white, "Available"),
        _legendItem(const Color(0xFF154c79), "Selected"),
        _legendItem(Colors.grey[300]!, "Booked"),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey),
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
