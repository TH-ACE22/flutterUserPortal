import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:user_portal01/services/realtime_service.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final _storage = const FlutterSecureStorage();
  static const String _baseUrl = 'http://10.0.2.2:8081';

  // Realtime service instance
  late RealtimeService _realtimeService;

  // Dynamic channels
  List<Map<String, dynamic>> _channels = [];
  bool _loadingChannels = true;

  final ScrollController _scrollController = ScrollController();
  int _selectedIndex = 0;
  int _bottomNavIndex = 0;

  // Discussions state
  List<Map<String, dynamic>> _discussions = [];
  bool _loadingDiscussions = true;
  bool _filterByRecent = true;

  @override
  void initState() {
    super.initState();

    // 1) Start real-time listener first
    _realtimeService = RealtimeService(onPostReceived: _onRealtimePostReceived);
    _realtimeService.connect(
      baseUrl: 'http://10.0.2.2:8081/ws', // use HTTP for SockJS
      channelId: 'all',
    );

    // 2) Load historical data
    _loadChannels();
    _loadDiscussions();
  }

  @override
  void dispose() {
    _realtimeService.disconnect();
    super.dispose();
  }

  void _onRealtimePostReceived(Map<String, dynamic> post) {
    final newPost = {
      'profileImage': post['profileImage'] ?? 'assets/profile_pic.png',
      'userName': post['userName'] ?? '',
      'status': post['status'] ?? '',
      'timePosted': _formatTime(post['timestamp'] ?? ''),
      'subtitle': post['content'] ?? '',
      'likeCount': post['likeCount'] ?? 0,
      'commentCount': post['commentCount'] ?? 0,
    };

    setState(() {
      _discussions.insert(0, newPost);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("New post from ${newPost['userName']}"),
          backgroundColor: Colors.green.shade600,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'VIEW',
            textColor: Colors.white,
            onPressed: () {
              // optional: scroll to top or highlight
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
              );
            },
          ),
        ),
      );
    }
  }

  Future<void> _loadChannels() async {
    setState(() => _loadingChannels = true);
    try {
      final token = await _storage.read(key: 'jwt_token');
      final uri = Uri.parse('$_baseUrl/channels');
      final response = await http
          .get(
            uri,
            headers: token != null ? {'Authorization': 'Bearer $token'} : null,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        setState(() {
          _channels = data.map((item) {
            return {
              'name': item['name'] ?? '',
              'icon': _iconFromString(item['icon'] ?? 'category'),
              'color': _colorFromString(item['color'] ?? 'blue'),
              'route': item['route'] ?? '',
            };
          }).toList();
          _loadingChannels = false;
        });
      } else {
        setState(() => _loadingChannels = false);
      }
    } catch (_) {
      setState(() => _loadingChannels = false);
    }
  }

  Future<void> _loadDiscussions() async {
    setState(() => _loadingDiscussions = true);
    try {
      final token = await _storage.read(key: 'jwt_token');
      final communityId = await _storage.read(key: 'selected_community_id');
      if (communityId == null) {
        // ignore: avoid_print
        print('⚠️ No community ID saved!');
        setState(() => _loadingDiscussions = false);
        return;
      }

      final channelsUri =
          Uri.parse('$_baseUrl/communities/$communityId/channels');
      final channelsRes = await http
          .get(
            channelsUri,
            headers: token != null ? {'Authorization': 'Bearer $token'} : null,
          )
          .timeout(const Duration(seconds: 10));

      if (channelsRes.statusCode != 200) {
        setState(() => _loadingDiscussions = false);
        return;
      }

      final List channels = json.decode(channelsRes.body);
      List<Map<String, dynamic>> aggregatedPosts = [];

      for (var channel in channels) {
        final channelId = channel['id'];
        final postsUri = Uri.parse('$_baseUrl/channels/$channelId/posts');
        final postsRes = await http
            .get(
              postsUri,
              headers:
                  token != null ? {'Authorization': 'Bearer $token'} : null,
            )
            .timeout(const Duration(seconds: 10));

        if (postsRes.statusCode == 200) {
          final List posts = json.decode(postsRes.body);
          aggregatedPosts.addAll(posts.map((item) => {
                'profileImage':
                    item['profileImage'] ?? 'assets/profile_pic.png',
                'userName': item['userName'] ?? '',
                'status': item['status'] ?? '',
                'timePosted': _formatTime(item['timestamp'] ?? ''),
                'timestamp': item['timestamp'],
                'subtitle': item['content'] ?? '',
                'likeCount': item['likeCount'] ?? 0,
                'commentCount': item['commentCount'] ?? 0,
              }));
        }
      }

      // Sort in frontend
      if (_filterByRecent) {
        aggregatedPosts.sort((a, b) => DateTime.parse(b['timestamp'])
            .compareTo(DateTime.parse(a['timestamp'])));
      } else {
        aggregatedPosts.sort((a, b) => (b['likeCount'] + b['commentCount'])
            .compareTo(a['likeCount'] + a['commentCount']));
      }

      setState(() {
        _discussions = aggregatedPosts;
        _loadingDiscussions = false;
      });
    } catch (e) {
      print("Error loading discussions: $e");
      setState(() => _loadingDiscussions = false);
    }
  }

  String _formatTime(String timestamp) {
    try {
      final time = DateTime.parse(timestamp);
      final diff = DateTime.now().difference(time);
      if (diff.inHours >= 1) return '${diff.inHours}h ago';
      if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
      return '${diff.inSeconds}s ago';
    } catch (_) {
      return '';
    }
  }

  IconData _iconFromString(String iconName) {
    switch (iconName) {
      case 'water_drop':
        return Icons.water_drop;
      case 'electrical_services':
        return Icons.electrical_services;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'local_police':
        return Icons.local_police;
      default:
        return Icons.category;
    }
  }

  Color _colorFromString(String colorName) {
    switch (colorName) {
      case 'blue':
        return Colors.blue;
      case 'yellow':
        return Colors.yellow;
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _scrollToChannel(int index) {
    setState(() => _selectedIndex = index);
    _scrollController.animateTo(
      index * 138.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _onBottomNavTap(int index) {
    setState(() => _bottomNavIndex = index);
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/dashboard');
        break;
      case 1:
        Navigator.pushNamed(context, '/channels');
        break;
      case 2:
        Navigator.pushNamed(context, '/discussion');
        break;
      case 3:
        Navigator.pushNamed(context, '/notifications');
        break;
      case 4:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5874C6),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(minHeight: MediaQuery.of(context).size.height),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),
                  Center(
                    child: Text(
                      'Explore',
                      style: GoogleFonts.sora(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(
                      'Channels',
                      style: GoogleFonts.sora(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_loadingChannels)
                    const Center(child: CircularProgressIndicator())
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _channels.map((channel) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: GestureDetector(
                                onTap: () => Navigator.pushNamed(
                                    context, channel['route']),
                                child: Container(
                                  width: 126,
                                  height: 101,
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: (channel['color'] as Color)
                                        .withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Stack(
                                    children: [
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          channel['name'],
                                          style: GoogleFonts.sora(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Icon(
                                          channel['icon'] as IconData,
                                          size: 30,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_channels.length, (index) {
                        return GestureDetector(
                          onTap: () => _scrollToChannel(index),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _selectedIndex == index
                                  ? Colors.black
                                  : Colors.white.withOpacity(0.8),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(
                      'Discussions',
                      style: GoogleFonts.sora(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Material(
                      elevation: 7,
                      borderRadius: BorderRadius.circular(2),
                      child: Container(
                        width: 390,
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          image: const DecorationImage(
                            image: AssetImage('assets/Module.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _filterByRecent = true;
                                    _loadDiscussions();
                                  });
                                },
                                child: Text(
                                  'Recent',
                                  style: GoogleFonts.sora(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: _filterByRecent
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _filterByRecent = false;
                                    _loadDiscussions();
                                  });
                                },
                                child: Text(
                                  'Trending',
                                  style: GoogleFonts.sora(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: !_filterByRecent
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_loadingDiscussions)
                    const Center(child: CircularProgressIndicator())
                  else if (_channels.isEmpty || _discussions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(
                        child: Text(
                          'No posts available ',
                          style: GoogleFonts.sora(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: _discussions
                          .map((discussion) => Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: DiscussionCard(discussion: discussion),
                              ))
                          .toList(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.circular(0.0),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: _bottomNavIndex,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle:
              GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.bold),
          unselectedLabelStyle:
              GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.normal),
          type: BottomNavigationBarType.fixed,
          onTap: _onBottomNavTap,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.explore), label: 'Explore'),
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard), label: 'Channels'),
            BottomNavigationBarItem(
                icon: Icon(Icons.chat), label: 'Discussions'),
            BottomNavigationBarItem(
                icon: Icon(Icons.notifications), label: 'Notifications'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

class DiscussionCard extends StatelessWidget {
  final Map<String, dynamic> discussion;
  const DiscussionCard({super.key, required this.discussion});

  @override
  Widget build(BuildContext context) {
    final ImageProvider imageProvider =
        discussion['profileImage'].toString().startsWith('http')
            ? NetworkImage(discussion['profileImage'])
            : AssetImage(discussion['profileImage']) as ImageProvider;

    final statusColors = {
      'Police Officer': Colors.red,
      'Member': Colors.green,
    };
    final statusColor = statusColors[discussion['status']] ?? Colors.grey;

    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      child: Container(
        width: double.infinity,
        height: 168,
        decoration: BoxDecoration(
          image: const DecorationImage(
              image: AssetImage('assets/Module.png'), fit: BoxFit.cover),
          borderRadius: BorderRadius.circular(2),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 53.12,
                  height: 58.24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        discussion['userName'],
                        style: GoogleFonts.sora(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              discussion['status'],
                              style: GoogleFonts.sora(
                                fontSize: 10,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 100,
                            height: 16,
                            alignment: Alignment.center,
                            child: Text(
                              discussion['timePosted'],
                              style: GoogleFonts.sora(
                                fontSize: 11,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Flexible(
              child: Text(
                discussion['subtitle'],
                style: GoogleFonts.sora(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.red, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${discussion['likeCount']}',
                      style:
                          GoogleFonts.sora(fontSize: 14, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    const Icon(Icons.chat_bubble,
                        color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${discussion['commentCount']} Comments',
                      style:
                          GoogleFonts.sora(fontSize: 14, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
