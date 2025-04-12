import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _obscureText = true;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? _usernameErrorMessage;
  String? _emailErrorMessage;
  bool _termsAccepted = false;

  @override
  void dispose() {
    try {
      fullNameController.dispose();
      usernameController.dispose();
      phoneController.dispose();
      emailController.dispose();
      passwordController.dispose();
    } catch (e) {
      debugPrint("Dispose error: $e");
    }
    super.dispose();
  }

  Future<void> registerUser() async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('http://10.0.2.2:8081/auth/register');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'fullName': fullNameController.text.trim(),
      'username': usernameController.text.trim(),
      'phone': phoneController.text.trim(),
      'email': emailController.text.trim(),
      'password': passwordController.text.trim(),
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      debugPrint("Register Status: ${response.statusCode}");
      debugPrint("Register Response: ${response.body}");

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        _usernameErrorMessage = null;
        _emailErrorMessage = null;
        await _showDialog("Success",
            "Account created successfully!\nPlease check your email to verify your account.");
        if (mounted) Navigator.pushReplacementNamed(context, '/login');
      } else if (response.statusCode == 409) {
        final error = jsonDecode(response.body);
        String conflict = '';
        setState(() {
          _usernameErrorMessage = error['username'];
          _emailErrorMessage = error['email'];
        });
        if (_usernameErrorMessage != null) {
          conflict += "Username: $_usernameErrorMessage\n";
        }
        if (_emailErrorMessage != null) {
          conflict += "Email: $_emailErrorMessage\n";
        }
        await _showDialog(
            "Error",
            conflict.trim().isEmpty
                ? "Username or email might already exist."
                : conflict);
      } else {
        String msg = '';
        try {
          msg = jsonDecode(response.body)['message'] ?? '';
        } catch (_) {}
        if (msg.isEmpty) {
          msg = response.statusCode == 400
              ? "Bad Request – Check your inputs."
              : response.statusCode == 500
                  ? "Server error – Try again later."
                  : "Unexpected Error: ${response.statusCode}";
        }
        await _showDialog("Error", msg);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      await _showDialog(
          "Network Error", "Could not connect to the server.\n\nDetails: $e");
    }
  }

  Future<void> _showDialog(String title, String message) async {
    Icon icon;
    if (title.toLowerCase() == "success") {
      icon = const Icon(Icons.check_circle, color: Colors.green, size: 30);
    } else if (title.toLowerCase() == "error") {
      icon = const Icon(Icons.warning, color: Colors.red, size: 30);
    } else {
      icon = const Icon(Icons.info, color: Colors.white, size: 30);
    }

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/Module.png'),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: title.toLowerCase() == "error"
                  ? Colors.red
                  : Colors.blueAccent,
              width: 2,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  icon,
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(message,
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text("OK"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputBorder getBorder(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide(color: color, width: 2),
      );

  String? _validateNotEmpty(String? value, String fieldName) =>
      value == null || value.trim().isEmpty ? '$fieldName is required' : null;

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$');
    return emailRegex.hasMatch(value) ? null : 'Enter a valid email';
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone is required';
    if (value.length < 8 || value.length > 15) return 'Invalid phone number';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Container(color: const Color(0xFF5874C6))),
          SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.sizeOf(context).height,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Image.asset("assets/app_icon.png", width: 120),
                      Text("Let's Create Your Account",
                          style: GoogleFonts.inter(
                              fontSize: 17, color: Colors.white)),
                      const SizedBox(height: 10),

                      // Fields
                      _buildField(
                          icon: Icons.person_2,
                          controller: fullNameController,
                          label: "Full Names",
                          hint: "Enter full name",
                          validator: (v) => _validateNotEmpty(v, "Full Names")),
                      _buildField(
                          icon: Icons.person,
                          controller: usernameController,
                          label: "Username",
                          hint: "Enter username",
                          validator: (v) {
                            final val = _validateNotEmpty(v, "Username");
                            return val ?? _usernameErrorMessage;
                          },
                          onChanged: (_) => setState(() {
                                _usernameErrorMessage = null;
                              })),
                      _buildField(
                          icon: Icons.phone,
                          controller: phoneController,
                          label: "Phone",
                          hint: "Phone Number",
                          validator: _validatePhone,
                          inputType: TextInputType.phone),
                      _buildField(
                          icon: Icons.email,
                          controller: emailController,
                          label: "Email",
                          hint: "Email Address",
                          validator: (v) {
                            final val = _validateEmail(v);
                            return val ?? _emailErrorMessage;
                          },
                          onChanged: (_) => setState(() {
                                _emailErrorMessage = null;
                              })),
                      _buildField(
                          icon: Icons.lock,
                          controller: passwordController,
                          label: "Password",
                          hint: "Enter password",
                          validator: _validatePassword,
                          isPassword: true),

                      // Terms
                      CheckboxListTile(
                        value: _termsAccepted,
                        onChanged: (val) =>
                            setState(() => _termsAccepted = val!),
                        checkColor: Colors.white,
                        activeColor: Colors.black,
                        title: GestureDetector(
                          onTap: () {
                            _showDialog("Terms and Conditions",
                                "Your terms and conditions go here...");
                          },
                          child: Text(
                            "I agree to the Terms and Conditions",
                            style: GoogleFonts.inter(color: Colors.white),
                          ),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),

                      const SizedBox(height: 5),

                      // Button
                      ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                setState(() {
                                  _usernameErrorMessage = null;
                                  _emailErrorMessage = null;
                                });

                                if (!_termsAccepted) {
                                  await _showDialog("Error",
                                      "Please accept the Terms and Conditions.");
                                  return;
                                }

                                if (_formKey.currentState!.validate()) {
                                  await registerUser();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(200, 55),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : Text(
                                'Create Account',
                                style: GoogleFonts.sora(fontSize: 15),
                              ),
                      ),

                      const SizedBox(height: 30),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Already have an Account?",
                              style: GoogleFonts.inter(color: Colors.white)),
                          const SizedBox(width: 5),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            child: Text("Login",
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required IconData icon,
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    TextInputType inputType = TextInputType.text,
    bool isPassword = false,
    void Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: TextFormField(
        controller: controller,
        validator: validator,
        onChanged: onChanged,
        obscureText: isPassword ? _obscureText : false,
        keyboardType: inputType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black45),
          enabledBorder: getBorder(Colors.black),
          focusedBorder: getBorder(Colors.white),
          errorBorder: getBorder(Colors.red),
          focusedErrorBorder: getBorder(Colors.redAccent),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.black,
                  ),
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                )
              : null,
        ),
      ),
    );
  }
}
