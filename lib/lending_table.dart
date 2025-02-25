// filename: lib/table_borrowing_transaction.dart
/*import 'package:flutter/material.dart';
import 'package:logger/logger.dart';  // Import Logger
import 'design/colors.dart';
import 'lending_transaction.dart';

class LendingTransactionTable extends StatefulWidget {
  final int currentDptId;
  final int empId;
  final int itemId;
  final String itemName;
  final String description;
  final List<Map<String, dynamic>> initialTransactions;

  const LendingTransactionTable({
    super.key,
    required this.initialTransactions,
    required this.currentDptId,
    required this.empId,
    required this.itemId,
    required this.itemName,
    required this.description,
  });

  @override
  State<LendingTransactionTable> createState() => _LendingTransactionTableState();
}

class _LendingTransactionTableState extends State<LendingTransactionTable> {
  List<Map<String, dynamic>> transactions = [];
  final Logger logger = Logger();  // Initialize Logger

  @override
  void initState() {
    super.initState();
    transactions = List.from(widget.initialTransactions);

    // 🔍 Log fetched initial transactions
    logger.i('Initial Transactions: ${widget.initialTransactions}');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _buildDataTable()),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _showBorrowingTransactionDialog,
          child: const Text('Add Transaction'),
        ),
      ],
    );
  }

  void _showBorrowingTransactionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LendingTransaction(
          empId: widget.empId,
          itemId: widget.itemId,
          itemName: widget.itemName,
          description: widget.description,
          currentDptId: widget.currentDptId,
          initialTransactions: transactions,
        );
      },
    ).then((result) {
      if (result != null && result is Map<String, dynamic>) {
        logger.d('Transaction added: $result');  // Debug log

        setState(() {
          transactions.add({
            'item_name': result['itemName'],
            'description': result['description'],
            'quantity': result['quantity'],
            'borrower': result['borrowerName'],
          });
        });

        logger.i('Updated Transactions List: $transactions');  // Info log
      }
    });
  }

  Widget _buildDataTable() {
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
                  (states) => AppColors.accentColor,
                ),
                columns: const [
                  DataColumn(label: Text('Item', style: TextStyle(color: Colors.white))),
                  DataColumn(label: Text('Description', style: TextStyle(color: Colors.white))),
                  DataColumn(label: Text('Quantity', style: TextStyle(color: Colors.white))),
                  DataColumn(label: Text('Borrower', style: TextStyle(color: Colors.white))),
                ],
                rows: transactions.map((transaction) {
                  return DataRow(cells: [
                    DataCell(Text(transaction['item_name'] ?? '')),
                    DataCell(Text(transaction['description'] ?? '')),
                    DataCell(Text(transaction['quantity'].toString())),
                    DataCell(Text(transaction['borrower'] ?? 'N/A')),
                  ]);
                }).toList(),
              ),
            ),
          )
        : const Center(child: Text('No transactions yet', style: TextStyle(color: Colors.grey)));
  }
}
*/