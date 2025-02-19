//filename:lib/services/items_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';

class ItemsApi {
  final String baseUrl = Config.baseUrl;
  final Logger log = Logger();

  // Retrieve Employee ID from SharedPreferences
  Future<int?> getEmpId() async {
    final prefs = await SharedPreferences.getInstance();
    int? empId = prefs.getInt('emp_id');

    if (empId == null) {
      log.w("⚠ No Employee ID found in SharedPreferences!");
    } else {
      log.i("✅ Found Employee ID in SharedPreferences: $empId");
    }
    return empId;
  }

  // Fetch items based on emp_id
  Future<List<Map<String, dynamic>>> fetchItems(int empId) async {
    log.i("🔄 Fetching items for empId: $empId");

    final url = Uri.parse('$baseUrl/api/items/$empId');
    log.i("🌍 API Request URL: $url");

    try {
      final response = await http.get(url);

      log.i("📩 Response Status Code: ${response.statusCode}");
      log.d("📜 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        if (responseData is Map<String, dynamic> && responseData.containsKey("items")) {
          final List<Map<String, dynamic>> items = List<Map<String, dynamic>>.from(responseData["items"]);

          if (items.isEmpty) {
            log.w("⚠ No items found in the response.");
          } else {
            log.i("✅ Successfully retrieved ${items.length} items.");
          }

          return items;
        } else {
          log.w("⚠ Unexpected response format: $responseData");
          return [];
        }
      } else {
        throw Exception('❌ Failed to load items: ${response.reasonPhrase}');
      }
    } catch (e) {
      log.e("❌ Error fetching items: $e");
      throw Exception('❌ Error fetching items. Please try again.');
    }
  }

  Future<void> debugSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    log.i("🔎 Stored emp_id: ${prefs.getInt('emp_id')}");
  }
}
