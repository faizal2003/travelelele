import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/trip_model.dart';
import '../models/route_model.dart';
import '../models/promo_model.dart';
import 'seat_selection_screen.dart';

class DetailScreen extends StatefulWidget {
  final Trip trip;
  final Promo? promo;

  const DetailScreen({super.key, required this.trip, this.promo});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  DateTime _selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String finalPrice = widget.promo != null 
        ? Promo.calculateDiscountedPrice(widget.trip.price, widget.promo!.discount)
        : widget.trip.price;

    return Scaffold(
      appBar: AppBar(title: Text(widget.trip.title)),
      body: Column(
        children: [
          Image.network(
            widget.trip.image,
            height: 250,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.trip.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.promo != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "Promo ${widget.promo!.discount}",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        finalPrice,
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.promo != null) ...[
                        const SizedBox(width: 12),
                        Text(
                          widget.trip.price,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    "Description",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.promo != null ? widget.promo!.description : "Enjoy a wonderful trip with our premium travel package. Includes transportation, meals, and guided tours.",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const Spacer(),
                  
                  // Bagian Pemilihan Tanggal
                  const Text("Tanggal Keberangkatan", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(_selectedDate),
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Icon(Icons.calendar_month, color: Colors.blue),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final route = TravelRoute(
                          id: 'trip-${widget.trip.title.hashCode}',
                          fromCity: 'Yogyakarta',
                          toCity: widget.trip.title,
                          date: "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}",
                          departTime: '08:00',
                          arriveTime: '18:00',
                          price: finalPrice,
                          seatsAvailable: 19,
                          isWisata: true,
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SeatSelectionScreen(route: route),
                          ),
                        );
                      },
                      child: const Text("Pilih Kursi"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


