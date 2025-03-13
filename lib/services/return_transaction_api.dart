import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';

class ReturnTransactionApi {
  final Logger log = Logger();
  final String baseUrl = Config.baseUrl;

  Future<bool> returnItem({
    required int empId,
    required int itemId,
    required int quantity,
    required String remarks,
  }) async {
     // ✅ Using baseUrl from config
    final Uri url = Uri.parse('$baseUrl/api/return_transaction');

    final Map<String, dynamic> requestBody = {
      "emp_id": empId,
      "item_id": itemId,
      "quantity": quantity,
      "remarks": remarks,
    };

    log.i("🔄 Sending return request: $requestBody");

    try {
      // ✅ Get stored token for authentication
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        log.i("✅ Item returned successfully!");
        return true;
      } else {
        final responseBody = jsonDecode(response.body);
        log.w("⚠️ Failed to return item. Status: ${response.statusCode}, Error: ${responseBody['msg'] ?? 'Unknown error'}");
        return false;
      }
    } catch (e, stackTrace) {
      log.e("❌ Error in returnItem API: $e", error: e, stackTrace: stackTrace);
      return false;
    }
  }
}
