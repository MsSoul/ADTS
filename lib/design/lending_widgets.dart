//filename: lib/design/lending_widgets.dart
import 'package:flutter/material.dart';
import 'colors.dart';

Widget buildDialogTitle() {
  return const Center(
    child: Text(
      'Borrowing Transaction',
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  );
}

Widget buildInfoBox(String label, String text) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      Container(
        height: 40,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 238, 247, 255),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.primaryColor, width: 1),
        ),
        child: Text(text, style: const TextStyle(fontSize: 14)),
      ),
      const SizedBox(height: 3),
    ],
  );
}

Widget buildTextField(String label, String hint, {TextEditingController? controller}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      SizedBox(
        height: 40,
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8), 
            filled: true,
            fillColor: Colors.white,
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppColors.primaryColor, width: 1),
            ),
          ),
        ),
      ),
      const SizedBox(height: 3),
    ],
  );
}

//borrowinng_transaction.dart add button
Widget buildActionButtons(BuildContext context, TextEditingController qtyController, TextEditingController borrowerController, dynamic widget) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      SizedBox(
        width: 100,
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey[700],
            backgroundColor: Colors.grey[200],
          ),
          child: const Text('Cancel'),
        ),
      ),
      const SizedBox(width: 10),
      SizedBox(
        width: 100,
        child: ElevatedButton(
          onPressed: () {
            int? quantity = int.tryParse(qtyController.text);
            if (quantity == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Invalid quantity')),
              );
              return;
            }

            if (borrowerController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please select a borrower')),
              );
              return;
            }

            Navigator.of(context).pop({
              'current_dpt_Id': widget.currentDptId,
              'empId': widget.empId,
              'itemId': widget.itemId,
              'itemName': widget.itemName,
              'description': widget.description,
              'quantity': int.tryParse(qtyController.text),
              'borrowerName': borrowerController.text,
             // initialTransactions: widget.transactionList,
            });

          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Add'),
        ),
      ),
    ],
  );
}
