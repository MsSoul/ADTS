//filename:lib/services/user_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'config.dart';

class UserApi {
  final String baseUrl = Config.baseUrl;
  final Logger logger = Logger();

  // 🔹 Login Function (Fixed to store emp_id instead of id_number)
  Future<Map<String, dynamic>> login(String idNumber, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/users/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id_number": idNumber.trim(), "password": password.trim()}),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        int? empId = responseData["emp_id"];
        String? idNumber = responseData["id_number"];
        String? firstName = responseData["first_name"];
        int? currentDptId = responseData["current_dpt_id"];
        String? token = responseData["token"];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        if (empId != null) await prefs.setInt('emp_id', empId);
        if (idNumber != null) await prefs.setString('id_number', idNumber);
        if (firstName != null && firstName.isNotEmpty) {
          await prefs.setString('firstLetter', firstName.substring(0, 1).toUpperCase());
        }
        if (currentDptId != null) await prefs.setInt('currentDptId', currentDptId);
        if (token != null) await prefs.setString('token', token);

        logger.i("Login successful: emp_id=$empId, currentDptId=$currentDptId");
        return responseData;
      } else {
        logger.w("Login failed: ${responseData["msg"] ?? "Invalid credentials"}");
        return {"error": responseData["msg"] ?? "Invalid credentials"};
      }
    } catch (e) {
      logger.e("Login error: $e");
      return {"error": "Failed to connect to the server."};
    }
  }

  // 🔹 Update User Function (Fixed to use emp_id)
  Future<Map<String, dynamic>> updateUser(int empId, String email, String password) async {
    try {
      logger.i("Sending Update Request: emp_id=$empId, email=$email");

      final response = await http.post(
        Uri.parse("$baseUrl/api/users/update"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "emp_id": empId,
          "email": email,
          "password": password,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData.containsKey("success")) {
          logger.i("Update successful: ${responseData["success"]}");
          return {"success": responseData["success"]};
        }
        return {"error": "Unexpected response format."};
      }

      logger.w("Update failed: ${responseData["error"] ?? "Invalid request data."}");
      return {"error": responseData["error"] ?? "Invalid request data."};
    } catch (e) {
      logger.e("Update error: $e");
      return {"error": "Failed to connect to the server. Please check your internet connection."};
    }
  }

  // 🔹 Get User Details Function
  Future<Map<String, dynamic>> getUserDetails() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      int? empId = prefs.getInt("emp_id");

      if (empId == null) {
        logger.w("Employee ID not found in preferences");
        return {"error": "Employee ID not found in preferences"};
      }

      final response = await http.get(Uri.parse("$baseUrl/api/users/$empId"));
      final Map<String, dynamic> userData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (userData.containsKey("current_dpt_id")) {
          await prefs.setInt('currentDptId', userData["current_dpt_id"]);
          logger.i("User details fetched: currentDptId=${userData["current_dpt_id"]}");
        }
        return userData;
      } else {
        logger.w("Failed to fetch user details");
        return {"error": "Failed to fetch user details"};
      }
    } catch (e) {
      logger.e("Get user details error: $e");
      return {"error": "Network error"};
    }
  }
}

