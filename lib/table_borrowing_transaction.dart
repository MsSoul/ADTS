// filename: lib/table_borrowing_transaction.dart
import 'package:flutter/material.dart';
import 'design/colors.dart';
import 'borrowing_transaction.dart';

class BorrowingTransactionTable extends StatefulWidget {
  final int currentDptId;
  final int empId;
  final List<Map<String, dynamic>> initialTransactions;

  const BorrowingTransactionTable({
    super.key,
    required this.initialTransactions,
    required this.currentDptId,
    required this.empId,
  });

  @override
  State<BorrowingTransactionTable> createState() =>
      _BorrowingTransactionTableState();
}

class _BorrowingTransactionTableState extends State<BorrowingTransactionTable> {
  List<Map<String, dynamic>> transactions = [];

  @override
  void initState() {
    super.initState();
    transactions = List.from(widget.initialTransactions);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _buildDataTable(),
        ),
        ElevatedButton(
          onPressed: () {
            _showBorrowingTransactionDialog();
          },
          child: const Text('Add'),
        ),
      ],
    );
  }

  void _showBorrowingTransactionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BorrowingTransaction(
          empId: widget.empId,
          itemId: 1, // Replace with actual item ID
          itemName: "Test Item", // Replace with actual item name
          description: "Test Description", // Replace with actual description
          currentDptId: widget.currentDptId,
        );
      },
    ).then((result) {
      if (result != null && result is Map<String, dynamic>) { // Type check
        setState(() {
          transactions.add({
            'item_name': result['itemName'],
            'Description': result['description'],
            'quantity': result['quantity'],
            'Borrower': result['borrowerName'],
          });
        });
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
                  DataColumn(
                      label: Text('Item',
                          style: TextStyle(color: Colors.white))),
                  DataColumn(
                      label: Text('Description',
                          style: TextStyle(color: Colors.white))),
                  DataColumn(
                      label: Text('Quantity',
                          style: TextStyle(color: Colors.white))),
                  DataColumn(
                      label: Text('Borrower',
                          style: TextStyle(color: Colors.white))),
                ],
                rows: transactions.map((transaction) {
                  return DataRow(cells: [
                    DataCell(Text(transaction['item_name'] ?? '')), 
                    DataCell(Text(transaction['Description'] ?? '')), 
                    DataCell(Text(transaction['quantity'].toString())),
                    DataCell(Text(transaction['Borrower'] ?? 'N/A')),
                  ]);
                }).toList(),
              ),
            ),
          )
        : const SizedBox();
  }
}