import 'package:flutter/material.dart';
import 'package:ocr_app/pages/classroom_list_page.dart';
import '../services/auth_service.dart'; // Import AuthService
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isPasswordVisible = false;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> login() async {
    try {
      String username = _usernameController.text.trim();
      String password = _passwordController.text.trim();

      // Call the AuthService to perform login
      var response = await AuthService().login(username, password);

      if (response['message'] == 'Login successful') {
        // Navigate to HomePage if login is successful
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ClassroomListPage()),
        );
      } else {
        // Show error dialog if login fails
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text(response['message'] ?? 'Login failed. Please try again.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Handle exception and show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text(e.toString()),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
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
            crossAxisAlignment: CrossAxisAlignment.center,
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
              buildTextField("Username", "Enter your username", Icons.person_outline, _usernameController),
              SizedBox(height: 15),
              buildPasswordField("Password", "Enter your password", Icons.lock_outline, _passwordController),
              SizedBox(height: 25),
              ElevatedButton(
                onPressed: login, // Trigger login
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0A1D37),
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
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
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.grey[700],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignupPage()),
                      );
                    },
                    child: Text(
                      "Register here",
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

  Widget buildPasswordField(String label, String hint, IconData icon, TextEditingController controller) {
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
            prefixIcon: Icon(icon, color: Colors.grey[700]),
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

  Widget buildSocialButton(String text, String iconText, Color borderColor) {
    return OutlinedButton.icon(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        minimumSize: Size(double.infinity, 50),
        side: BorderSide(color: borderColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      icon: Text(
        iconText,
        style: TextStyle(
          fontSize: 20,
          color: Colors.black,
          fontFamily: 'Poppins',
        ),
      ),
      label: Text(
        text,
        style: TextStyle(
          fontFamily: 'Poppins',
          color: Colors.black,
        ),
      ),
    );
  }
}
