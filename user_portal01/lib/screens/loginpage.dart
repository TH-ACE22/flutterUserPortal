import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyLoginPage extends StatefulWidget {
  const MyLoginPage({super.key});

  @override
  State<MyLoginPage> createState() => _MyLoginPageState();
}

class _MyLoginPageState extends State<MyLoginPage> {
  bool isChecked = false;
  bool _obscureText = true;

  // Returns an outlined border with the given color.
  InputBorder getBorder(Color color) => OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(7)),
        borderSide: BorderSide(color: color, width: 2),
      );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Dismiss the keyboard when tapping outside the fields.
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          Scaffold(
            body: Stack(
              children: [
                // Use the same blue background as the sign-up page.
                Positioned.fill(
                  child: Container(color: const Color(0xFF5874C6)),
                ),
                SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.sizeOf(context).height,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Center(
                          child: Image.asset(
                            'assets/app_icon.png',
                            width: 120,
                            height: 120,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Login',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Enter your email and password to log in',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Email Field
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              prefixIcon:
                                  const Icon(Icons.email, color: Colors.black),
                              labelText: 'Email',
                              labelStyle: const TextStyle(color: Colors.black),
                              hintText: 'Email Address',
                              hintStyle: const TextStyle(color: Colors.black45),
                              enabledBorder: getBorder(Colors.black),
                              focusedBorder: getBorder(Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Password Field
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: TextFormField(
                            obscureText: _obscureText,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              prefixIcon:
                                  const Icon(Icons.lock, color: Colors.black),
                              labelText: 'Password',
                              labelStyle: const TextStyle(color: Colors.black),
                              hintText: 'Enter Password',
                              hintStyle: const TextStyle(color: Colors.black45),
                              enabledBorder: getBorder(Colors.black),
                              focusedBorder: getBorder(Colors.white),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.black,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // "Remember Me" and "Forgot Password" Row.
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    checkColor: Colors.black,
                                    activeColor: Colors.white,
                                    value: isChecked,
                                    onChanged: (value) {
                                      setState(() => isChecked = value!);
                                    },
                                  ),
                                  Text(
                                    'Remember Me',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: Text(
                                  "Forgot Password?",
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Login Button (using the original button size).
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/dashboard');
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(200, 55),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 160),
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7),
                              ),
                            ),
                            child: Text(
                              'Login',
                              style: GoogleFonts.sora(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Sign-up prompt.
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 90),
                          child: Row(
                            children: [
                              Text(
                                "Don't have an Account?",
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              const SizedBox(width: 7),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/signup');
                                },
                                child: Text(
                                  "SignUp",
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
