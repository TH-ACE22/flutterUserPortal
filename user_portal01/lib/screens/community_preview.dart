import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:user_portal01/utility/http_with_refresh.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
// ignore: unused_import
import 'package:http/http.dart' as http;
import 'package:user_portal01/models/community_summary.dart';

class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final p = Path();
    p.lineTo(0, size.height - 60);
    p.quadraticBezierTo(
      size.width * .5,
      size.height,
      size.width,
      size.height - 60,
    );
    p.lineTo(size.width, 0);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class Channel {
  final String id;
  final String channelName;

  Channel({required this.id, required this.channelName});

  factory Channel.fromJson(Map<String, dynamic> json) => Channel(
        id: json['id'],
        channelName: json['channelName'],
      );
}

class CommunityPreviewPage extends StatefulWidget {
  const CommunityPreviewPage({super.key});

  @override
  State<CommunityPreviewPage> createState() => _CommunityPreviewPageState();
}

class _CommunityPreviewPageState extends State<CommunityPreviewPage> {
  // ignore: unused_field
  final _storage = const FlutterSecureStorage();
  static const String _baseUrl = 'http://10.0.2.2:8081';

  late CommunitySummary community;
  List<Channel> _channels = [];
  bool _isJoining = false;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      setState(() => _visible = true);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    community = ModalRoute.of(context)!.settings.arguments as CommunitySummary;
    fetchChannels();
  }

  Future<void> fetchChannels() async {
    final uri = Uri.parse('$_baseUrl/communities/${community.id}/channels');
    final response = await HttpWithRefresh.get(uri);

    if (!mounted) return;
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _channels = data.map((json) => Channel.fromJson(json)).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to load channels (${response.statusCode})')),
      );
    }
  }

  Future<void> joinCommunity() async {
    if (!mounted) return;
    setState(() => _isJoining = true);

    final uri = Uri.parse('$_baseUrl/communities/${community.id}/join');
    final response = await HttpWithRefresh.post(uri);

    if (!mounted) return;
    setState(() => _isJoining = false);

    if (response.statusCode == 200) {
      // ✅ Save community ID and name
      const storage = FlutterSecureStorage();
      await storage.write(key: 'selected_community_id', value: community.id);
      await storage.write(
          key: 'selected_community_name', value: community.name);

      // ✅ Navigate to dashboard
      Navigator.pushReplacementNamed(
        context,
        '/dashboard',
        arguments: {
          'communityId': community.id,
          'communityName': community.name,
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to join community (${response.statusCode})'),
        ),
      );
    }
  }

  void _confirmJoin() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Join Community'),
        content: Text(
          'Are you sure you want to join "${community.name}"?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              joinCommunity();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4870B6),
            ),
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF2FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5874C6),
        elevation: 0,
        title: Text('Preview Community',
            style:
                GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: AnimatedOpacity(
        opacity: _visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        child: Column(
          children: [
            // Header Wave
            ClipPath(
              clipper: BottomWaveClipper(),
              child: Container(
                height: 120,
                color: const Color(0xFF5874C6),
                alignment: Alignment.center,
                child: Text(
                  community.name,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Content
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  // Community Info Card
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Location',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(community.location,
                              style: GoogleFonts.poppins()),
                          const Divider(height: 20),
                          Text('Description',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(community.description,
                              style: GoogleFonts.poppins()),
                          const Divider(height: 20),
                          Text('Members',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text('${community.memberCount}',
                              style: GoogleFonts.poppins()),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Channels Section
                  Text('Channels in this community',
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  if (_channels.isEmpty)
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text('No channels found.',
                            style: GoogleFonts.poppins(
                                fontStyle: FontStyle.italic)),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _channels
                          .map((c) => Chip(
                                label: Text(c.channelName,
                                    style: GoogleFonts.poppins()),
                                backgroundColor: Colors.white,
                                elevation: 2,
                              ))
                          .toList(),
                    ),
                  const SizedBox(height: 24),
                  // Join Button
                  Center(
                    child: ElevatedButton(
                      onPressed: _isJoining ? null : _confirmJoin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5874C6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 48, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 4,
                      ),
                      child: _isJoining
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text('Join Community',
                              style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
