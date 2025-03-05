//filename: lib/notification.dart
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../services/notif_api.dart';
import '../services/config.dart';
import 'design/nav_bar.dart';

class NotifScreen extends StatefulWidget {
  final int empId; // Pass the Employee ID

  const NotifScreen({super.key, required this.empId});

  @override
  State<NotifScreen> createState() => _NotifScreenState();
}

class _NotifScreenState extends State<NotifScreen> {
  final NotifApi notifApi = NotifApi(baseUrl: Config.baseUrl);
  final Logger logger = Logger();
  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
    _setupSocket();
  }

  // Fetch notifications from API
  Future<void> _fetchNotifications() async {
    try {
      List<Map<String, dynamic>> fetchedNotifs = await notifApi.fetchNotifications(widget.empId);

      setState(() {
        notifications = fetchedNotifs;
        isLoading = false;
      });

      logger.i("✅ Notifications fetched successfully");
    } catch (e, stacktrace) {
      logger.e("❌ Error fetching notifications: $e");
      logger.e(stacktrace); // Logs the exact error trace
      setState(() => isLoading = false);
    }
  }

  // Initialize WebSocket for real-time updates
  void _setupSocket() {
    notifApi.initSocket(widget.empId, (newNotif) {
      setState(() {
        notifications.insert(0, newNotif);
      });
      logger.i("🔔 New notification received: ${newNotif['message']}");
    });
  }

  @override
  void dispose() {
    notifApi.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: BottomNavBar(
        onMenuItemSelected: (String title) {
          setState(() {});
        },
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? const Center(
                  child: Text(
                    "NO NOTIFICATIONS SO FAR!",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text("Message", style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("Transaction ID", style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("Status", style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: notifications.map((notif) {
                        return DataRow(
                          color: WidgetStateProperty.resolveWith<Color?>(
                              (states) => (notif['read'] ?? 1) == 0 ? Colors.red.shade100 : null),
                          cells: [
                            DataCell(Text(notif['message'] ?? "No Message")), // Handle null message
                            DataCell(Text(notif['transaction_id']?.toString() ?? "N/A")), // Handle null transaction ID
                            DataCell(Text((notif['read'] ?? 1) == 0 ? "Unread" : "Read")), // Default to 'Read' if null
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
    );
  } 
}
