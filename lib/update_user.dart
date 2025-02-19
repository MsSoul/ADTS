//filename: lib/update_users.dart
import 'package:flutter/material.dart';
import 'design/colors.dart';
import 'design/login_design.dart';
import 'notif_alert_prompt/alert.dart';
import 'services/user_api.dart';
import 'main.dart';

class UpdateUserScreen extends StatefulWidget {
  final int empId; 

  const UpdateUserScreen({super.key, required this.empId});

  @override
  UpdateUserScreenState createState() => UpdateUserScreenState();
}

class UpdateUserScreenState extends State<UpdateUserScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final UserApi _userApi = UserApi();

  bool get _isFormValid {
    return _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;
  }

  Widget buildCustomTextField(String label, TextEditingController controller, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.primaryColor),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.primaryColor),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.primaryColor),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Future<void> _updateUser() async {
    if (!_isFormValid) {
      debugPrint("Form is incomplete. Email: ${_emailController.text}, Password: ${_passwordController.text}");
      showIncompleteFormDialog(context);
      return;
    }

    String email = _emailController.text;
    String password = _passwordController.text;
    int empId = widget.empId;

    debugPrint("Sending update request for Employee ID: $empId, Email: $email");

    try {
      final response = await _userApi.updateUser(empId, email, password);
      debugPrint("Update response: $response");

      if (!mounted) return;

      if (response.containsKey("success")) {
        _showSuccessDialog(" ${response["success"]}");
      } else if (response.containsKey("error")) {
        _showErrorDialog(response["error"]);
      } else {
        _showErrorDialog("Unexpected response format: ${response.toString()}");
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog("An unexpected error occurred.");
    }
  }

  void _showSuccessDialog(String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Success"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await Future.delayed(const Duration(milliseconds: 500));
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Update Required"),
              content: const Text("You must update your account before leaving."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        }
      },
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),
                  buildLogo(constraints.maxWidth),
                  const SizedBox(height: 20),
                  const Text(
                    "PLEASE UPDATE YOUR ACCOUNT",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 30),
                  buildCustomTextField('Email', _emailController),
                  const SizedBox(height: 20),
                  buildCustomTextField('Password', _passwordController, obscureText: true),
                  const SizedBox(height: 30),
                  buildLoginButton('Update', _updateUser),
                  const Spacer(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}


/*
import 'package:flutter/material.dart';
import 'design/colors.dart';
import 'design/login_design.dart';
import 'notif_alert_prompt/alert.dart';
import 'services/user_api.dart';
import 'main.dart';

class UpdateUserScreen extends StatefulWidget {
  final String idNumber;
  final int dptId;

  const UpdateUserScreen({super.key, required this.idNumber, required this.dptId});

  @override
  UpdateUserScreenState createState() => UpdateUserScreenState();
}

class UpdateUserScreenState extends State<UpdateUserScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final UserApi _userApi = UserApi();

  bool get _isFormValid {
    return _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;
  }

  Widget buildCustomTextField(String label, TextEditingController controller, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.primaryColor),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.primaryColor),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.primaryColor),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Future<void> _updateUser() async {
  if (!_isFormValid) {
    debugPrint("Form is incomplete. Email: ${_emailController.text}, Password: ${_passwordController.text}");
    showIncompleteFormDialog(context);
    return;
  }

  String email = _emailController.text;
  String password = _passwordController.text;
  String idNumber = widget.idNumber;
  int dptId = widget.dptId;

  debugPrint("Sending update request for ID: $idNumber, Email: $email, DPT ID: $dptId");

  try {
    final response = await _userApi.updateUser(idNumber, email, password, dptId);
    debugPrint("Update response: $response");

    if (!mounted) return;

    if (response.containsKey("success")) {
      _showSuccessDialog(" ${response["success"]}");
    } else if (response.containsKey("error")) {
      _showErrorDialog(response["error"]);
    } else {
      _showErrorDialog("Unexpected response format: ${response.toString()}");
    }
  } catch (e) {
    if (!mounted) return;
    _showErrorDialog("An unexpected error occurred.");
  }
}

  void _showSuccessDialog(String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Success"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await Future.delayed(const Duration(milliseconds: 500));
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Update Required"),
              content: const Text("You must update your account before leaving."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        }
      },
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),
                  buildLogo(constraints.maxWidth),
                  const SizedBox(height: 20),
                  const Text(
                    "PLEASE UPDATE YOUR ACCOUNT",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 30),
                  buildCustomTextField('Email', _emailController),
                  const SizedBox(height: 20),
                  buildCustomTextField('Password', _passwordController, obscureText: true),
                  const SizedBox(height: 30),
                  buildLoginButton('Update', _updateUser),
                  const Spacer(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
*/