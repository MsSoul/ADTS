//filename: lib/table_borrowing_transaction.dart
import 'package:flutter/material.dart';
import 'design/colors.dart';

class BorrowingTransactionTable extends StatelessWidget {
  final int? currentDptId;
  final List<Map<String, dynamic>> transactions;

  const BorrowingTransactionTable({super.key, required this.transactions,  required this.currentDptId});

  @override
  Widget build(BuildContext context) {
    return transactions.isNotEmpty
        ? Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.accentColor, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateColor.resolveWith(
                    (states) => AppColors.accentColor),
                columns: const [
                  DataColumn(label: Text('Item', style: TextStyle(color: Colors.white))),
                  DataColumn(label: Text('Description', style: TextStyle(color: Colors.white))),
                  DataColumn(label: Text('Quantity', style: TextStyle(color: Colors.white))),
                  DataColumn(label: Text('Borrower', style: TextStyle(color: Colors.white))),
                  DataColumn(label: Text('Status', style: TextStyle(color: Colors.white))),
                ],
                rows: transactions.map((transaction) {
                  return DataRow(cells: [
                    DataCell(Text(transaction['item_name'])),
                    DataCell(Text(transaction['Description'])),
                    DataCell(Text(transaction['quantity'].toString())),
                    DataCell(Text(transaction['Borrower'] ?? 'N/A')),
                    DataCell(Text(transaction['status'] ?? 'Pending')),
                  ]);
                }).toList(),
              ),
            ),
          )
        : const SizedBox(); // Empty if no transactions
  }
}
