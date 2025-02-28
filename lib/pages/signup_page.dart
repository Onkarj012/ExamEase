import 'package:flutter/material.dart';
import 'package:ocr_app/pages/classroom_list_page.dart';

import '../services/auth_service.dart';
import 'login_page.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  int currentPart = 1;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> signUp() async {
    try {
      String username = _usernameController.text.trim();
      String fullName = _fullNameController.text.trim();
      String phoneNumber = _phoneNumberController.text.trim();
      String password = _passwordController.text.trim();

      var statusCode = await AuthService().signUp(
        username,
        fullName,
        phoneNumber,
        password,
      );

      if (statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ClassroomListPage()),
        );
      } else {
        String? message;
        if (statusCode == 404) {
          message = 'User not found';
        } else if (statusCode == 401) {
          message = 'Invalid credentials.';
        } else if (statusCode == 500) {
          message = 'Internal Server error.';
        }
        showErrorDialog(message!);
      }
    } catch (e) {
      showErrorDialog(e.toString());
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.school,
                size: 80,
                color: Color(0xFF0A1D37),
              ),
              SizedBox(height: 10),
              Text(
                "ExamEase",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A1D37),
                ),
              ),
              SizedBox(height: 30),
              if (currentPart == 1) ...[
                buildTextField("Full Name", "John Doe", Icons.person_outline, _fullNameController),
                SizedBox(height: 15),
                buildTextField("Phone Number", "123-456-7890", Icons.phone, _phoneNumberController),
              ] else if (currentPart == 2) ...[
                buildTextField("Username", "john_doe", Icons.person, _usernameController),
                SizedBox(height: 15),
                buildPasswordField("Password", "Enter your password", _passwordController),
                SizedBox(height: 15),
                buildConfirmPasswordField("Confirm Password", "Re-enter your password"),
              ],
              SizedBox(height: 25),
              ElevatedButton(
                onPressed: () {
                  if (currentPart == 1) {
                    setState(() {
                      currentPart = 2;
                    });
                  } else {
                    signUp();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0A1D37),
                  minimumSize: Size(400, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  currentPart == 1 ? "Next" : "Create Account",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              if (currentPart == 2) ...[
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[400])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "Or continue with",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey[400])),
                  ],
                ),
                SizedBox(height: 20),
                buildSocialButton("Google", "G", Color(0xFF0A1D37)),
              ],
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.grey[700],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: Text(
                      "Sign in",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A1D37),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, String hint, IconData icon, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0A1D37),
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          style: TextStyle(fontFamily: 'Poppins'),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.grey[600],
            ),
            prefixIcon: Icon(icon, color: Colors.grey[700]),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildPasswordField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0A1D37),
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: !_isPasswordVisible,
          style: TextStyle(fontFamily: 'Poppins'),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.grey[600],
            ),
            prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[700]),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey[700],
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildConfirmPasswordField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0A1D37),
          ),
        ),
        SizedBox(height: 8),
        TextField(
          obscureText: !_isConfirmPasswordVisible,
          style: TextStyle(fontFamily: 'Poppins'),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.grey[600],
            ),
            prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[700]),
            suffixIcon: IconButton(
              icon: Icon(
                _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey[700],
              ),
              onPressed: () {
                setState(() {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                });
              },
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSocialButton(String label, String icon, Color color) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: Size(400, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(width: 10),
          Icon(
            Icons.accessibility_new, // Use appropriate icon for the social button
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
