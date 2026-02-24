import 'package:flutter/material.dart';
import '../models/route_model.dart';
import '../services/booking_service.dart';
import 'seat_selection_screen.dart'; // We reuse your existing seat selection

class TravelSearchScreen extends StatefulWidget {
  const TravelSearchScreen({super.key});

  @override
  State<TravelSearchScreen> createState() => _TravelSearchScreenState();
}

class _TravelSearchScreenState extends State<TravelSearchScreen> {
  // Controllers
  final TextEditingController _fromController = TextEditingController(
    text: "Jakarta",
  );
  final TextEditingController _toController = TextEditingController(
    text: "Bandung",
  );
  DateTime _selectedDate = DateTime.now();
  final BookingService _bookingService = BookingService();

  // List to display (starts with all routes, filters later)
  List<TravelRoute> _displayRoutes = dummyRoutes;

  // Cities for autocomplete
  final Set<String> _allCities = {};

  @override
  void initState() {
    super.initState();
    // Extract unique cities from dummyRoutes
    for (var route in dummyRoutes) {
      _allCities.add(route.fromCity);
      _allCities.add(route.toCity);
    }
  }

  void _searchRoutes() {
    setState(() {
      _displayRoutes = dummyRoutes.where((route) {
        return route.fromCity.toLowerCase().contains(
              _fromController.text.toLowerCase(),
            ) &&
            route.toCity.toLowerCase().contains(
              _toController.text.toLowerCase(),
            );
      }).toList();
    });
  }

  void _swapLocations() {
    String temp = _fromController.text;
    _fromController.text = _toController.text;
    _toController.text = temp;
    _searchRoutes(); // Auto search on swap
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text("Cari Travel"),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchHeader(),
          Expanded(
            child: _displayRoutes.isEmpty
                ? const Center(child: Text("Tidak ada rute tersedia"))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _displayRoutes.length,
                    itemBuilder: (context, index) {
                      return _buildRouteCard(context, _displayRoutes[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // FROM & TO INPUTS
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildLocationRow(Icons.my_location, "Dari", _fromController),
                const Divider(height: 1, indent: 40),
                Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    _buildLocationRow(Icons.location_on, "Ke", _toController),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: IconButton(
                        icon: const Icon(
                          Icons.swap_vert_circle,
                          color: Colors.blue,
                          size: 32,
                        ),
                        onPressed: _swapLocations,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // DATE PICKER & SEARCH BUTTON
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
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white30),
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
                          "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
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

  Widget _buildLocationRow(
    IconData icon,
    String label,
    TextEditingController controller,
  ) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: RawAutocomplete<String>(
            textEditingController: controller,
            focusNode: FocusNode(),
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<String>.empty();
              }
              return _allCities.where((String option) {
                return option.toLowerCase().contains(
                  textEditingValue.text.toLowerCase(),
                );
              });
            },
            fieldViewBuilder:
                (
                  BuildContext context,
                  TextEditingController textEditingController,
                  FocusNode focusNode,
                  VoidCallback onFieldSubmitted,
                ) {
                  return TextField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      labelText: label,
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    onSubmitted: (String value) {
                      onFieldSubmitted();
                    },
                  );
                },
            optionsViewBuilder:
                (
                  BuildContext context,
                  AutocompleteOnSelected<String> onSelected,
                  Iterable<String> options,
                ) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4.0,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 250, // Adjust width as needed
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                            final String option = options.elementAt(index);
                            return InkWell(
                              onTap: () {
                                onSelected(option);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(option),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
          ),
        ),
      ],
    );
  }

  Widget _buildRouteCard(BuildContext context, TravelRoute route) {
    return StreamBuilder<List<int>>(
      stream: _bookingService.getBookedSeatsStream(route.id),
      builder: (context, snapshot) {
        int availableSeats = 16; // Using 16 as the total default capacity

        if (snapshot.hasData) {
          availableSeats = 16 - snapshot.data!.length;
        }

        // Just in case data gives more seats than 16 somehow
        if (availableSeats < 0) {
          availableSeats = 0;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Top Row: Seats & Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.event_seat,
                          size: 18,
                          color: availableSeats < 3
                              ? Colors.red
                              : Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "$availableSeats Kursi Tersedia",
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

                // Middle Row: Time & Route
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
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: availableSeats == 0
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SeatSelectionScreen(route: route),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: availableSeats == 0 
                          ? Colors.grey 
                          : Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
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

  Widget _buildTimeColumn(String time, String city) {
    return Column(
      children: [
        Text(
          time,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(city, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
