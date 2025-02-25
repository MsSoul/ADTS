// filename: lib/design/lending_widgets.dart
import 'package:flutter/material.dart';
import 'colors.dart';
import 'package:logger/logger.dart';
import '../services/lend_transaction_api.dart';
import '../services/config.dart'; // Import Config

final Logger logger = Logger();
final LendTransactionApi lendTransactionApi = LendTransactionApi(Config.baseUrl); 

Widget buildDialogTitle() {
  return const Center(
    child: Text(
      'Request Lent Item',
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

// Add button function
Widget buildActionButtons(
  BuildContext context, 
  TextEditingController qtyController, 
  TextEditingController borrowerController, 
  dynamic widget, 
  {required int? selectedBorrowerId} 
) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      SizedBox(
        width: 120,
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
        width: 120,
        child: ElevatedButton(
          onPressed: () async {
            int? quantity = int.tryParse(qtyController.text);
            
            if (quantity == null || quantity <= 0) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid quantity.')),
                );
              }
              return;
            }

            if (selectedBorrowerId == null) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select a borrower.')),
                );
              }
              return;
            }

            // Create transaction data
            Map<String, dynamic> transactionData = {
              'current_dpt_Id': widget.currentDptId,
              'empId': widget.empId,
              'itemId': widget.itemId,
              'itemName': widget.itemName,
              'description': widget.description,
              'quantity': quantity,
              'borrower': borrowerController.text,
              'borrowerId': selectedBorrowerId,
              'currentDptId': widget.currentDptId,  
            };

            // 🔍 Log the transaction data
            logger.i("Transaction Data: $transactionData");

            // Show confirmation dialog
            bool confirm = await showDialog(
              context: context,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  title: const Text('Confirm Request'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 14, color: Colors.black),
                          children: [
                            const TextSpan(text: "Item: ", style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: transactionData['itemName']),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 14, color: Colors.black),
                          children: [
                            const TextSpan(text: "Description: ", style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: transactionData['description']),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 14, color: Colors.black),
                          children: [
                            const TextSpan(text: "Quantity: ", style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: transactionData['quantity'].toString()),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 14, color: Colors.black),
                          children: [
                            const TextSpan(text: "Borrower Name: ", style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: transactionData['borrower'].toString()),
                          ],
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: 120,
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(dialogContext).pop(false),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                foregroundColor: Colors.black, 
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 120,
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(dialogContext).pop(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Confirm'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );

            if (!context.mounted) return; // Check if the widget is still mounted

            if (confirm == true) {
              try {
                // 🔥 Call API function to submit the transaction
                final response = await lendTransactionApi.submitLendingTransaction(
                empId: widget.empId,
                itemId: widget.itemId,
                itemName: widget.itemName,
                description: widget.description,
                quantity: quantity,
                borrowerId: selectedBorrowerId,
                currentDptId: widget.currentDptId, 
                );
logger.i("Submitting Lending Transaction with Borrower ID: $selectedBorrowerId");

                if (context.mounted) {
                  // 🎉 Success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(response['message'] ?? 'Request submitted successfully!')),
                  );

                  // Close the dialog
                  Navigator.of(context).pop();
                }
              } catch (e) {
                if (context.mounted) {
                  // ❌ Error handling
                  logger.e("Error submitting transaction: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error submitting request: $e')),
                  );
                }
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Request'),
        ),
      ),
    ],
  );
}




