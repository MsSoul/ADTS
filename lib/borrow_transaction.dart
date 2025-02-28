import 'package:flutter/material.dart';
import 'package:ibs/design/colors.dart';
import 'services/borrow_transaction_api.dart';
import 'package:logger/logger.dart';
import 'design/lending_widgets.dart'; 

class BorrowTransaction extends StatefulWidget {
  final int empId; // Logged-in user (Borrower)
  final int itemId;
  final String itemName;
  final String description;
  final int availableQuantity;
  final String owner; // Owner's name
  final int ownerId; // Owner's ID
  final int currentDptId;
  final String borrower;

  const BorrowTransaction({
    super.key,
    required this.empId,
    required this.currentDptId,
    required this.itemId,
    required this.itemName,
    required this.description,
    required this.availableQuantity,
    required this.owner,
    required this.ownerId, 
    required this.borrower,
  });

  @override
  BorrowTransactionState createState() => BorrowTransactionState();
}

class BorrowTransactionState extends State<BorrowTransaction> {
  final TextEditingController qtyController = TextEditingController();
  final BorrowTransactionApi borrowApi = BorrowTransactionApi();
  final Logger logger = Logger();
  
  String? quantityError;
  String? borrowerName; // Store borrower name
  bool isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    _fetchBorrowerName();
  }

    /// Fetch borrower name using empId
  Future<void> _fetchBorrowerName() async {
    try {
      logger.i("Fetching borrower name for empId: ${widget.empId}");
      String? name = await borrowApi.fetchUserName(widget.empId);
      
      if (name == null || name.isEmpty) {
        logger.e("Error: Borrower name not found for empId ${widget.empId}");
        setState(() {
          borrowerName = "Error: Name not found";
          isLoading = false;
        });
      } else {
        logger.i("Borrower name fetched successfully: $name");
        setState(() {
          borrowerName = name;
          isLoading = false;
        });
      }
    } catch (e) {
      logger.e("Exception while fetching borrower name: $e");
      setState(() {
        borrowerName = "Error fetching name";
        isLoading = false;
      });
    }
  }


  void _validateQuantity(String value) {
  setState(() {
    if (value.isEmpty) {
      quantityError = "Quantity cannot be empty.";
    } else {
      int enteredQuantity = int.tryParse(value) ?? 0;
      if (enteredQuantity <= 0) {
        quantityError = "Quantity must be at least 1.";
      } else if (enteredQuantity > widget.availableQuantity) {
        quantityError = "Maximum available quantity is ${widget.availableQuantity}.";
      } else {
        quantityError = null; // Clear error if input is valid
      }
    }
  });
}

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth * 0.05,
            vertical: constraints.maxHeight * 0.05,
          ),
          backgroundColor: Colors.transparent,
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.9),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildBorrowDialogTitle(),
                    buildInfoBox('Item Name:', widget.itemName),
                    buildInfoBox('Description:', widget.description),
                    buildInfoBox('Owner:', 
                      widget.owner.split(' ')
                        .map((word) => word.isNotEmpty 
                          ? word[0].toUpperCase() + word.substring(1).toLowerCase() 
                          : ''
                        ).join(' ')
                    ),
                    isLoading 
                      ? const Center(child: CircularProgressIndicator()) // Show loading
                      : buildInfoBox('Borrower:', borrowerName ?? "Unknown"), // Show borrower name
                    
                    buildTextField(
                      'Quantity:', 
                      'Enter Quantity',
                      controller: qtyController, 
                      onChanged: _validateQuantity, 
                      errorText: quantityError,
                    ),
                    buildBorrowActionButton(context, qtyController, widget),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}Widget buildBorrowActionButton(
    BuildContext context, TextEditingController qtyController, BorrowTransaction widget) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      ElevatedButton(
        onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey[700],
            backgroundColor: Colors.grey[200], // Gray color for Cancel
        ),
        child: const Text("Cancel"),
      ),
      const SizedBox(width: 10),
      ElevatedButton(
        onPressed: () async {
          int qty = int.tryParse(qtyController.text) ?? 0;
          if (qty > 0) {
            bool success = await processBorrowTransaction(
              borrowerId: widget.empId,
              ownerId: widget.ownerId,
              itemId: widget.itemId,
              quantity: qty,
              currentDptId: widget.currentDptId,
            );

            if (success) {
              Navigator.pop(context);
              print("Item borrowed successfully!");
            } else {
              print("Failed to borrow item.");
            }
          } else {
            print("Invalid quantity.");
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor, // Primary color for Confirm Borrow
          foregroundColor: Colors.white, // White text color
        ),
        child: const Text("Confirm Borrow"),
      ),
    ],
  );
}

/// Process borrow transaction API call
Future<bool> processBorrowTransaction({
  required int borrowerId,
  required int ownerId,
  required int itemId,
  required int quantity,
  required int currentDptId,
}) async {
  BorrowTransactionApi borrowApi = BorrowTransactionApi();
  
  bool success = await borrowApi.processBorrowTransaction(
    borrowerId, 
    itemId, 
    quantity, 
    currentDptId,
  );

  return success;
}
