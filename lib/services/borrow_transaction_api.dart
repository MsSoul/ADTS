//filname:lib/service/borrow_transaction_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class BorrowTransactionApi {
  final String baseUrl;

  BorrowTransactionApi(this.baseUrl);

  // Fetch borrowers based on department and search criteria
  Future<List<Map<String, dynamic>>> fetchBorrowers(int departmentId, String query, String searchType) async {
    final response = await http.get(Uri.parse('$baseUrl/api/borrowers?department_id=$departmentId&query=$query&search_type=$searchType'));

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch borrowers');
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
