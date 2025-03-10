//filename: borrow_transaction.dart
import 'package:flutter/material.dart';
import 'package:ibs/design/colors.dart';
import 'services/borrow_transaction_api.dart';
import 'package:logger/logger.dart';
import 'design/lending_widgets.dart';
import 'design/borrowing_widgets.dart';

class BorrowTransaction extends StatefulWidget {
  final int empId;
  final int distributedItemId;
  final String itemName;
  final String description;
  final int availableQuantity;
  final String owner;
  final int ownerId;
  final int currentDptId;
  final String borrower;

  const BorrowTransaction({
    super.key,
    required this.empId,
    required this.currentDptId,
    required this.distributedItemId,
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
    logger.i("📩 BorrowTransaction Initialized: distributedItemId=${widget.distributedItemId}");
    _fetchBorrowerName();
  }

  /// Fetch borrower name using empId
  Future<void> _fetchBorrowerName() async {
    try {
      logger.i("Fetching borrower name for empId: ${widget.empId}");
      String? name = await borrowApi.fetchUserName(widget.empId);
      if (name.isEmpty) {
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
          quantityError =
              "Maximum available quantity is ${widget.availableQuantity}.";
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
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context)
                    .viewInsets
                    .bottom, // Adjust for keyboard
              ),
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(maxWidth: constraints.maxWidth * 0.9),
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
                      buildInfoBox(
                        'Owner:',
                        widget.owner
                            .split(' ')
                            .map((word) => word.isNotEmpty
                                ? word[0].toUpperCase() +
                                    word.substring(1).toLowerCase()
                                : '')
                            .join(' '),
                      ),
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : buildInfoBox(
                              'Borrower:', borrowerName ?? "Unknown"),
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
          ),
        );
      },
    );
  }

  Widget buildBorrowActionButton(BuildContext context,
      TextEditingController qtyController, BorrowTransaction widget) {
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

            // Check if quantity is valid
            if (qty <= 0 || qty > widget.availableQuantity) {
              setState(() {
                quantityError = (qty > widget.availableQuantity)
                    ? "Maximum available quantity is ${widget.availableQuantity}."
                    : "Please enter a valid quantity.";
              });

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(quantityError!),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              return; // Stop further execution
            }

            // Proceed with confirmation
            bool confirm = await showBorrowConfirmationDialog(
              context: context,
              itemName: widget.itemName,
              description: widget.description,
              quantity: qty,
              ownerName: widget.owner,
              borrowerName: widget.borrower,
              distributedItemId: widget.distributedItemId,
            );

            if (confirm) {
              bool success = await processBorrowTransaction(
                borrowerId: widget.empId,
                ownerId: widget.ownerId,
                distributedItemId: widget.distributedItemId,
                quantity: qty,
                currentDptId: widget.currentDptId,
                context: context,
              );

              if (success) {
                logger.i("distributedid: ${widget.distributedItemId}");
                Navigator.pop(context); // Close borrow transaction dialog

                // Show success dialog
                if (context.mounted) {
                  await showSuccessDialog(context: context);
                }
              } else {
                logger.e("Failed to borrow item.");
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text("Confirm"),
        ),
      ],
    );
  }

  // Process borrow transaction API call
  Future<bool> processBorrowTransaction({
    required int borrowerId,
    required int ownerId,
    required int distributedItemId,
    required int quantity,
    required int currentDptId,
    required BuildContext context,
  }) async {
    BorrowTransactionApi borrowApi = BorrowTransactionApi();
    logger.i("Quantity to send: $quantity");
    bool success = await borrowApi.processBorrowTransaction(
      context: context,
      borrowerId: borrowerId,
      ownerId: ownerId,
      distributedItemId: distributedItemId,
      quantity: quantity,
      currentDptId: currentDptId,
    );
logger.i("📤 Sending borrow request: {"
    " borrower_emp_id: ${widget.empId},"
    " owner_emp_id: ${widget.ownerId},"
    " distributedItemId: ${widget.distributedItemId},"
    " quantity: ${qtyController.text},"
    " currentDptId: ${widget.currentDptId}"
    " }"
);

    return success;
  }
}