/*gana ni ilisan lang kay nka prin instead of logger
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';

class UserApi {
  final String baseUrl = Config.baseUrl;

  // 🔹 Login Function (Fixed to store emp_id instead of id_number)
  Future<Map<String, dynamic>> login(String idNumber, String password) async {
  try {
    final response = await http.post(
      Uri.parse("$baseUrl/api/users/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"id_number": idNumber.trim(), "password": password.trim()}),
    );

    final Map<String, dynamic> responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      int? empId = responseData["emp_id"];
      String? idNumber = responseData["id_number"];
      String? firstName = responseData["first_name"];
      int? currentDptId = responseData["current_dpt_id"];
      String? token = responseData["token"];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (empId != null) {
        await prefs.setInt('emp_id', empId); // ✅ Store emp_id
      }
      if (idNumber != null) {
        await prefs.setString('id_number', idNumber); // ✅ Store id_number
      }
      if (firstName != null && firstName.isNotEmpty) {
        await prefs.setString('firstLetter', firstName.substring(0, 1).toUpperCase());
      }
      if (currentDptId != null) {
        await prefs.setInt('currentDptId', currentDptId);
      }
      if (token != null) {
        await prefs.setString('token', token); // ✅ Store token for authentication
      }

      return responseData;
    } else if (response.statusCode == 400) {
      return {"error": responseData["msg"] ?? "Invalid credentials"};
    } else {
      return {"error": "Unexpected error occurred. Please try again."};
    }
  } catch (e) {
    return {"error": "Failed to connect to the server."};
  }
}

  // 🔹 Update User Function (Fixed to use emp_id)
  Future<Map<String, dynamic>> updateUser(int empId, String email, String password) async {
    try {
      print("🔹 Sending Update Request: emp_id: $empId, email: $email");

      final response = await http.post(
        Uri.parse("$baseUrl/api/users/update"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "emp_id": empId,
          "email": email,
          "password": password,
        }),
      );

      print("🔹 Response Status: ${response.statusCode}");
      print("🔹 Response Body: ${response.body}");

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData.containsKey("success")) {
          print("✅ Update successful: ${responseData["success"]}");
          return {"success": responseData["success"]};
        }
        return {"error": "Unexpected response format."};
      }

      if (response.statusCode == 400) {
        print("⚠️ Client-side error: ${responseData["error"]}");
        return {"error": responseData["error"] ?? "Invalid request data."};
      }

      if (response.statusCode >= 500) {
        print("❌ Server Error: ${responseData["error"]}");
        return {"error": "Server error. Please try again later."};
      }

      return {"error": responseData["error"] ?? "Failed to update user. Please try again."};
    } catch (e) {
      print("❌ Exception: $e");
      return {"error": "Failed to connect to the server. Please check your internet connection."};
    }
  }

  // 🔹 Get User Details Function 
  Future<Map<String, dynamic>> getUserDetails() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      int? empId = prefs.getInt("emp_id");

      if (empId == null) return {"error": "Employee ID not found in preferences"};

      final response = await http.get(Uri.parse("$baseUrl/api/users/$empId"));

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = jsonDecode(response.body);

        if (userData.containsKey("current_dpt_id")) {
          await prefs.setInt('currentDptId', userData["current_dpt_id"]);
        }

        return userData;
      } else {
        return {"error": "Failed to fetch user details"};
      }
    } catch (e) {
      return {"error": "Network error"};
    }
  }
}
*/
/*import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';

class UserApi {
  final String baseUrl = Config.baseUrl;

  // 🔹 Login Function (Unchanged - Uses id_number)
  Future<Map<String, dynamic>> login(String idNumber, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/users/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id_number": idNumber.trim(), "password": password.trim()}),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        String? firstName = responseData["first_name"];
        int? currentDptId = responseData["current_dpt_id"];

        if (firstName != null && firstName.isNotEmpty) {
          String firstLetter = firstName.substring(0, 1);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('firstLetter', firstLetter);
        }

        if (currentDptId != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setInt('currentDptId', currentDptId);
        }

        return responseData;
      } else if (response.statusCode == 400) {
        return {"error": responseData["msg"] ?? "Invalid credentials"};
      } else {
        return {"error": "Unexpected error occurred. Please try again."};
      }
    } catch (e) {
      return {"error": "Failed to connect to the server."};
    }
  }

  // 🔹 Update User Function (Fixed ID to emp_id)
  Future<Map<String, dynamic>> updateUser(int empId, String email, String password) async {
    try {
      print("🔹 Sending Update Request: emp_id: $empId, email: $email");

      final response = await http.post(
        Uri.parse("$baseUrl/api/users/update"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "emp_id": empId, // ✅ Using emp_id as the primary key
          "email": email,
          "password": password,
        }),
      );

      print("🔹 Response Status: ${response.statusCode}");
      print("🔹 Response Body: ${response.body}");

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData.containsKey("success")) {
          print("✅ Update successful: ${responseData["success"]}");
          return {"success": responseData["success"]};
        }
        return {"error": "Unexpected response format."};
      }

      if (response.statusCode == 400) {
        print("⚠️ Client-side error: ${responseData["error"]}");
        return {"error": responseData["error"] ?? "Invalid request data."};
      }

      if (response.statusCode >= 500) {
        print("❌ Server Error: ${responseData["error"]}");
        return {"error": "Server error. Please try again later."};
      }

      return {"error": responseData["error"] ?? "Failed to update user. Please try again."};
    } catch (e) {
      print("❌ Exception: $e");
      return {"error": "Failed to connect to the server. Please check your internet connection."};
    }
  }

  // 🔹 Get User Details Function (Fixed ID to emp_id)
  Future<Map<String, dynamic>> getUserDetails() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      int? empId = prefs.getInt("emp_id");

      if (empId == null) return {"error": "Employee ID not found in preferences"};

      final response = await http.get(Uri.parse("$baseUrl/api/users/$empId"));

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = jsonDecode(response.body);

        if (userData.containsKey("current_dpt_id")) {
          await prefs.setInt('currentDptId', userData["current_dpt_id"]);
        }

        return userData;
      } else {
        return {"error": "Failed to fetch user details"};
      }
    } catch (e) {
      return {"error": "Network error"};
    }
  }
}
*/

