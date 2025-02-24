//filname:lib/service/lend_transaction_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class BorrowTransactionApi {
  final String baseUrl;
    final Logger logger = Logger();

  BorrowTransactionApi(this.baseUrl);

  // Fetch borrowers based on department and search criteria
 Future<List<Map<String, dynamic>>> fetchBorrowers(String currentDptId, String query, String searchType, String
  empId) async {
    try {
      final uri = Uri.parse('$baseUrl/api/borrowTransaction/borrowers').replace(queryParameters: {
        'current_dpt_id': currentDptId,
        'query': query,
        'search_type': searchType,
        'emp_id': empId,
      });

      logger.i("🔍 Fetching from URL: $uri");

      final response = await http.get(uri);

      logger.i("📥 API Response: ${response.body}");

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        logger.i("✅ Decoded Response: $decodedResponse");

        // Ensure response is a list before converting
        if (decodedResponse is List) {
          return List<Map<String, dynamic>>.from(decodedResponse);
        } else {
          logger.e("🚨 Unexpected API Response Type: ${decodedResponse.runtimeType}");
          throw Exception("Invalid API response format");
        }
      } else {
        logger.e("🚨 Backend Response: ${response.statusCode} - ${response.body}");
        throw Exception("Failed to fetch borrowers");
      }
    } catch (e) {
      logger.e("⛔ Error fetching borrowers: $e");
      rethrow;
    }
  }

  // Submit borrowing transaction
  Future<Map<String, dynamic>> submitBorrowingTransaction({
    required int empId,
    required int itemId,
    required int quantity,
    required int borrowerId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/borrow_transaction'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'emp_id': empId,
        'item_id': itemId,
        'quantity': quantity,
        'borrower_id': borrowerId,
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to submit transaction');
    }
  }
}
