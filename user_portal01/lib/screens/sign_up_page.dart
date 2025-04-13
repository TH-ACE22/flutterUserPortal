import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'email_verification.dart'; // Adjust the path as needed.

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _obscureText = true;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  // Controllers.
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Error state variables for inline field error indication.
  String? _usernameErrorMessage;
  String? _emailErrorMessage;

  // Flag to track acceptance of terms and conditions.
  bool _termsAccepted = false;

  @override
  void dispose() {
    try {
      firstNameController.dispose();
      lastNameController.dispose();
      usernameController.dispose();
      phoneController.dispose();
      emailController.dispose();
      passwordController.dispose();
    } catch (e) {
      debugPrint("Dispose error: $e");
    }
    super.dispose();
  }

  /// Registers the user via a POST request.
  Future<void> registerUser() async {
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    final url = Uri.parse('http://10.0.2.2:8081/auth/register');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'fullName':
          '${firstNameController.text.trim()} ${lastNameController.text.trim()}',
      'username': usernameController.text.trim(),
      'phone': phoneController.text.trim(),
      'email': emailController.text.trim(),
      'password': passwordController.text.trim(),
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      debugPrint("Register Status code: ${response.statusCode}");
      debugPrint("Register Response body: ${response.body}");

      setState(() => _isLoading = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Clear any previous field errors on success.
        setState(() {
          _usernameErrorMessage = null;
          _emailErrorMessage = null;
        });
        await _showDialog(
          "Success",
          "Account created successfully!\nPlease check your email to verify your account.",
        );
        // After a successful registration, navigate to the EmailVerificationPage.
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  EmailVerificationPage(email: emailController.text.trim()),
            ),
          );
        }
      } else if (response.statusCode == 409) {
        // Parse the JSON error response.
        final errorResponse = jsonDecode(response.body);
        String conflictMessage = "";
        if (errorResponse['username'] != null) {
          setState(() {
            _usernameErrorMessage = errorResponse['username'];
          });
          conflictMessage += "Username: ${errorResponse['username']}\n";
        }
        if (errorResponse['email'] != null) {
          setState(() {
            _emailErrorMessage = errorResponse['email'];
          });
          conflictMessage += "Email: ${errorResponse['email']}\n";
        }
        // If no specific field errors are present, use a fallback message.
        if (conflictMessage.trim().isEmpty) {
          conflictMessage =
              "Username or email might already exist. Please try again.";
        }
        await _showDialog("Error", conflictMessage);
      } else {
        // Handle other status codes.
        String errorMessage = "";
        try {
          final errorResponse = jsonDecode(response.body);
          if (errorResponse['message'] != null) {
            errorMessage = errorResponse['message'];
          }
        } catch (_) {
          // Fallback if response cannot be decoded.
        }
        if (errorMessage.isEmpty) {
          switch (response.statusCode) {
            case 400:
              errorMessage =
                  "Bad Request – Invalid input provided. Please check your details and try again.";
              break;
            case 500:
              errorMessage =
                  "Internal Server Error – Something went wrong on our end. Please try again later.";
              break;
            default:
              errorMessage = "Error: ${response.body}";
          }
        }
        await _showDialog("Error", errorMessage);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Register Exception: $e");
      await _showDialog(
          "Network Error", "Could not connect to the server.\n\n$e");
    }
  }

  Future<void> checkUsernameAvailability(String username) async {
    if (username.isEmpty) return;
    final url = Uri.parse('http://10.0.2.2:8081/auth/check-username/$username');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final isAvailable = jsonDecode(response.body) as bool;
        setState(() {
          _usernameErrorMessage =
              isAvailable ? null : "Username already exists.";
        });
      }
    } catch (e) {
      debugPrint("Username check failed: $e");
    }
  }

  Future<void> checkEmailAvailability(String email) async {
    if (email.isEmpty) return;
    final url = Uri.parse('http://10.0.2.2:8081/auth/check-email/$email');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final isAvailable = jsonDecode(response.body) as bool;
        setState(() {
          _emailErrorMessage = isAvailable ? null : "Email already exists.";
        });
      }
    } catch (e) {
      debugPrint("Email check failed: $e");
    }
  }

  /// Displays a dialog using the same background as the sign‑up page.
  Future<void> _showDialog(String title, String message) async {
    bool isSuccess = title.toLowerCase() == "success";
    bool isError = title.toLowerCase() == "error";

    Icon dialogIcon;
    if (isSuccess) {
      dialogIcon =
          const Icon(Icons.check_circle, color: Colors.green, size: 30);
      // Optionally override the message for successful registration:
      message =
          "Account created successfully!\nPlease check your email to verify your account.";
    } else if (isError) {
      dialogIcon = const Icon(Icons.warning, color: Colors.red, size: 30);
    } else {
      dialogIcon = const Icon(Icons.info, color: Colors.white, size: 30);
    }

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF5874C6),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isError ? Colors.red : Colors.blue,
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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
      ),
    );
  }

  // For fields that must not be empty.
  String? _validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your $fieldName';
    }
    return null;
  }

  // For the email field, a friendlier message.
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please provide your email address';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address (e.g., example@mail.com)';
    }
    return null;
  }

  // For the phone field.
  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your phone number';
    }
    if (value.trim().length < 8 || value.trim().length > 15) {
      return 'Please enter a valid phone number (8-15 digits)';
    }
    return null;
  }

  // For the password field.
  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your password';
    }
    if (value.trim().length < 6) {
      return 'Your password must be at least 6 characters long';
    }
    return null;
  }

  // Returns an outlined border with the given color.
  InputBorder getBorder(Color color) => OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(7)),
        borderSide: BorderSide(color: color, width: 2),
      );

  @override
  Widget build(BuildContext context) {
    // Wrapping the whole content with a GestureDetector to dismiss the keyboard.
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          Scaffold(
            body: Stack(
              children: [
                // Custom blue background.
                Positioned.fill(
                  child: Container(
                    color: const Color(0xFF5874C6),
                  ),
                ),
                SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.sizeOf(context).height,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
                          Center(
                            child: Image.asset(
                              "assets/app_icon.png",
                              width: 120,
                              height: 120,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Let's Create Your Account",
                            style: GoogleFonts.inter(
                              fontSize: 17,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 5),
                          // First Name and Last Name Fields.
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: firstNameController,
                                    validator: (value) =>
                                        _validateNotEmpty(value, "First Name"),
                                    keyboardType: TextInputType.name,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(
                                        Icons.person,
                                        color: Colors.black,
                                      ),
                                      labelText: 'First Name',
                                      labelStyle:
                                          const TextStyle(color: Colors.black),
                                      hintText: 'First Name',
                                      hintStyle: const TextStyle(
                                          color: Colors.black45),
                                      enabledBorder: getBorder(Colors.black),
                                      focusedBorder: getBorder(Colors.white),
                                      errorBorder: getBorder(Colors.red),
                                      focusedErrorBorder:
                                          getBorder(Colors.redAccent),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextFormField(
                                    controller: lastNameController,
                                    validator: (value) =>
                                        _validateNotEmpty(value, "Last Name"),
                                    keyboardType: TextInputType.name,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(
                                        Icons.person,
                                        color: Colors.black,
                                      ),
                                      labelText: 'Last Name',
                                      labelStyle:
                                          const TextStyle(color: Colors.black),
                                      hintText: 'Last Name',
                                      hintStyle: const TextStyle(
                                          color: Colors.black45),
                                      enabledBorder: getBorder(Colors.black),
                                      focusedBorder: getBorder(Colors.white),
                                      errorBorder: getBorder(Colors.red),
                                      focusedErrorBorder:
                                          getBorder(Colors.redAccent),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5),
                          // Username Field.
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextFormField(
                              controller: usernameController,
                              // Basic validation: required field
                              validator: (value) =>
                                  _validateNotEmpty(value, "username"),
                              onChanged: (value) {
                                // Whenever the user types, clear the old error message
                                // and check the new availability.
                                if (_usernameErrorMessage != null) {
                                  setState(() => _usernameErrorMessage = null);
                                }
                                checkUsernameAvailability(value.trim());
                              },
                              keyboardType: TextInputType.text,
                              autocorrect: true,
                              enableSuggestions: true,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.person,
                                    color: Colors.black),
                                labelText: 'Username',
                                labelStyle:
                                    const TextStyle(color: Colors.black),
                                hintText: 'Username',
                                hintStyle:
                                    const TextStyle(color: Colors.black45),
                                errorStyle: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                enabledBorder: getBorder(Colors.black),
                                focusedBorder: getBorder(Colors.white),
                                errorBorder: getBorder(Colors.red),
                                focusedErrorBorder: getBorder(Colors.redAccent),
                                // Suffix icon: green check if available, red hazard if not
                                suffixIcon:
                                    usernameController.text.trim().isNotEmpty
                                        ? (_usernameErrorMessage == null
                                            ? const Icon(Icons.check_circle,
                                                color: Colors.green)
                                            : const Icon(Icons.warning,
                                                color: Colors.red))
                                        : null,
                                // Helper text: green "available", or red "already exists"
                                helperText:
                                    usernameController.text.trim().isNotEmpty
                                        ? (_usernameErrorMessage == null
                                            ? 'This username is available'
                                            : 'Username already exists')
                                        : null,
                                helperStyle: TextStyle(
                                  color: _usernameErrorMessage == null
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          // Phone Field.
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextFormField(
                              controller: phoneController,
                              validator: _validatePhone,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.phone,
                                    color: Colors.black),
                                labelText: 'Phone',
                                labelStyle:
                                    const TextStyle(color: Colors.black),
                                hintText: 'Phone Number',
                                hintStyle:
                                    const TextStyle(color: Colors.black45),
                                enabledBorder: getBorder(Colors.black),
                                focusedBorder: getBorder(Colors.white),
                                errorBorder: getBorder(Colors.red),
                                focusedErrorBorder: getBorder(Colors.redAccent),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          // Email Field.
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextFormField(
                              controller: emailController,
                              // Basic validation: required + valid format
                              validator: _validateEmail,
                              onChanged: (value) {
                                // Clear old message and check availability
                                if (_emailErrorMessage != null) {
                                  setState(() => _emailErrorMessage = null);
                                }
                                checkEmailAvailability(value.trim());
                              },
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: true,
                              enableSuggestions: true,
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
                                errorStyle: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                enabledBorder: getBorder(Colors.black),
                                focusedBorder: getBorder(Colors.white),
                                errorBorder: getBorder(Colors.red),
                                focusedErrorBorder: getBorder(Colors.redAccent),
                                suffixIcon:
                                    emailController.text.trim().isNotEmpty
                                        ? (_emailErrorMessage == null
                                            ? const Icon(Icons.check_circle,
                                                color: Colors.green)
                                            : const Icon(Icons.warning,
                                                color: Colors.red))
                                        : null,
                                // Helper text: green "available", or red "already exists"
                                helperText:
                                    emailController.text.trim().isNotEmpty
                                        ? (_emailErrorMessage == null
                                            ? 'Email is available'
                                            : 'Email already exists')
                                        : null,
                                helperStyle: TextStyle(
                                  color: _emailErrorMessage == null
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Password Field.
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextFormField(
                              controller: passwordController,
                              obscureText: _obscureText,
                              validator: _validatePassword,
                              autocorrect: false,
                              enableSuggestions: false,
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
                                    color: Colors.black,
                                  ),
                                  onPressed: () {
                                    setState(
                                        () => _obscureText = !_obscureText);
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Terms and Conditions Checkbox.
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: _termsAccepted,
                                  onChanged: (value) {
                                    setState(() {
                                      _termsAccepted = value ?? false;
                                    });
                                  },
                                  checkColor: Colors.white,
                                  activeColor: Colors.black,
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => Dialog(
                                          backgroundColor: Colors.transparent,
                                          child: Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.75,
                                            decoration: BoxDecoration(
                                              image: const DecorationImage(
                                                image: AssetImage(
                                                    'assets/Module.png'),
                                                fit: BoxFit.cover,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: Colors.blue, width: 2),
                                            ),
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              children: [
                                                Text(
                                                  "Terms and Conditions",
                                                  style: GoogleFonts.inter(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Expanded(
                                                  child: SingleChildScrollView(
                                                    child: Text(
                                                      '''
Welcome to Lefatshe-Larona. By using our platform, you agree to the following Terms and Conditions:

1. PURPOSE OF THE PLATFORM  
Lefatshe-Larona is a community-centered platform that facilitates communication between citizens and government services in Botswana.

2. USER CONDUCT  
- You agree not to post harmful, misleading, or offensive content.  
- You must use the platform respectfully and lawfully at all times.

3. ACCOUNT SECURITY  
- You are responsible for keeping your account credentials secure.  
- Misuse of accounts may result in suspension or termination.

4. CONTENT OWNERSHIP  
- You retain ownership of any content you create.  
- By posting, you grant Lefatshe-Larona permission to display and moderate your content.

5. PRIVACY AND DATA PROTECTION  
- We comply with the Botswana Data Protection Act.  
- Your data is securely stored and not shared without your permission.

6. SUSPENSION AND TERMINATION  
- Accounts may be suspended for violating these terms.  
- We reserve the right to remove any content deemed inappropriate.

7. CHANGES TO TERMS  
- These terms may be updated from time to time.  
- Continued use of the platform implies your acceptance of any changes.

8. CONTACT US  
If you have any questions, please contact: support@lefatshelarona.org

By registering, you confirm that you have read and agree to these terms.
                  ''',
                                                      style: GoogleFonts.inter(
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 20),
                                                ElevatedButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.white,
                                                    foregroundColor:
                                                        Colors.black,
                                                    textStyle:
                                                        GoogleFonts.inter(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  child: const Text("OK"),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "I agree to the Terms and Conditions",
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Create Account Button.
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: ElevatedButton(
                              onPressed: () async {
                                // Clear old messages
                                setState(() {
                                  _usernameErrorMessage = null;
                                  _emailErrorMessage = null;
                                });
                                if (!_termsAccepted) {
                                  await _showDialog(
                                    "Error",
                                    "Please accept the Terms and Conditions before registering.",
                                  );
                                  return;
                                }
                                // Run validation
                                if (_formKey.currentState!.validate()) {
                                  FocusScope.of(context).unfocus();
                                  await registerUser();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(200, 55),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 125),
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(7)),
                                ),
                              ),
                              child: Text(
                                'Create Account',
                                style: GoogleFonts.sora(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          // Already have an Account.
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 90),
                            child: Row(
                              children: [
                                Text(
                                  "Already have an Account?",
                                  style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.normal),
                                ),
                                const SizedBox(width: 7),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context, '/login');
                                  },
                                  child: Text(
                                    "Login",
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Full-screen loading overlay.
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
