import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class MidtransService {
  // Your Backend Configuration
  // Use http://10.0.2.2:3000/api for Android Emulator, 
  // http://localhost:3000/api for iOS Simulator, 
  // or your actual backend URL (e.g., https://your-domain.com/api)
  static const String backendBaseUrl = "https://mdtrns.detectpadi.my.id/api";

  /// Fetches the QRIS Image URL from your Node.js backend.
  Future<String?> getQrisImageUrl({
    required String orderId,
    required int grossAmount,
  }) async {
    try {
      debugPrint("Requesting QRIS from backend for Order: $orderId");
      
      final response = await http.post(
        Uri.parse('$backendBaseUrl/payments/qris'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "order_id": orderId,
          "gross_amount": grossAmount,
        }),
      );

      debugPrint("Backend response status: ${response.statusCode}");
      debugPrint("Backend response body: ${response.body}"); // Uncomment for debugging

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['qr_url']; 
      } else {
        debugPrint("Backend API Error: ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("Network Error calling backend: $e");
      return null;
    }
  }

  /// Checks the transaction status via your Node.js backend.
  Future<String> checkStatus(String orderId) async {
    try {
      debugPrint("Checking status via backend for Order: $orderId");

      final response = await http.get(
        Uri.parse('$backendBaseUrl/payments/status/$orderId'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] ?? "pending"; 
      }
      return "error"; 
    } catch (e) {
      debugPrint("Network error checking status: $e");
      return "error";
    }
  }
}