/*
// filename: lib/services/user_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';

class UserApi {
  final String baseUrl = Config.baseUrl;

  // 🔹 Login Function
  Future<Map<String, dynamic>> login(String idNumber, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/users/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id_number": idNumber.trim(), "password": password.trim()}),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Extract user data
        String? firstName = responseData["first_name"];
        int? currentDptId = responseData["current_dpt_id"];

        // Save first letter of first name
        if (firstName != null && firstName.isNotEmpty) {
          String firstLetter = firstName.substring(0, 1);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('firstLetter', firstLetter);
        }

        // Save currentDptId
        if (currentDptId != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setInt('currentDptId', currentDptId);
        }

        return responseData;
      } else if (response.statusCode == 400) {
        return {"error": responseData["msg"] ?? "Invalid credentials"};
      } else {
        return {"error": "Unexpected error occurred. Please try again."};
      }
    } catch (e) {
      return {"error": "Failed to connect to the server."};
    }
  }
// user_api.dart - Update User Function  
Future<Map<String, dynamic>> updateUser(int empId, String email, String password) async {
  try {
    print("🔹 Sending Update Request: empId: $empId, email: $email");

    final response = await http.post(
      Uri.parse("$baseUrl/api/users/update"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "emp_id": empId,  // ✅ Ensure emp_id is used as the primary key
        "email": email,
        "password": password,
      }),
    );

    print("🔹 Response Status: ${response.statusCode}");
    print("🔹 Response Body: ${response.body}");

    final Map<String, dynamic> responseData = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (responseData.containsKey("success")) {
        print("✅ Update successful: ${responseData["success"]}");
        return {"success": responseData["success"]};
      }
      return {"error": "Unexpected response format."};
    }

    if (response.statusCode == 400) {
      print("⚠️ Client-side error: ${responseData["error"]}");
      return {"error": responseData["error"] ?? "Invalid request data."};
    }

    if (response.statusCode >= 500) {
      print("❌ Server Error: ${responseData["error"]}");
      return {"error": "Server error. Please try again later."};
    }

    return {"error": responseData["error"] ?? "Failed to update user. Please try again."};
  } catch (e) {
    print("❌ Exception: $e");
    return {"error": "Failed to connect to the server. Please check your internet connection."};
  }
}

   // 🔹 Get User Details Function
  Future<Map<String, dynamic>> getUserDetails() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      int? empId = prefs.getInt("emp_id");

      if (empId == null) return {"error": "Employee ID not found in preferences"};

      final response = await http.get(Uri.parse("$baseUrl/api/users/$empId"));

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = jsonDecode(response.body);

        // Save currentDptId
        if (userData.containsKey("current_dpt_id")) {
          await prefs.setInt('currentDptId', userData["current_dpt_id"]);
        }

        return userData;
      } else {
        return {"error": "Failed to fetch user details"};
      }
    } catch (e) {
      return {"error": "Network error"};
    }
  }
}
*/

