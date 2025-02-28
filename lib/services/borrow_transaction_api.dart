//filename:lib/services/borrow_transaction_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'config.dart';

class BorrowTransactionApi {
  final String baseUrl = Config.baseUrl;
  final Logger logger = Logger();

  BorrowTransactionApi();

  /// Fetch items based on current department ID, excluding a specific employee ID
  Future<List<Map<String, dynamic>>> fetchAllItems(int currentDptId, int empId) async {
    final url = Uri.parse('$baseUrl/api/borrowTransaction/$currentDptId/$empId');
    logger.i("🔍 Fetching items from: $url");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data.containsKey("items")) {
          List<Map<String, dynamic>> items = List<Map<String, dynamic>>.from(data["items"]);

          // Log each item retrieved
          for (var item in items) {
            logger.i("📦 Item: ${item['name']}, Accountable: ${item['accountable_name']}");
          }

          return items;
        } else {
          logger.w("⚠ Unexpected response format (No 'items' key): $data");
          return [];
        }
      } else {
        logger.w("⚠ Failed to fetch items. Status: ${response.statusCode}");
        return [];
      }
    } catch (e, stackTrace) {
      logger.e("❌ Error fetching items", error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Process the borrowing transaction
  Future<bool> processBorrowTransaction(int borrowerId, int itemId, int quantity, int currentDptId) async {
    final url = Uri.parse('$baseUrl/api/borrow');
    logger.i("🔄 Processing borrow transaction: $url");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'borrowerId': borrowerId,
          'itemId': itemId,
          'quantity': quantity,
          'currentDptId': currentDptId,
        }),
      );

      if (response.statusCode == 200) {
        logger.i("✅ Borrow transaction successful!");
        return true;
      } else {
        logger.w("⚠ Failed to borrow item. Status: ${response.statusCode}, Response: ${response.body}");
        return false;
      }
    } catch (e, stackTrace) {
      logger.e("❌ Error processing borrow transaction", error: e, stackTrace: stackTrace);
      return false;
    }
  }
 /// Fetch employee name based on employee ID
  Future<String> fetchUserName(int empId) async {
    final url = Uri.parse('$baseUrl/api/userName/$empId'); 
    logger.i("🔍 Fetching user name: $url");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data.containsKey("userName")) {
          String userName = data["userName"];

          // Capitalize the first letter of each word
          String formattedName = userName.split(' ').map((word) {
            return word.isNotEmpty ? word[0].toUpperCase() + word.substring(1).toLowerCase() : '';
          }).join(' ');

          logger.i("👤 User Name: $formattedName");
          return formattedName;
        } else {
          logger.w("⚠ User data does not contain 'userName' key: $data");
          return "Unknown";
        }
      } else {
        logger.w("⚠ Failed to fetch user name. Status: ${response.statusCode}");
        return "Unknown";
      }
    } catch (e, stackTrace) {
      logger.e("❌ Error fetching user name", error: e, stackTrace: stackTrace);
      return "Unknown";
    }
  }
}