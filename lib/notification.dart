import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../services/notif_api.dart';
import '../services/config.dart';
import 'design/colors.dart';

class NotifScreen extends StatefulWidget {
  final int empId;

  const NotifScreen({super.key, required this.empId});

  @override
  State<NotifScreen> createState() => _NotifScreenState();
}

class _NotifScreenState extends State<NotifScreen> {
  final NotifApi notifApi = NotifApi(baseUrl: Config.baseUrl);
  final Logger logger = Logger();
  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;
  String selectedFilter = "Newest"; // Default sorting option
  bool showAllNotifications = false; // Flag to control visibility

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
    _setupSocket();
  }

  Future<void> _fetchNotifications() async {
    try {
      List<Map<String, dynamic>> fetchedNotifs =
          await notifApi.fetchNotifications(widget.empId);

      logger.i("📥 Raw Notifications Fetched: $fetchedNotifs");

      setState(() {
        notifications = fetchedNotifs;
        _sortNotifications();
        isLoading = false;
      });

      logger.i("✅ Notifications processed successfully");
    } catch (e, stacktrace) {
      logger.e("❌ Error fetching notifications: $e");
      logger.e(stacktrace);
      setState(() => isLoading = false);
    }
  }

  void _setupSocket() {
    notifApi.initSocket(widget.empId, (newNotif) {
      setState(() {
        notifications.insert(0, newNotif);
        _sortNotifications();
      });
      logger.i("🔔 New notification received: ${newNotif['message']}");
    });
  }

  void _markAsRead(int index) async {
    final notif = notifications[index];
    int? notifId = notif['id'] ?? notif['ID'];

    if (notifId == null) {
      logger.e("❌ Notification ID is null or invalid. Data: $notif");
      return;
    }

    if (isUnread(notif)) {
      try {
        await notifApi.markAsRead(notifId);
        setState(() {
          notifications[index]['read'] = 1;
        });
        logger.i("✅ Notification marked as read (ID: $notifId)");
      } catch (e) {
        logger.e("❌ Failed to mark as read: $e");
      }
    }
  }

  void _sortNotifications() {
    setState(() {
      if (selectedFilter == "Newest") {
        notifications.sort((a, b) => (b['id'] ?? 0).compareTo(a['id'] ?? 0));
      } else if (selectedFilter == "Oldest") {
        notifications.sort((a, b) => (a['id'] ?? 0).compareTo(b['id'] ?? 0));
      } else if (selectedFilter == "Unread First") {
        notifications.sort((a, b) => isUnread(a)
            ? -1
            : isUnread(b)
                ? 1
                : 0);
      }
    });
  }

  @override
  void dispose() {
    notifApi.dispose();
    super.dispose();
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return "Unknown date";
    DateTime date = DateTime.parse(dateString);
    return DateFormat('MMM dd, yyyy hh:mm a').format(date);
  }

  bool isUnread(Map<String, dynamic> notif) {
    return (notif['read'] ?? notif['READ'] ?? 0) == 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black.withAlpha(50),
        title: Row(
          children: [
            const Text(
              "Inbox",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Spacer(),
            PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list,
                  size: 28, color: Colors.black), // Icon color
              color: AppColors.primaryColor, // Background color of dropdown
              onSelected: (String value) {
                setState(() {
                  selectedFilter = value;
                  _sortNotifications();
                });
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: "Newest",
                  child: Text("Sort by Newest",
                      style: TextStyle(color: Colors.white)),
                ),
                const PopupMenuItem(
                  value: "Oldest",
                  child: Text("Sort by Oldest",
                      style: TextStyle(color: Colors.white)),
                ),
                const PopupMenuItem(
                  value: "Unread First",
                  child: Text("Sort by Unread First",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchNotifications,
              child: notifications.isEmpty
                  ? const Center(
                      child: Text(
                        "No new notifications!",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: showAllNotifications
                                ? notifications.length
                                : notifications.length > 10
                                    ? 10
                                    : notifications.length,
                            itemBuilder: (context, index) {
                              final notif = notifications[index];
                              bool isUnreadNotif = isUnread(notif);

                              return Card(
                                elevation: 4,
                                color: isUnreadNotif
                                    ? Colors.blue.shade50
                                    : Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                child: ListTile(
                                  leading: Icon(
                                    Icons.notifications,
                                    color: isUnreadNotif
                                        ? AppColors.primaryColor
                                        : Colors.grey,
                                  ),
                                  title: RichText(
                                    text: TextSpan(
                                      text: (notif['message'] ??
                                              notif['MESSAGE'] ??
                                              "No message")
                                          .split('\n')
                                          .take(2)
                                          .join('\n'),
                                      style: TextStyle(
                                        fontWeight: isUnreadNotif
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: Colors.black,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  subtitle: Text(
                                    "Date: ${_formatDate(notif['createdAt'])}",
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 119, 118, 118),
                                      fontSize: 10,
                                    ),
                                  ),
                                  trailing: Text(
                                    isUnreadNotif ? "Unread" : "Read",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isUnreadNotif
                                          ? AppColors.primaryColor
                                          : Colors.grey,
                                    ),
                                  ),
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text("Notification"),
                                        content: SingleChildScrollView(
                                          child: Text(notif['message'] ??
                                              notif['MESSAGE'] ??
                                              "No message"),
                                        ),
                                        actions: [
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.primaryColor,
                                            ),
                                            onPressed: () {
                                              Navigator.pop(context);
                                              _markAsRead(index);
                                            },
                                            child: const Text(
                                              "Close",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        if (notifications.length > 10 && !showAllNotifications)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  showAllNotifications = true;
                                });
                              },
                              child: const Text(
                                'See More',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
    );
  }
}
