import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class EmailVerificationPage extends StatefulWidget {
  final String email;

  const EmailVerificationPage({Key? key, required this.email})
      : super(key: key);

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  static const int _pinLength = 6;

  final List<TextEditingController> _pinControllers =
      List.generate(_pinLength, (_) => TextEditingController());
  bool _isVerifying = false;

  @override
  void dispose() {
    for (final controller in _pinControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Verifies the entered 6-digit code via an HTTP POST request.
  Future<void> _verifyCode() async {
    FocusScope.of(context).unfocus();
    setState(() => _isVerifying = true);

    final pin = _pinControllers.map((controller) => controller.text).join();

    if (pin.length != _pinLength) {
      await _showDialog(
          "Error", "Please enter a valid 6-digit verification code.");
      setState(() => _isVerifying = false);
      return;
    }

    final url = Uri.parse("http://10.0.2.2:8081/auth/verify-code");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': widget.email,
          'code': pin,
        }),
      );

      setState(() => _isVerifying = false);

      if (response.statusCode == 200) {
        await _showDialog(
            "Success", "Email verified successfully. You may now log in.");
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        await _showDialog(
            "Error", "Invalid or expired code. Please try again.");
      }
    } catch (e) {
      setState(() => _isVerifying = false);
      await _showDialog(
          "Network Error", "Could not connect to the server.\n$e");
    }
  }

  /// Requests a new verification code via an HTTP POST request.
  Future<void> _resendCode() async {
    final url = Uri.parse("http://10.0.2.2:8081/auth/resend-code");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': widget.email}),
      );

      if (response.statusCode == 200) {
        await _showDialog(
            "Success", "A new verification code has been sent to your email.");
      } else {
        await _showDialog("Error", "Failed to resend verification code.");
      }
    } catch (e) {
      await _showDialog(
          "Network Error", "Could not connect to the server.\n$e");
    }
  }

  /// Displays a dialog with a custom design based on the [title] and [message].
  Future<void> _showDialog(String title, String message) async {
    final lowerTitle = title.toLowerCase();
    final bool isSuccess = lowerTitle == "success";
    final bool isError = lowerTitle == "error";

    final Icon dialogIcon = isSuccess
        ? const Icon(Icons.check_circle, color: Colors.green, size: 30)
        : isError
            ? const Icon(Icons.warning, color: Colors.red, size: 30)
            : const Icon(Icons.info, color: Colors.white, size: 30);

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
              color: isError ? Colors.red : Colors.blue,
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
                  dialogIcon,
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
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

  /// Builds a single PIN input field for the verification code.
  Widget _buildPinField(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 45,
      child: TextField(
        controller: _pinControllers[index],
        onChanged: (value) {
          if (value.length == 1 && index < _pinLength - 1) {
            FocusScope.of(context).nextFocus();
          } else if (value.isEmpty && index > 0) {
            FocusScope.of(context).previousFocus();
          }
        },
        maxLength: 1,
        style: const TextStyle(color: Colors.white, fontSize: 24),
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          counterText: '',
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFF5874C6),
          body: SafeArea(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    Image.asset("assets/app_icon.png", width: 120, height: 120),
                    const SizedBox(height: 20),
                    Text(
                      "Verify Your Email",
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "Enter the 6-digit code sent to your email (${widget.email}).",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_pinLength, _buildPinField),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _isVerifying ? null : _verifyCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(300, 60),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isVerifying
                          ? const CircularProgressIndicator(color: Colors.black)
                          : Text(
                              'Verify',
                              style: GoogleFonts.sora(
                                  fontSize: 17, fontWeight: FontWeight.w600),
                            ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: 300,
                      height: 50,
                      child: TextButton(
                        onPressed: _resendCode,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          "Resend Code",
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_isVerifying)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
      ],
    );
  }
}
