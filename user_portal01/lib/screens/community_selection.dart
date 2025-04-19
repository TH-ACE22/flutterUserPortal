import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:user_portal01/models/community_summary.dart';

class TopWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 60);
    path.quadraticBezierTo(size.width * 0.5, 0, size.width, 60);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class CommunitySelectionPage extends StatefulWidget {
  const CommunitySelectionPage({super.key});

  @override
  State<CommunitySelectionPage> createState() => _CommunitySelectionPageState();
}

class _CommunitySelectionPageState extends State<CommunitySelectionPage> {
  static const _baseUrl = 'http://10.0.2.2:8081';
  final _storage = const FlutterSecureStorage();
  late Future<List<CommunitySummary>> _futureCommunities;

  @override
  void initState() {
    super.initState();
    _futureCommunities = fetchCommunities();
  }

  Future<List<CommunitySummary>> fetchCommunities() async {
    final token = await _storage.read(key: 'jwt_token');
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final uri = Uri.parse('$_baseUrl/communities/summaries');
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      final listJson = jsonDecode(response.body) as List<dynamic>;
      return listJson
          .map(
              (json) => CommunitySummary.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load communities: ${response.statusCode}');
    }
  }

  void _viewCommunity(CommunitySummary c) {
    Navigator.pushNamed(
      context,
      '/community-preview',
      arguments: c,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF2FA),
      body: Column(
        children: [
          // Wave Header
          ClipPath(
            clipper: TopWaveClipper(),
            child: Container(
              height: 120,
              color: const Color(0xFF5874C6),
              alignment: Alignment.center,
              child: Text(
                'Select Community',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Community List
          Expanded(
            child: FutureBuilder<List<CommunitySummary>>(
              future: _futureCommunities,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF5874C6),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Error loading communities:\n${snapshot.error}',
                        style: GoogleFonts.poppins(
                          color: Colors.black54,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                final communities = snapshot.data!;
                if (communities.isEmpty) {
                  return Center(
                    child: Text(
                      'No communities available to join.',
                      style: GoogleFonts.poppins(
                        color: Colors.black45,
                        fontSize: 16,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  itemCount: communities.length,
                  itemBuilder: (context, index) {
                    final c = communities[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _viewCommunity(c),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF333333),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                c.description,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: const Color(0xFF666666),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.people,
                                      size: 16, color: Color(0xFF5874C6)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${c.memberCount} members',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: const Color(0xFF5874C6),
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Color(0xFF5874C6),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
