//filename: lib/table_borrowing_transaction.dart
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
  State<BorrowingTransactionTable> createState() => _BorrowingTransactionTableState();
}

class _BorrowingTransactionTableState extends State<BorrowingTransactionTable> {
  List<Map<String, dynamic>> transactions = []; // Initialize an empty list

  @override
  void initState() {
    super.initState();
    transactions = List.from(widget.initialTransactions); // Copy initial data
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
     // _showBorrowingTransactionDialog({}); // Call with the argument
    },
    child: const Text('Add'),
        ),
      ],
    );
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
                    DataCell(Text(transaction['item_name'])),
                    DataCell(Text(transaction['Description'])),
                    DataCell(Text(transaction['quantity'].toString())),
                    DataCell(Text(transaction['Borrower'] ?? 'N/A')),
                  ]);
                }).toList(),
                 ),
            ),
          )
        : const SizedBox();
  }

/*void _showBorrowingTransactionDialog(Map<String, dynamic>? item) async { // Make item nullable
  if (item == null) {
    // Handle the case where item is null (e.g., show a message).
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No item selected')),
    );
    return; // Important: Exit the function early
  }

  final newTransaction = await showDialog<Map<String, dynamic>>(
    context: context,
    builder: (BuildContext context) {
      return BorrowingTransaction(
        empId: widget.empId,
        itemId: item['id'], // Provide default value if null
        itemName: item['name'], // Provide default value if null
        description: item['description'], // Provide default value if null
        borrower: item['borrower'],
        currentDptId: widget.currentDptId,
        quantity: item['quantity'], // Provide default value if null
      );
    },
  );

  if (newTransaction != null) {
    setState(() {
      transactions.add(newTransaction);
    });
  }
}*/
}