import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_notifier.dart'; // Make sure your ThemeNotifier is set up

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Editable username.
  String username = "JohnDoe";
  late TextEditingController _usernameController;

  // Non-editable user details.
  final String role = "Member";
  final String email = "johndoe@example.com";
  final String fullName = "John Doe";
  final String phoneNumber = "+1234567890";

  // Profile picture path. Initially from assets.
  String profilePic = 'assets/profile_pic.png';

  // For image picking.
  final ImagePicker _picker = ImagePicker();

  // Sample communities.
  final List<Map<String, String>> communities = [
    {"name": "Community A", "description": "Feed for Community A"},
    {"name": "Community B", "description": "Feed for Community B"},
    {"name": "Community C", "description": "Feed for Community C"},
  ];
  String selectedCommunity = "Community A";

  // Bottom navigation state. Profile is at index 4.
  int _bottomNavIndex = 4;

  // Dark mode flag.
  bool isDarkMode = false;

  // Secure storage instance.
  final _secureStorage = const FlutterSecureStorage();

  // For the "Remember Me" functionality.
  // ignore: unused_field
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: username);
    _loadRememberedEmail();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _onBottomNavTap(int index) {
    if (index == 0) {
      Navigator.pushNamed(context, '/dashboard');
    } else if (index == 1) {
      Navigator.pushNamed(context, '/channels');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/discussion');
    } else if (index == 3) {
      Navigator.pushNamed(context, '/notifications');
    } else if (index == 4) {
      setState(() {
        _bottomNavIndex = index;
      });
    }
  }

  // Build a widget for a user detail label/value.
  Widget _buildUserDetail(String label, String value) {
    return ListTile(
      title: Text(
        label,
        style: GoogleFonts.sora(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        value,
        style: GoogleFonts.sora(
          fontSize: 14,
          color: Colors.white,
        ),
      ),
    );
  }

  // Logout function to clear stored tokens and navigate to the login screen.
  Future<void> _logout() async {
    // Clear tokens from secure storage.
    await _secureStorage.delete(key: 'jwt_token');
    await _secureStorage.delete(key: 'refresh_token');

    // Optionally, clear the "Remember Me" flag.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberMe', false);

    // Navigate to the login screen and clear the navigation history.
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  // Build the settings section.
  Widget _buildSettingsSection() {
    return Card(
      color: Colors.black45,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Dark Mode toggle using Provider.
          ListTile(
            leading: const Icon(Icons.dark_mode, color: Colors.white),
            title: Text(
              "Dark Mode",
              style: GoogleFonts.sora(fontSize: 16, color: Colors.white),
            ),
            trailing: Consumer<ThemeNotifier>(
              builder: (context, themeNotifier, child) {
                bool isDark = themeNotifier.themeMode == ThemeMode.dark;
                return Switch(
                  value: isDark,
                  onChanged: (val) {
                    themeNotifier.toggleTheme(val);
                  },
                  activeColor: Colors.blue,
                );
              },
            ),
          ),
          const Divider(color: Colors.white54, indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.notifications, color: Colors.white),
            title: Text(
              "Notification Preferences",
              style: GoogleFonts.sora(fontSize: 16, color: Colors.white),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/notificationSettings');
            },
          ),
          const Divider(color: Colors.white54, indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.info, color: Colors.white),
            title: Text(
              "About",
              style: GoogleFonts.sora(fontSize: 16, color: Colors.white),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/about');
            },
          ),
          const Divider(color: Colors.white54, indent: 16, endIndent: 16),
          // Updated Logout ListTile to use the _logout() function.
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white),
            title: Text(
              "Logout",
              style: GoogleFonts.sora(fontSize: 16, color: Colors.white),
            ),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  // Build the community selection section.
  Widget _buildCommunitySection() {
    return Card(
      color: Colors.black45,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: const Icon(Icons.group, color: Colors.white),
        title: Text(
          "Community",
          style: GoogleFonts.sora(fontSize: 16, color: Colors.white),
        ),
        subtitle: Text(
          "Current: $selectedCommunity",
          style: GoogleFonts.sora(fontSize: 14, color: Colors.white70),
        ),
        onTap: () {
          Navigator.pushNamed(context, '/communities').then((value) {
            if (value is String && value.isNotEmpty) {
              setState(() {
                selectedCommunity = value;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Switched to $selectedCommunity feed."),
                  backgroundColor: Colors.blue,
                ),
              );
            }
          });
        },
      ),
    );
  }

  // Build the profile header with a big, centered profile pic.
  Widget _buildProfileHeader() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: profilePic.startsWith('assets/')
                ? AssetImage(profilePic) as ImageProvider
                : FileImage(File(profilePic)),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _editProfilePic,
              child: const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.blue,
                child: Icon(Icons.edit, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to edit the profile picture.
  Future<void> _editProfilePic() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black45,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.white),
                title: Text(
                  "Take Photo",
                  style: GoogleFonts.sora(color: Colors.white),
                ),
                onTap: () async {
                  final XFile? photo =
                      await _picker.pickImage(source: ImageSource.camera);
                  if (photo != null) {
                    setState(() {
                      profilePic = photo.path;
                    });
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white),
                title: Text(
                  "Choose from Gallery",
                  style: GoogleFonts.sora(color: Colors.white),
                ),
                onTap: () async {
                  final XFile? photo =
                      await _picker.pickImage(source: ImageSource.gallery);
                  if (photo != null) {
                    setState(() {
                      profilePic = photo.path;
                    });
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.white),
                title: Text(
                  "Cancel",
                  style: GoogleFonts.sora(color: Colors.white),
                ),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  // Loads remembered email if available.
  Future<void> _loadRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('rememberMe') ?? false) {
      setState(() {
        _rememberMe = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background image.
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/Module.png', fit: BoxFit.cover),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
              children: [
                // Header with back button and title.
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon:
                          Image.asset('assets/Back.png', width: 35, height: 35),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    Text(
                      "Profile",
                      style: GoogleFonts.sora(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(flex: 2),
                  ],
                ),
                const SizedBox(height: 16),
                // Profile header with big, centered profile pic.
                _buildProfileHeader(),
                const SizedBox(height: 16),
                // Editable username.
                Center(
                  child: TextField(
                    textAlign: TextAlign.center,
                    style: GoogleFonts.sora(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter username",
                      hintStyle: GoogleFonts.sora(color: Colors.white70),
                    ),
                    controller: _usernameController,
                    onChanged: (value) {
                      username = value;
                    },
                  ),
                ),
                const SizedBox(height: 24),
                // User details Card.
                Card(
                  color: Colors.black45,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      _buildUserDetail("Role", role),
                      _buildUserDetail("Email", email),
                      _buildUserDetail("Full Name", fullName),
                      _buildUserDetail("Phone Number", phoneNumber),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Community section.
                _buildCommunitySection(),
                const SizedBox(height: 24),
                // Settings section.
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Settings",
                    style: GoogleFonts.sora(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  color: Colors.black45,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: _buildSettingsSection(),
                ),
              ],
            ),
          ),
        ],
      ),
      // Bottom navigation bar.
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BottomNavigationBar(
          currentIndex: _bottomNavIndex,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: GoogleFonts.sora(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: GoogleFonts.sora(
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
          type: BottomNavigationBarType.fixed,
          onTap: _onBottomNavTap,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Channels',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Discussions',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Notifications',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
