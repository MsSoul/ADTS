//filename:lib/ borrowing_transaction.dart
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
  final TextEditingController qtyController = TextEditingController();
  final TextEditingController borrowerController = TextEditingController();
  final BorrowTransactionApi borrowApi = BorrowTransactionApi(Config.baseUrl);
  final Logger logger = Logger();

  String searchType = "ID Number";
  bool isLoading = false;
  List<Map<String, dynamic>> searchResults = [];

  Future<void> fetchBorrowerDetails(String input) async {
  logger.i("Fetching borrower details for Department ID: ${widget.currentDptId}");

  if (widget.currentDptId == -1) {
    logger.w("Invalid Department ID - Using Default ID");
    return;
  }

  setState(() => isLoading = true);

  try {
    final borrowerData = await borrowApi.fetchBorrowers(
      widget.currentDptId.toString(),
      input,
      searchType,
      widget.empId.toString(),
    );

    if (borrowerData.isNotEmpty) {
      logger.i("First borrower: ${borrowerData[0]}");
      setState(() {
        searchResults = borrowerData;
        isLoading = false;
      });
      logger.i("Fetched ${borrowerData.length} borrower(s)");
    } else {
      logger.w("No borrowers found.");
      setState(() {
        searchResults = [];
        isLoading = false;
      });
    }
  } catch (e, stackTrace) {
    logger.e("Error fetching borrower details:", error: e, stackTrace: stackTrace);
    setState(() => isLoading = false);
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
                    _buildDialogTitle(),
                    _buildInfoBox('Item Name:', widget.itemName),
                    _buildInfoBox('Description:', widget.description),
                    _buildTextField('Quantity:', 'Enter Quantity', controller: qtyController),
                    _buildBorrowerField(),
                    _buildActionButtons(context),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogTitle() {
    return const Center(
      child: Text(
        'Borrowing Transaction',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoBox(String label, String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 238, 247, 255),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primaryColor, width: 1.5),
          ),
          child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 5),
      ],
    );
  }

  Widget _buildTextField(String label, String hint, {TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 5),
      ],
    );
  }

 Widget _buildBorrowerField() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildInfoBox('Borrower:', borrowerController.text),
      Row(
        children: [
          _buildDropdown(),
          const SizedBox(width: 10),
          Expanded(child: _buildSearchField()),
        ],
      ),
      const SizedBox(height: 5), // Space between search field and results
      if (isLoading) const CircularProgressIndicator(),
      if (searchResults.isNotEmpty) _buildSearchResultsList(),
    ],
  );
}

Widget _buildSearchField() {
  return TextField(
    controller: borrowerController,
    style: const TextStyle(color: AppColors.primaryColor),
    decoration: InputDecoration(
      labelStyle: const TextStyle(color: AppColors.primaryColor),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.primaryColor),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
      ),
      // Clear button appears when text is entered
      suffixIcon: borrowerController.text.isNotEmpty
          ? IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: () {
                setState(() {
                  borrowerController.clear(); // Clear text
                  searchResults = []; // Hide results
                });
              },
            )
          : null,
    ),
    onChanged: (value) {
      if (value.isNotEmpty) {
        fetchBorrowerDetails(value);
      } else {
        setState(() => searchResults = []);
      }
    },
  );
}

Widget _buildSearchResultsList() {
  return Padding(
    padding: const EdgeInsets.only(left: 140), // External left padding
    child: Positioned(
      right: 10,
      top: 50,
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 200), // Limit max height
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: searchResults.length > 5 ? 5 : searchResults.length, // Limit to 5 users
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final borrower = searchResults[index];

              int? idNumber = borrower['ID_NUMBER'] is int ? borrower['ID_NUMBER'] : null;
              String formattedName = _capitalizeName(
                '${borrower['FIRSTNAME'] ?? ''} '
                '${(borrower['MIDDLENAME'] ?? '').isNotEmpty ? borrower['MIDDLENAME'][0] + "." : ''} '
                '${borrower['LASTNAME'] ?? ''}'
              );

              return InkWell(
                onTap: () {
                  setState(() {
                    borrowerController.text = formattedName;
                    searchResults = [];
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Row(
                    children: [
                      Text(
                        idNumber?.toString() ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          formattedName,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ),
  );
}

// Function to capitalize each word in the name properly
String _capitalizeName(String name) {
  return name.split(' ').map((word) {
    if (word.isEmpty) return '';
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}

Widget _buildDropdown() {
  return SizedBox(
    width: 130, 
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: DropdownButton<String>(
          value: searchType,
          isExpanded: true,
          onChanged: (String? newValue) {
            setState(() {
              searchType = newValue!;
              borrowerController.clear();
              searchResults = [];
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
          underline: Container(), // Remove default underline
        ),
      ),
    ),
  );
}

Widget _buildActionButtons(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        style: TextButton.styleFrom(
          foregroundColor: Colors.grey[700],
        ),
        child: const Text('Cancel'),
      ),
      const SizedBox(width: 10),
      ElevatedButton(
        onPressed: () => Navigator.of(context).pop(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
        ),
        child: const Text('Add'),
      ),
    ],
  );
}
}