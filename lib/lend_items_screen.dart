//filenmae:lib/items.dart
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../services/items_api.dart';
import 'lend_transaction.dart';
import '../design/colors.dart';

class LendingItemsScreen extends StatefulWidget {
  final int currentDptId; 
  final int empId;
  const LendingItemsScreen({super.key, required this.currentDptId, required this.empId});

  @override
  State<LendingItemsScreen> createState() => _LendingItemsScreenState();
}

class _LendingItemsScreenState extends State<LendingItemsScreen> {
  final ItemsApi _itemsApi = ItemsApi();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _pageController = TextEditingController();
  final Logger log = Logger();


  List<Map<String, dynamic>> allItems = [];
  List<Map<String, dynamic>> filteredItems = [];
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;
  bool hasError = false;

  int currentPage = 0;
  int itemsPerPage = 5;
  late int empId;
  late int currentDptId;
  late String itemName;
  late String description;
  late int itemId;

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
        allItems = items.map((item) => {
              'id': item['id'],
              'name': item['name'],
              'description': item['description'],
              'quantity': item['quantity'],
              'ics': item['ics'],
              'are_no': item['are_no'],
              'prop_no': item['prop_no'],
              'serial_no': item['serial_no'],
              'empId': empId,
            }).toList();
        filteredItems = List.from(allItems);
        isLoading = false;
      });
    } else {
      log.w("Invalid Employee ID, unable to fetch items.");
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  } catch (e) {
    log.e("Error fetching items: $e");
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

  void _nextPage() {
    if ((currentPage + 1) * itemsPerPage < filteredItems.length) {
      setState(() {
        currentPage++;
        _pageController.text = (currentPage + 1).toString();
      });
    }
  }

  void _prevPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
        _pageController.text = (currentPage + 1).toString();
      });
    }
  }

  void _jumpToPage(String value) {
    int pageNumber = int.tryParse(value) ?? 1;
    int totalPages = (filteredItems.length / itemsPerPage).ceil();
    if (pageNumber >= 1 && pageNumber <= totalPages) {
      setState(() {
        currentPage = pageNumber - 1;
      });
    } else {
      _pageController.text = (currentPage + 1).toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalPages = (filteredItems.length / itemsPerPage).ceil();
    _pageController.text = (currentPage + 1).toString();

    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? const Center(
                  child: Text('Failed to load items. Please try again later.',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: AppColors.primaryColor),
                  ),
                )
              : Padding( padding: const EdgeInsets.all(10), 
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search Bar
                      Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: SizedBox(
                              height: 40, 
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  labelText: 'Search Items',
                                  labelStyle: const TextStyle(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  prefixIcon: _searchController.text.isEmpty
                                      ? const Icon(Icons.search, color: AppColors.primaryColor)
                                      : null,
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear, color: AppColors.primaryColor),
                                          onPressed: () {
                                            setState(() {
                                              _searchController.clear();
                                              _searchItems('');
                                            });
                                          },
                                        )
                                      : null,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: AppColors.primaryColor , width: 2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10), 
                                ),
                                onChanged: (value) => _searchItems(value),
                              ),
                            ),
                          ),

                      // Table Section
                      Container(
                        padding: const EdgeInsets.all(5), // Table Padding
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: AppColors.primaryColor, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: WidgetStateColor.resolveWith((states) => AppColors.primaryColor),
                                dataRowMinHeight: 40, 
                                dataRowMaxHeight: 40,
                                headingRowHeight: 40,
                            columns: const [
                              DataColumn(label: Center(child: Text(' Action', style: TextStyle(color: Colors.white)))),
                              DataColumn(label: Text('Name', style: TextStyle(color: Colors.white))),
                              DataColumn(label: Text('Description', style: TextStyle(color: Colors.white))),
                              DataColumn(label: Text('Quantity', style: TextStyle(color: Colors.white))),
                              DataColumn(label: Center(child: Text('ICS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)))),
                              DataColumn(label: Center(child: Text('ARE No.', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)))),
                              DataColumn(label: Center(child: Text('Prop No.', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)))),
                              DataColumn(label: Center(child: Text('Serial No.', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)))),
                            ],
                            rows: filteredItems
                                .skip(currentPage * itemsPerPage)
                                .take(itemsPerPage)
                                .map((item) {
                              return DataRow(cells: [
                               DataCell(
                                SizedBox(
                                  height: 35, // Set button height to 35px
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      backgroundColor: AppColors.primaryColor, 
                                      foregroundColor: Colors.white, 
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => LendingTransaction(
                                          empId: widget.empId, 
                                          itemId: item['id'],   
                                          itemName: item['name'],
                                          description: item['description'],
                                          currentDptId: widget.currentDptId, 
                                          initialTransactions: transactions,
                                          availableQuantity: item['quantity'], 
                                        ),
                                      );
                                    },
                                    child: const Text('Lend'),
                                  ),
                                ),
                              ),

                                    DataCell(Text(item['name'])),
                                    DataCell(Text(item['description'])),
                                    DataCell(Text(item['quantity'].toString())),
                                    DataCell(Text(item['ics']?.toString() ?? 'N/A')),
                                    DataCell(Text(item['are_no']?.toString() ?? 'N/A')),
                                    DataCell(Text(item['prop_no']?.toString() ?? 'N/A')),
                                    DataCell(Text(item['serial_no']?.toString() ?? 'N/A')),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),

                      // Pagination Controls (Right Corner Below the Table)
                      if (filteredItems.isNotEmpty)
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
                                onPressed: _prevPage,
                              ),

                              // Page Number Input
                              SizedBox(
                                width: 30, 
                                height: 30,
                                child: TextField(
                                  controller: _pageController,
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(fontSize: 12),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: AppColors.primaryColor),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 3, horizontal: 3),
                                  ),
                                  onSubmitted: _jumpToPage,
                                ),
                              ),

                              // Total Pages
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  "/ $totalPages",
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), 
                                ),
                              ),

                              // Next Page Button
                              IconButton(
                                icon: const Icon(Icons.arrow_forward_ios, color: AppColors.primaryColor),
                                onPressed: _nextPage,
                              ),
                            ],
                          ),
                        ),
                      ),
                  const SizedBox(height: 15),
        ],
      ),)
    );
  }
}