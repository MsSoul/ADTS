//filename: lib/services/notif_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:logger/logger.dart';

class NotifApi {
  final String baseUrl;
  io.Socket? socket;
  final Logger logger = Logger(); // Logger instance

  NotifApi({required this.baseUrl});

  // Initialize WebSocket connection
  void initSocket(int empId, Function(dynamic) onNotificationReceived) {
    socket = io.io(baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket!.connect();

    socket!.onConnect((_) {
      logger.i("Connected to WebSocket");
      socket!.emit("joinRoom", empId);
    });

    socket!.on("newNotification", (data) {
      logger.i("New Notification: $data");
      onNotificationReceived(data);
    });

    socket!.onDisconnect((_) => logger.w("Disconnected from WebSocket"));
  }

  // Fetch unread notifications
  Future<List<Map<String, dynamic>>> fetchNotifications(int empId) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/api/notifications/$empId"));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        logger.d("Fetched Notifications: $data");
        return List<Map<String, dynamic>>.from(data);
      } else {
        logger.e("Failed to load notifications, Status Code: ${response.statusCode}");
        throw Exception("Failed to load notifications");
      }
    } catch (e) {
      logger.e("Error fetching notifications: $e");
      throw Exception("Error fetching notifications");
    }
  }

  // Mark notification as read
  Future<void> markAsRead(int notifId) async {
    try {
      final response = await http.put(Uri.parse("$baseUrl/api/notifications/read/$notifId"));

      if (response.statusCode == 200) {
        logger.i("Notification ID $notifId marked as read");
      } else {
        logger.e("Failed to mark notification as read, Status Code: ${response.statusCode}");
        throw Exception("Failed to mark notification as read");
      }
    } catch (e) {
      logger.e("Error marking notification as read: $e");
      throw Exception("Error marking notification as read");
    }
  }

  // Create a new notification (for testing)
  Future<void> createNotification(String message, int forEmp, int transactionId) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/notifications"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "message": message,
          "for_emp": forEmp,
          "transaction_id": transactionId,
        }),
      );

      if (response.statusCode == 201) {
        logger.i("Notification sent: $message to Employee ID: $forEmp");
      } else {
        logger.e("Failed to send notification, Status Code: ${response.statusCode}");
        throw Exception("Failed to create notification");
      }
    } catch (e) {
      logger.e("Error creating notification: $e");
      throw Exception("Error creating notification");
    }
  }

  // Close the WebSocket connection
  void dispose() {
    socket?.disconnect();
    socket?.destroy();
    logger.w("WebSocket connection closed");
  }
}
