//filename:lib/deisgn/login_deisgn.dart
import 'package:flutter/material.dart';
import '../design/colors.dart';


// Logo Widget
Widget buildLogo(double size) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Image.asset(
        'assets/logo.png',
        height: size * 0.3,
        width: size * 0.3,
      ),
      const SizedBox(width: 5), // Space between images
      Image.asset(
        'assets/adts-logo.png',
        height: size * 0.3,
        width: size * 0.3,
      ),
    ],
  );
}


// Custom Text Field Widget
Widget buildTextField(
  String label, {
  TextEditingController? controller,
  bool obscureText = false,
  Function()? onToggleVisibility,
}) {
  return TextField(
    controller: controller,
    obscureText: obscureText,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.primaryColor),
        borderRadius: BorderRadius.circular(10),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.primaryColor),
        borderRadius: BorderRadius.circular(10),
      ),
      suffixIcon: onToggleVisibility != null
          ? IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey, // Adjust color as needed
              ),
              onPressed: onToggleVisibility,
            )
          : null, // Show icon only for password fields
    ),
  );
}


// Forgot Password Button
Widget buildForgotPasswordButton(BuildContext context, VoidCallback onPressed) {
  return Align(
    alignment: Alignment.centerRight,
    child: TextButton(
      onPressed: onPressed,
      child: const Text(
        'Forgot Password?',
        style: TextStyle(
          color: AppColors.primaryColor,
          fontSize: 14,
        ),
      ),
    ),
  );
}

// Login Button
Widget buildLoginButton(String buttonText, VoidCallback onPressed) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: () {
        onPressed();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        buttonText,
        style: const TextStyle(fontSize: 18, color: Colors.white),
      ),
    ),
  );
}
