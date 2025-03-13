import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/config.dart';
import 'package:logger/logger.dart';

class TransferTransactionApi {
  final String baseUrl;
  final Logger logger = Logger();

  TransferTransactionApi(this.baseUrl);

  /// Fetch employees based on department ID and search input (ID Number or Name)
  Future<List<Map<String, dynamic>>> fetchEmployees(String departmentId, String query, String searchType, String empId) async {
    final url = Uri.parse('$baseUrl/employees/search?departmentId=$departmentId&query=$query&searchType=$searchType&empId=$empId');

    logger.i("Fetching employees: $url");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        logger.w("Failed to fetch employees. Status Code: ${response.statusCode}");
        return [];
      }
    } catch (e, stackTrace) {
      logger.e("Error fetching employees", error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Process transfer transaction
  Future<bool> transferItem({
    required int senderEmpId,
    required int receiverEmpId,
    required int itemId,
    required int quantity,
  }) async {
    final url = Uri.parse('$baseUrl/transfer');

    final Map<String, dynamic> requestBody = {
      "senderEmpId": senderEmpId,
      "receiverEmpId": receiverEmpId,
      "itemId": itemId,
      "quantity": quantity,
    };

    logger.i("Initiating transfer: $requestBody");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        logger.i("Transfer successful");
        return true;
      } else {
        logger.w("Transfer failed. Status Code: ${response.statusCode}, Response: ${response.body}");
        return false;
      }
    } catch (e, stackTrace) {
      logger.e("Error processing transfer", error: e, stackTrace: stackTrace);
      return false;
    }
  }
}
