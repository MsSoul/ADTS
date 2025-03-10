import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../services/borrow_transaction_api.dart';
import 'dart:convert';
import 'borrow_transaction.dart';
import '../design/colors.dart';

class BorrowItemsScreen extends StatefulWidget {
  final int currentDptId;
  final int empId;

  const BorrowItemsScreen(
      {super.key, required this.currentDptId, required this.empId});

  @override
  State<BorrowItemsScreen> createState() => _BorrowItemsScreenState();
}

class _BorrowItemsScreenState extends State<BorrowItemsScreen> {
  late BorrowTransactionApi _allItemsApi;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _pageController = TextEditingController();
  final Logger log = Logger();

  List<Map<String, dynamic>> allItems = [];
  List<Map<String, dynamic>> filteredItems = [];
  bool isLoading = true;
  bool hasError = false;

  int currentPage = 0;
  int itemsPerPage = 10;
  late int empId;
  late int currentDptId;

  @override
  void initState() {
    super.initState();
    currentDptId = widget.currentDptId;
    empId = widget.empId;
    log.i("💡 Current Department ID: $currentDptId");
    _allItemsApi = BorrowTransactionApi();

    _loadAllItems();
  }

  Future<void> _loadAllItems() async {
    try {
      final items = await _allItemsApi.fetchAllItems(currentDptId, empId);

      log.i("🔍 Full API Response: ${jsonEncode(items)}");

      setState(() {
        allItems = items.map((item) {
          log.i(
              "📦 Item: ${item['name']} | ID: ${item['id']} (DistributedItemId)");

          return {
            ...item,
            'distributed_item_id':
                item['id'] // Assign `id` as `distributedItemId`
          };
        }).toList();

        filteredItems = List.from(allItems);
        isLoading = false;
      });
    } catch (e) {
      log.e("❌ Error fetching borrowable items: $e");
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

  void _changePage(int newPage) {
    setState(() {
      currentPage = newPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    int totalPages = (filteredItems.length / itemsPerPage).ceil();
    _pageController.text = (currentPage + 1).toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Items to Borrow',
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
                    '⚠ Failed to load items. Please try again later.',
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
                      // Search Box with Rounded Border
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: SizedBox(
                          height: 40, // Set the desired height
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              labelText: 'Search Items to Borrow',
                              labelStyle: const TextStyle(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              prefixIcon: const Icon(Icons.search,
                                  color: AppColors.primaryColor),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: AppColors.primaryColor, width: 2),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: AppColors.primaryColor, width: 3),
                              ),
                            ),
                            onChanged: _searchItems,
                          ),
                        ),
                      ),

                      // Pagination Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: AppColors.primaryColor),
                            onPressed: currentPage > 0
                                ? () => _changePage(currentPage - 1)
                                : null,
                          ),
                          Text("Page ${currentPage + 1} of $totalPages"),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward,
                                color: AppColors.primaryColor),
                            onPressed: currentPage < totalPages - 1
                                ? () => _changePage(currentPage + 1)
                                : null,
                          ),
                        ],
                      ),

                      // Items Table
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primaryColor, width: 2),borderRadius: BorderRadius.circular(10),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: WidgetStateColor.resolveWith(
                                (states) => AppColors.primaryColor),
                            dataRowMinHeight: 40,
                            dataRowMaxHeight: 40,
                            headingRowHeight: 40,
                            columns: const [
                              DataColumn(
                                  label: Center(child: Text('Action',style:TextStyle(color: Colors.white)))),
                              DataColumn(
                                  label: Center(child: Text('Owner',style:TextStyle(color: Colors.white)))),
                              DataColumn(
                                  label: Text('Item Name',style: TextStyle(color: Colors.white))),
                              DataColumn(
                                  label: Text('Description',style: TextStyle(color: Colors.white))),
                              DataColumn(
                                  label: Text('Quantity',style: TextStyle(color: Colors.white))),
                              DataColumn(
                                  label: Center(child: Text('ICS',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)))),
                              DataColumn(
                                  label: Center(child: Text('ARE No.',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)))),
                              DataColumn(
                                  label: Center(child: Text('Prop No.',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)))),
                              DataColumn(
                                  label: Center(child: Text('Serial No.',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)))),
                        ],
                            rows: filteredItems
                                .skip(currentPage * itemsPerPage)
                                .take(itemsPerPage)
                                .map((item) {
                              return DataRow(cells: [
                                DataCell(
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryColor,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8),),
                                      minimumSize: const Size(80, 35),
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                    ),
                                    onPressed: () async {
                                      String borrowerName = await _allItemsApi
                                          .fetchUserName(empId);

                                      int distributedItemId = item['id']; // Use `id` instead of `distributed_item_id`

                                      log.i("🛠 Opening BorrowTransaction: distributedItemId=$distributedItemId");

                                      showDialog(
                                        context: context,
                                        builder: (context) => BorrowTransaction(
                                          empId: empId,
                                          currentDptId: currentDptId,
                                          distributedItemId:distributedItemId, // Pass `id` here
                                          itemName: item['name'],
                                          description: item['description'],
                                          availableQuantity: item['quantity'],
                                          ownerId: item['accountable_emp'],
                                          owner: item['accountable_name'] ??'Unknown',
                                          borrower: borrowerName,
                                        ),
                                      );
                                    },
                                    child: const Text('Borrow'),
                                  ),
                                ),
                                DataCell(Text(
                                  item['accountable_name'] != null? item['accountable_name']
                                          .split(' ')
                                          .map((word) => word.isNotEmpty
                                              ? word[0].toUpperCase() +
                                                  word
                                                      .substring(1)
                                                      .toLowerCase()
                                              : '')
                                          .join(' ')
                                      : 'Unknown',
                                )),
                                DataCell(Text(item['name'])),
                                DataCell(Text(item['description'])),
                                DataCell(Text(item['quantity'] != null? item['quantity'].toString(): 'N/A')),
                                DataCell(Text(item['ics']?.toString() ?? 'N/A')),
                                DataCell(Text(item['are_no']?.toString() ?? 'N/A')),
                                DataCell(Text(item['prop_no']?.toString() ?? 'N/A')),
                                DataCell(Text(item['serial_no']?.toString() ?? 'N/A')),
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
