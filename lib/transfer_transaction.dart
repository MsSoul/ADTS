import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'design/colors.dart';
import 'services/transfer_transaction_api.dart';
import '../services/config.dart';

class TransferTransactionDialog extends StatefulWidget {
  final int empId;
  final int itemId;
  final String itemName;
  final String description;
  final int currentDptId;
  final int availableQuantity;

  const TransferTransactionDialog({
    super.key,
    required this.empId,
    required this.itemId,
    required this.itemName,
    required this.description,
    required this.currentDptId,
    required this.availableQuantity,
  });

  @override
  TransferTransactionDialogState createState() => TransferTransactionDialogState();
}

class TransferTransactionDialogState extends State<TransferTransactionDialog> {
  final TextEditingController qtyController = TextEditingController();
  final TextEditingController employeeController = TextEditingController();
  final TransferTransactionApi transferApi = TransferTransactionApi(Config.baseUrl);
  final Logger logger = Logger();

  String searchType = "ID Number";
  bool isLoading = false;
  bool isConfirmEnabled = false;
  bool _employeeSelected = false;

  List<Map<String, dynamic>> searchResults = [];
  int? selectedEmployeeId;
  String? quantityError;

  @override
  void initState() {
    super.initState();
    qtyController.addListener(_validateQuantity);
  }

  Future<void> fetchEmployeeDetails(String input) async {
    logger.i("Fetching employee details for Department ID: ${widget.currentDptId}");

    if (widget.currentDptId == -1) {
      logger.w("Invalid Department ID - Using Default ID");
      return;
    }

    setState(() => isLoading = true);

    try {
      final employeeData = await transferApi.fetchEmployees(
        widget.currentDptId.toString(),
        input,
        searchType,
        widget.empId.toString(),
      );

      setState(() {
        searchResults = employeeData;
        isLoading = false;
      });

      if (employeeData.isEmpty) {
        logger.w("No employees found.");
      } else {
        logger.i("Fetched ${employeeData.length} employee(s)");
      }
    } catch (e, stackTrace) {
      logger.e("Error fetching employee details:", error: e, stackTrace: stackTrace);
      setState(() => isLoading = false);
    }
  }

  void _validateQuantity() {
    setState(() {
      String value = qtyController.text;
      if (value.isEmpty) {
        quantityError = "Quantity cannot be empty.";
        isConfirmEnabled = false;
      } else {
        int enteredQuantity = int.tryParse(value) ?? 0;
        if (enteredQuantity <= 0) {
          quantityError = "Quantity must be at least 1.";
          isConfirmEnabled = false;
        } else if (enteredQuantity > widget.availableQuantity) {
          quantityError = "Maximum available quantity is ${widget.availableQuantity}.";
          isConfirmEnabled = false;
        } else {
          quantityError = null;
          isConfirmEnabled = selectedEmployeeId != null;
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
                    _buildDialogTitle(),
                    _buildInfoBox('Item Name:', widget.itemName),
                    _buildInfoBox('Description:', widget.description),
                    _buildTextField('Quantity:', 'Enter Quantity', controller: qtyController, errorText: quantityError),
                    _buildEmployeeField(),
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
    return const Text(
      "Transfer Item",
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
    );
  }

  Widget _buildInfoBox(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text("$label ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, {required TextEditingController controller, String? errorText}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          errorText: errorText,
          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryColor)),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryColor, width: 2)),
        ),
      ),
    );
  }

  Widget _buildEmployeeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoBox('Transfer To:', employeeController.text),
        if (!_employeeSelected)
          Row(
            children: [
              _buildDropdown(),
              const SizedBox(width: 10),
              Expanded(child: _buildSearchField()),
            ],
          ),
        if (!_employeeSelected && isLoading) const CircularProgressIndicator(),
        if (!_employeeSelected && searchResults.isNotEmpty) _buildSearchResultsList(),
      ],
    );
  }

  Widget _buildDropdown() {
    return SizedBox(
      width: 130,
      height: 40,
      child: DropdownButton<String>(
        value: searchType,
        isExpanded: true,
        onChanged: (String? newValue) {
          setState(() {
            searchType = newValue!;
            employeeController.clear();
            searchResults = [];
            _employeeSelected = false;
          });
        },
        items: ['ID Number', 'Name'].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, style: const TextStyle(fontSize: 14)),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: employeeController,
      onChanged: (value) => value.isNotEmpty ? fetchEmployeeDetails(value) : setState(() => searchResults = []),
    );
  }

  Widget _buildSearchResultsList() {
    return Column(
      children: searchResults.map((employee) {
        return ListTile(
          title: Text("${employee['FIRSTNAME']} ${employee['LASTNAME']}"),
          subtitle: Text("ID: ${employee['ID_NUMBER']}"),
          onTap: () {
            setState(() {
              employeeController.text = "${employee['FIRSTNAME']} ${employee['LASTNAME']}";
              selectedEmployeeId = employee['employeeId'];
              searchResults = [];
              _employeeSelected = true;
              isConfirmEnabled = qtyController.text.isNotEmpty;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: isConfirmEnabled ? () {
            logger.i("Confirming transfer of ${qtyController.text} items to Employee ID: $selectedEmployeeId");
            Navigator.pop(context);
          } : null,
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
