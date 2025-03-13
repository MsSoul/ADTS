import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../services/items_api.dart';
import '../design/colors.dart';
import 'transfer_transaction.dart';

class TransferItemsScreen extends StatefulWidget {
  final int currentDptId;
  final int empId;

  const TransferItemsScreen({
    super.key,
    required this.currentDptId,
    required this.empId,
  });

  @override
  State<TransferItemsScreen> createState() => _TransferItemsScreenState();
}

class _TransferItemsScreenState extends State<TransferItemsScreen> {
  final ItemsApi _itemsApi = ItemsApi();
  final TextEditingController _searchController = TextEditingController();
  final Logger log = Logger();

  List<Map<String, dynamic>> allItems = [];
  List<Map<String, dynamic>> filteredItems = [];
  bool isLoading = true;
  bool hasError = false;

  int currentPage = 0;
  int itemsPerPage = 5;
  late int empId;
  late int currentDptId;

  @override
  void initState() {
    super.initState();
    currentDptId = widget.currentDptId;
    log.i("Current Department ID: $currentDptId");
    _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      int? fetchedEmpId = await _itemsApi.getEmpId();

      if (fetchedEmpId != null && fetchedEmpId > 0) {
        empId = fetchedEmpId;
        final items = await _itemsApi.fetchItems(empId);

        setState(() {
          allItems = items.map((item) {
            return {
              ...item,
              'distributedItemId': item['distributedItemId'] ?? 0,
              'ITEM_ID': item['ITEM_ID'],
              'quantity': item['quantity'] as int? ?? 0,
            };
          }).toList();

          filteredItems = List.from(allItems);
          isLoading = false;
        });
      } else {
        log.w("⚠️ Invalid Employee ID, unable to fetch items.");
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    } catch (e, stackTrace) {
      log.e("❌ Error fetching items: $e", error: e, stackTrace: stackTrace);
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  void _searchItems(String query) {
    setState(() {
      filteredItems = allItems
          .where((item) =>
              item['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
      currentPage = 0;
    });
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Items to Transfer',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.primaryColor,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? const Center(
                  child: Text(
                    'Failed to load items. Please try again later.',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search Bar
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              labelText: 'Search Items to Transfer',
                              labelStyle: const TextStyle(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              prefixIcon: _searchController.text.isEmpty
                                  ? const Icon(Icons.search,
                                      color: AppColors.primaryColor)
                                  : null,
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear,
                                          color: AppColors.primaryColor),
                                      onPressed: () {
                                        setState(() {
                                          _searchController.clear();
                                          _searchItems('');
                                        });
                                      },
                                    )
                                  : null,
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: AppColors.primaryColor, width: 2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: AppColors.primaryColor, width: 2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 10),
                            ),
                            onChanged: (value) => _searchItems(value),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Table Section
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: AppColors.primaryColor, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: WidgetStateColor.resolveWith(
                                (states) => AppColors.primaryColor),
                            columns: const [
                              DataColumn(
                                  label: Center(
                                      child: Text(' Action',
                                          style:
                                              TextStyle(color: Colors.white)))),
                              DataColumn(
                                  label: Text('Name',
                                      style: TextStyle(color: Colors.white))),
                              DataColumn(
                                  label: Text('Description',
                                      style: TextStyle(color: Colors.white))),
                              DataColumn(
                                  label: Text('Quantity',
                                      style: TextStyle(color: Colors.white))),
                              DataColumn(
                                  label: Center(
                                      child: Text('ICS',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)))),
                              DataColumn(
                                  label: Center(
                                      child: Text('ARE No.',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)))),
                              DataColumn(
                                  label: Center(
                                      child: Text('Prop No.',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)))),
                              DataColumn(
                                  label: Center(
                                      child: Text('Serial No.',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)))),
                            ],
                            rows: filteredItems
                                .skip(currentPage * itemsPerPage)
                                .take(itemsPerPage)
                                .map((item) {
                              return DataRow(cells: [
                                DataCell(
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      backgroundColor: AppColors.primaryColor,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () {
                                      int itemId = item['ITEM_ID'];

                                      log.i(
                                          "🔄 Opening TransferTransaction: itemId=$itemId");

                                      showDialog(
                                        context: context,
                                        builder: (context) =>
                                            TransferTransactionDialog(
                                          empId: widget.empId,
                                          itemId: itemId,
                                          itemName: item['name'],
                                          description: item['description'],
                                          currentDptId: widget.currentDptId,
                                          availableQuantity: item['quantity'],
                                        ),
                                      );
                                    },
                                    child: const Text('Transfer'),
                                  ),
                                ),
                                DataCell(Text(item['name'])),
                                DataCell(Text(item['description'])),
                                DataCell(Text(item['quantity'].toString())),
                                DataCell(
                                    Text(item['ics']?.toString() ?? 'N/A')),
                                DataCell(
                                    Text(item['are_no']?.toString() ?? 'N/A')),
                                DataCell(
                                    Text(item['prop_no']?.toString() ?? 'N/A')),
                                DataCell(Text(
                                    item['serial_no']?.toString() ?? 'N/A')),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
