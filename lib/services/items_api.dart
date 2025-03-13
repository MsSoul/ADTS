// filename: lib/services/items_api.dart
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

        if (responseData is Map<String, dynamic> &&
            responseData.containsKey("items")) {
          final List<Map<String, dynamic>> items =
              List<Map<String, dynamic>>.from(responseData["items"]);

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
//fetching borrowed items t
  Future<List<Map<String, dynamic>>> fetchBorrowedItems(int empId) async {
    log.i("🔄 Fetching borrowed items for empId: $empId");

    final url = Uri.parse('$baseUrl/api/items/borrowed/$empId');
    log.i("🌍 API Request URL: $url");

    try {
      final response = await http.get(url);

      log.i("📩 Response Status Code: ${response.statusCode}");
      log.d("📜 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('borrowed_items') &&
            responseData['borrowed_items'] is List<dynamic>) {
          final List<Map<String, dynamic>> borrowedItems =
              List<Map<String, dynamic>>.from(responseData['borrowed_items']);

          if (borrowedItems.isEmpty) {
            log.w("⚠ No borrowed items found.");
          } else {
            log.i(
                "✅ Successfully retrieved ${borrowedItems.length} borrowed items.");
          }

          return borrowedItems.map((item) {
            String remarks;
            if (item["OWNER_NAME"] != null && item["createdAt"] != null) {
              DateTime borrowedDate = DateTime.parse(item["createdAt"]);
              String formattedDate =
                  "${borrowedDate.year}-${borrowedDate.month.toString().padLeft(2, '0')}-${borrowedDate.day.toString().padLeft(2, '0')}";
              remarks = "${item["OWNER_NAME"]} | Borrowed: $formattedDate";
            } else {
              remarks = "Owned Item"; // If it's an owned item
            }

            return {
              "name": item["ITEM_NAME"],
              "description": item["DESCRIPTION"],
              "quantity": item["quantity"] ?? 0,
              "ORIGINAL_QUANTITY": item["ORIGINAL_QUANTITY"] ?? 0,
              "ics": item["ics"] ?? "",
              "are_no": item["are_no"] ?? "",
              "prop_no": item["PROP_NO"] ?? "",
              "serial_no": item["SERIAL_NO"] ?? "",
              "unit_value": item["unit_value"] ?? 0,
              "total_value": item["total_value"] ?? 0,
              "remarks": remarks, // Display owner name and borrowed date
            };
          }).toList();
        } else {
          log.w("⚠ Unexpected response format: $responseData");
          return [];
        }
      } else {
        throw Exception(
            '❌ Failed to load borrowed items: ${response.reasonPhrase}');
      }
    } catch (e) {
      log.e("❌ Error fetching borrowed items: $e");
      throw Exception('❌ Error fetching borrowed items. Please try again.');
    }
  }

  Future<void> debugSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    log.i("🔎 Stored emp_id: ${prefs.getInt('emp_id')}");
  }
}
