import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:user_portal01/utility/token_manager.dart';

class MyLoginPage extends StatefulWidget {
  const MyLoginPage({super.key});

  @override
  State<MyLoginPage> createState() => _MyLoginPageState();
}

class _MyLoginPageState extends State<MyLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _secureStorage = const FlutterSecureStorage();
  bool _isLoading = false;
  bool _obscureText = true;
  bool _rememberMe = false;

  InputBorder getBorder(Color color) => OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(7)),
        borderSide: BorderSide(color: color, width: 2),
      );

  @override
  void initState() {
    super.initState();
    _attemptAutoLogin();
  }

  Future<void> _attemptAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool('rememberMe') ?? false;
    final token = await _secureStorage.read(key: 'jwt_token');

    if (rememberMe && token != null && token.isNotEmpty) {
      final url = Uri.parse('http://10.0.2.2:8081/auth/validate-token');
      try {
        final response = await http.get(url, headers: {
          'Authorization': 'Bearer $token'
        }).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/community');
          }
          return;
        } else if (response.statusCode == 401) {
          final refreshed = await TokenManager.refreshAccessToken();
          if (refreshed) {
            Navigator.pushReplacementNamed(context, '/community');
            return;
          }
        }
      } on TimeoutException {
        _showDialog('Error', 'Session validation timed out.');
      } catch (e) {
        _showDialog('Error', 'Unable to validate session.');
      }

      await _secureStorage.delete(key: 'jwt_token');
      await _secureStorage.delete(key: 'refresh_token');
    }

    final savedEmail = prefs.getString('email');
    if (prefs.getBool('rememberMe') == true && savedEmail != null) {
      setState(() {
        _rememberMe = true;
        _emailController.text = savedEmail;
      });
    }
  }

  Future<void> _loginUser() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('http://10.0.2.2:8081/auth/login');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': _emailController.text.trim(),
              'password': _passwordController.text.trim(),
            }),
          )
          .timeout(const Duration(seconds: 10));

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        await _secureStorage.write(
            key: 'jwt_token', value: jsonResponse['token']);
        await _secureStorage.write(
            key: 'refresh_token', value: jsonResponse['refreshToken']);

        if (_rememberMe) {
          final prefs = await SharedPreferences.getInstance();
          prefs.setBool('rememberMe', true);
          prefs.setString('email', _emailController.text.trim());
        }

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/community');
        }
      } else {
        _showDialog('Error', 'Invalid credentials. Please try again.');
      }
    } on TimeoutException {
      setState(() => _isLoading = false);
      _showDialog('Error', 'Login request timed out. Check your connection.');
    } catch (e) {
      setState(() => _isLoading = false);
      _showDialog('Error', 'An unexpected error occurred.');
    }
  }

  Future<void> _showDialog(String title, String message) async {
    await showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/Module.png'),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: title == 'Error' ? Colors.red : Colors.blue,
              width: 2,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    title == 'Error' ? Icons.warning : Icons.check_circle,
                    color: title == 'Error' ? Colors.red : Colors.green,
                    size: 30,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(message, style: const TextStyle(color: Colors.white)),
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          Scaffold(
            body: Stack(
              children: [
                Positioned.fill(
                  child: Container(color: const Color(0xFF5874C6)),
                ),
                SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          Image.asset('assets/app_icon.png',
                              width: 120, height: 120),
                          const SizedBox(height: 14),
                          Text('Login',
                              style: GoogleFonts.inter(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          const SizedBox(height: 5),
                          Text('Enter your email and password to log in',
                              style: GoogleFonts.inter(
                                  fontSize: 16, color: Colors.white)),
                          const SizedBox(height: 30),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (val) => val == null || val.isEmpty
                                  ? 'Email is required'
                                  : null,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.email,
                                    color: Colors.black),
                                labelText: 'Email',
                                labelStyle:
                                    const TextStyle(color: Colors.black),
                                hintText: 'Email Address',
                                hintStyle:
                                    const TextStyle(color: Colors.black45),
                                enabledBorder: getBorder(Colors.black),
                                focusedBorder: getBorder(Colors.white),
                                errorBorder: getBorder(Colors.red),
                                focusedErrorBorder: getBorder(Colors.redAccent),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: _obscureText,
                              validator: (val) => val == null || val.isEmpty
                                  ? 'Password is required'
                                  : null,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                prefixIcon:
                                    const Icon(Icons.lock, color: Colors.black),
                                labelText: 'Password',
                                labelStyle:
                                    const TextStyle(color: Colors.black),
                                hintText: 'Enter Password',
                                hintStyle:
                                    const TextStyle(color: Colors.black45),
                                enabledBorder: getBorder(Colors.black),
                                focusedBorder: getBorder(Colors.white),
                                errorBorder: getBorder(Colors.red),
                                focusedErrorBorder: getBorder(Colors.redAccent),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                      _obscureText
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.black),
                                  onPressed: () => setState(
                                      () => _obscureText = !_obscureText),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _rememberMe,
                                      onChanged: (v) => setState(
                                          () => _rememberMe = v ?? false),
                                      checkColor: Colors.black,
                                      activeColor: Colors.white,
                                    ),
                                    Text('Remember Me',
                                        style: GoogleFonts.inter(
                                            color: Colors.white)),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {},
                                  child: Text("Forgot Password?",
                                      style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: ElevatedButton(
                              onPressed: _loginUser,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(200, 55),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 160),
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(7)),
                              ),
                              child: Text('Login',
                                  style: GoogleFonts.sora(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 90),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Don't have an Account?",
                                    style:
                                        GoogleFonts.inter(color: Colors.white)),
                                const SizedBox(width: 7),
                                GestureDetector(
                                  onTap: () =>
                                      Navigator.pushNamed(context, '/signup'),
                                  child: Text("SignUp",
                                      style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                  child: CircularProgressIndicator(color: Colors.white)),
            ),
        ],
      ),
    );
  }
}
