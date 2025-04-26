import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:user_portal01/utility/http_with_refresh.dart';

class Channel {
  final String id;
  final String channelName;
  final List<String> users;

  Channel({
    required this.id,
    required this.channelName,
    required this.users,
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      id: json['id'] as String,
      channelName: json['channelName'] as String,
      users: List<String>.from(json['users'] ?? []),
    );
  }
}

class ChannelsPage extends StatefulWidget {
  const ChannelsPage({super.key});

  @override
  State<ChannelsPage> createState() => _ChannelsPageState();
}

class _ChannelsPageState extends State<ChannelsPage> {
  final _storage = const FlutterSecureStorage();
  List<Channel> _channels = [];
  bool _loading = true;
  bool _error = false;

  // Mappings for icon, description, route, and color based on channel name
  final Map<String, IconData> _iconMap = {
    'Water Utilities': Icons.water_drop,
    'Electricity': Icons.electrical_services,
    'Health Services': Icons.local_hospital,
    'Police Services': Icons.local_police,
  };

  final Map<String, String> _descriptionMap = {
    'Water Utilities':
        'Get updates about water supply, maintenance, and outage information.',
    'Electricity':
        'Stay informed about power outages, billing, and energy conservation.',
    'Health Services':
        'Find news on local healthcare, appointments, and health programs.',
    'Police Services':
        'Receive alerts and updates from your local police department.',
  };

  final Map<String, String> _routeMap = {
    'Water Utilities': '/waterUtilities',
    'Electricity': '/electricity',
    'Health Services': '/healthServices',
    'Police Services': '/policeServices',
  };

  @override
  void initState() {
    super.initState();
    _fetchChannels();
  }

  Future<void> _fetchChannels() async {
    setState(() {
      _loading = true;
      _error = false;
    });

    try {
      final communityId =
          await _storage.read(key: 'selected_community_id'); // ✅ fixed key
      final uri =
          Uri.parse('http://10.0.2.2:8081/communities/$communityId/channels');
      final response =
          await HttpWithRefresh.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body) as List;
        _channels = data
            .map((e) => Channel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        _error = true;
      }
    } catch (e) {
      _error = true;
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Color _colorForChannel(String name) {
    switch (name) {
      case 'Water Utilities':
        return Colors.blue;
      case 'Electricity':
        return Colors.yellow;
      case 'Health Services':
        return Colors.red;
      case 'Police Services':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _onChannelTap(Channel channel) {
    final name = channel.channelName;
    final description = _descriptionMap[name] ?? '';
    final route = _routeMap[name] ?? '/';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Join $name?',
            style: GoogleFonts.sora(fontWeight: FontWeight.bold)),
        content: Text(description, style: GoogleFonts.sora(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.sora(color: Colors.blue)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                channel.users.add(''); // increment member count
              });
              Navigator.pop(context);
              Navigator.pushNamed(context, route);
            },
            child: Text('Join', style: GoogleFonts.sora(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5874C6),
      appBar: AppBar(
        title: Text(
          'Channels',
          style: GoogleFonts.sora(
              fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF5874C6),
        elevation: 0,
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            )
          : _error
              ? Center(
                  child: Text(
                    'Failed to load channels.',
                    style:
                        GoogleFonts.sora(color: Colors.white70, fontSize: 16),
                  ),
                )
              : _channels.isEmpty
                  ? Center(
                      child: Text(
                        'No channels available.',
                        style: GoogleFonts.sora(
                            color: Colors.white70, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _channels.length,
                      itemBuilder: (context, index) {
                        final ch = _channels[index];
                        final icon =
                            _iconMap[ch.channelName] ?? Icons.dashboard;
                        final joinedCount = ch.users.length;
                        final color =
                            _colorForChannel(ch.channelName).withOpacity(0.8);

                        return GestureDetector(
                          onTap: () => _onChannelTap(ch),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(icon, size: 30, color: Colors.white),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        ch.channelName,
                                        style: GoogleFonts.sora(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _descriptionMap[ch.channelName] ?? '',
                                  style: GoogleFonts.sora(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.group,
                                        color: Colors.white, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$joinedCount members',
                                      style: GoogleFonts.sora(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.circular(0),
        child: BottomNavigationBar(
          currentIndex: 1,
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
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.pushNamed(context, '/dashboard');
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
          },
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
