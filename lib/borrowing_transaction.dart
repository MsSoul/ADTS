//filename:lib/borrowing_transaction.dart
import 'package:flutter/material.dart';
import 'design/colors.dart';
import '../services/borrow_transaction_api.dart'; 
import '../services/config.dart';
import 'package:logger/logger.dart';


class BorrowingTransaction extends StatefulWidget {
  final int empId;
  final int itemId;
  final String itemName;
  final String description;
  final int currentDptId;

  const BorrowingTransaction({
    super.key,
    required this.empId,
    required this.itemId,
    required this.itemName,
    required this.description,
    required this.currentDptId,
  });
  @override
  BorrowingTransactionState createState() => BorrowingTransactionState();
}

class BorrowingTransactionState extends State<BorrowingTransaction> {
  TextEditingController qtyController = TextEditingController();
  TextEditingController borrowerController = TextEditingController();
  String searchType = "ID Number";
  bool isLoading = false;
  BorrowTransactionApi borrowApi = BorrowTransactionApi(Config.baseUrl); 
  final logger = Logger();

 Future<void> fetchBorrowerDetails(String input) async {
  final int departmentId = widget.currentDptId;
  logger.d("Current Department ID: ${widget.currentDptId}");

  if (departmentId == -1) {
    logger.w("Invalid Department ID");
    return;
  }

  setState(() {
    isLoading = true;
  });

  try {
    final borrowerData = await borrowApi.fetchBorrowers(
      departmentId, 
      input, 
      searchType, 
    );

    if (borrowerData.isNotEmpty) {
      setState(() {
      borrowerController.text = searchType == "ID Number"
      ? (borrowerData[0]['name'] ?? 'Unknown')
      : (borrowerData[0]['id']?.toString() ?? '0');
      });
    } else {
      logger.i("No borrower found");
    }
  } catch (e) {
    logger.e("Error fetching borrower details: $e");
  } finally {
    setState(() {
      isLoading = false;
    });
  }
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
              constraints: BoxConstraints(
                maxWidth: constraints.maxWidth * 0.9,
              ),
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
                    const Center(
                      child: Text(
                        'Borrowing Transaction',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildInfoBox('Item Name:'),
                    _buildReadOnlyField(widget.itemName),
                    const SizedBox(height: 10),
                    _buildInfoBox('Description:'),
                    _buildReadOnlyField(widget.description),
                    const SizedBox(height: 10),
                    _buildInfoBox('Quantity:'),
                    _buildTextField('Enter Quantity', controller: qtyController),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoBox('Borrower:'),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: DropdownButton<String>(
                                value: searchType,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    searchType = newValue!;
                                    borrowerController.clear();
                                  });
                                },
                                items: ['ID Number', 'Name'].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value, style: const TextStyle(color: Colors.white)),
                                  );
                                }).toList(),
                                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                                dropdownColor: AppColors.primaryColor,
                                style: const TextStyle(color: Colors.white),
                                underline: Container(),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildTextField(
                                'Enter Borrower',
                                controller: borrowerController,
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    fetchBorrowerDetails(value);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        if (isLoading)
                          const Padding(
                            padding: EdgeInsets.only(top: 5),
                            child: CircularProgressIndicator(),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.grey,
                          ),
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Add'),
                          onPressed: () {
                            Navigator.of(context).pop({
                              'emp_id': widget.empId,
                              'item_name': widget.itemName,
                              'description': widget.description,
                              'quantity': qtyController.text,
                              'search_type': searchType,
                              'borrower': borrowerController.text,
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoBox(String label) {
    return Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black));
  }

  Widget _buildReadOnlyField(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 238, 247, 255),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primaryColor, width: 1.5),
      ),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
  }

  Widget _buildTextField(String hint, {TextEditingController? controller, Function(String)? onChanged}) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[500]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
        ),
      ),
      style: const TextStyle(color: Colors.black),
    );
  }
}
