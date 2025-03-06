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

Widget buildBorrowDialogTitle() {
  return const Center(
    child: Text(
      'Request Borrow Item',
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

Widget buildTextField(String label, String hint, { 
  TextEditingController? controller, 
  Function(String)? onChanged, 
  String? errorText, 
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          if (errorText != null) // Show error message inline
            Padding(
              padding: const EdgeInsets.only(left: 8), // Add spacing from label
              child: Text(
                errorText,
                style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      const SizedBox(height: 3), // Small spacing
      SizedBox(
        height: 40,
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: TextInputType.number, 
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
      const SizedBox(height: 3), // Keep spacing consistent
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
      // Cancel Button
      SizedBox(
        width: 120,
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the main dialog
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey[700],
            backgroundColor: Colors.grey[200],
          ),
          child: const Text('Cancel'),
        ),
      ),
      const SizedBox(width: 10),
      // Request Button
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

            // Show Confirmation Dialog
            bool confirm = await showDialog(
              context: context,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  backgroundColor: Colors.white,
                  title: const Text('Confirm Request'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDialogText("Item", widget.itemName),
                      _buildDialogText("Description", widget.description),
                      _buildDialogText("Quantity", quantity.toString()),
                      _buildDialogText("Borrower Name", borrowerController.text),
                    ],
                  ),
                  actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Cancel Button
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
                        // Confirm Button
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
                  ],
                );
              },
            );

            if (!context.mounted || confirm != true) return; // Check if confirmed

            try {
              // 🔥 Submit Transaction
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

              if (!context.mounted) return;

              // ✅ Show Success Dialog (After Closing Confirmation)
              await showDialog(
                context: context,
                barrierDismissible: false, // Prevent accidental closing
                builder: (BuildContext successContext) {
                  return AlertDialog(
                  title: const Text('🎉 Success!'),
                  content: Text(response['message'] ?? 'Request submitted successfully!'),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(successContext).pop(); // Close Success Dialog
                        Navigator.of(context).pop(); // Close Main Dialog
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('OK'),
                    ),
                  ],
                );
                },
              );
            } catch (e) {
              if (context.mounted) {
                logger.e("Error submitting transaction: $e");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error submitting request: $e')),
                );
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

// 📌 Helper function for dialog text
Widget _buildDialogText(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 14, color: Colors.black),
        children: [
          TextSpan(text: "$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: value),
        ],
      ),
    ),
  );
}