/*
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';

class UserApi {
  final String baseUrl = Config.baseUrl;

  // 🔹 Login Function
  Future<Map<String, dynamic>> login(String idNumber, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/users/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id_number": idNumber.trim(), "password": password.trim()}),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Extract first letter of first name safely
        String? firstName = responseData["first_name"];
        if (firstName != null && firstName.isNotEmpty) {
          String firstLetter = firstName.substring(0, 1); // Safe extraction
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('firstLetter', firstLetter);
        }

        return responseData;
      } else if (response.statusCode == 400) {
        return {"error": responseData["msg"] ?? "Invalid credentials"};
      } else {
        return {"error": "Unexpected error occurred. Please try again."};
      }
    } catch (e) {
      return {"error": "Failed to connect to the server."};
    }
  }

  // 🔹 Update User Function
  Future<Map<String, dynamic>> updateUser(String idNumber, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/users/update"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id_number": idNumber,
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData.containsKey("msg") 
            ? {"success": responseData["msg"]} 
            : {"error": "Unexpected response format."};
      } else if (response.statusCode >= 500) {
        return {"error": "Server error. Please try again later."};
      } else {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return {"error": responseData["msg"] ?? "Failed to update user. Please try again."};
      }
    } catch (e) {
      return {"error": "Failed to connect to the server."};
    }
  }

  // 🔹 Get User Details Function
  Future<Map<String, dynamic>> getUserDetails() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? idNumber = prefs.getString("id_number");

      if (idNumber == null) return {"error": "User ID not found in preferences"};

      final response = await http.get(Uri.parse("$baseUrl/api/users/$idNumber"));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"error": "Failed to fetch user details"};
      }
    } catch (e) {
      return {"error": "Network error"};
    }
  }
}
*/

/*
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';

class UserApi {
  final String baseUrl = Config.baseUrl;

  // 🔹 Login Function
  Future<Map<String, dynamic>> login(String idNumber, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/users/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id_number": idNumber.trim(), "password": password.trim()}),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Extract first letter of first name if available
        String? firstName = responseData["first_name"];
        if (firstName != null && firstName.isNotEmpty) {
          String firstLetter = firstName[0];
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('firstLetter', firstLetter);
        }

        return responseData;
      } else if (response.statusCode == 400) {
        return {"error": responseData["msg"] ?? "Invalid credentials"};
      } else {
        return {"error": "Unexpected error occurred. Please try again."};
      }
    } catch (e) {
      return {"error": "Failed to connect to the server."};
    }
  }

  Future<Map<String, dynamic>> updateUser(String idNumber, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/users/update"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id_number": idNumber,
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> responseData = jsonDecode(response.body);

          // Ensure response contains a success message
          if (responseData.containsKey("msg")) {
            return {"success": responseData["msg"]};
          } else {
            return {"error": "Unexpected response format."};
          }
        } catch (e) {
          return {"error": "Invalid server response."};
        }
      } else if (response.statusCode >= 500) {
        return {"error": "Server error. Please try again later."};
      } else {
        try {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          return {"error": responseData["msg"] ?? "Failed to update user. Please try again."};
        } catch (e) {
          return {"error": "Unexpected error occurred."};
        }
      }
    } catch (e) {
      return {"error": "Failed to connect to the server."};
    }
  }

  Future<Map<String, dynamic>> getUserDetails() async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? idNumber = prefs.getString("id_number");

    if (idNumber == null) return {"error": "User ID not found in preferences"};

    final response = await http.get(Uri.parse("$baseUrl/api/users/$idNumber"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {"error": "Failed to fetch user details"};
    }
  } catch (e) {
    return {"error": "Network error"};
  }
}


}*/


/*
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

class UserApi {
  final String baseUrl = Config.baseUrl;

  // 🔹 Login Function
  Future<Map<String, dynamic>> login(String idNumber, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/users/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id_number": idNumber.trim(), "password": password.trim()}),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Ensure we return all necessary data, including redirect
        return responseData; 
      } else if (response.statusCode == 400) {
        return {"error": responseData["msg"] ?? "Invalid credentials"};
      } else {
        return {"error": "Unexpected error occurred. Please try again."};
      }
    } catch (e) {
      return {"error": "Failed to connect to the server."};
    }
  }


  Future<Map<String, dynamic>> updateUser(String idNumber, String email, String password) async {
  try {
    final response = await http.post(
      Uri.parse("$baseUrl/api/users/update"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "id_number": idNumber,
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Ensure response contains a success message
        if (responseData.containsKey("msg")) {
          return {"success": responseData["msg"]};
        } else {
          return {"error": "Unexpected response format."};
        }
      } catch (e) {
        return {"error": "Invalid server response."};
      }
    } else if (response.statusCode >= 500) {
      return {"error": "Server error. Please try again later."};
    } else {
      try {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return {"error": responseData["msg"] ?? "Failed to update user. Please try again."};
      } catch (e) {
        return {"error": "Unexpected error occurred."};
      }
    }
  } catch (e) {
    return {"error": "Failed to connect to the server."};
  }
}

}

*/