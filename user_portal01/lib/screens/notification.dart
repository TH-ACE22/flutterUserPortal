import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final _storage = const FlutterSecureStorage();
  final List<Map<String, dynamic>> _notifications = [];

  late StompClient _stompClient;
  String? _userId;
  int _bottomNavIndex = 3;

  @override
  void initState() {
    super.initState();
    _initializeUserAndSocket();
  }

  void _initializeUserAndSocket() async {
    _userId = await _storage.read(key: 'user_id');
    if (_userId == null) {
      debugPrint("⚠️ No user ID found for WebSocket notifications.");
      return;
    }

    _stompClient = StompClient(
      config: StompConfig.SockJS(
        url: 'http://10.0.2.2:8081/ws',
        onConnect: _onConnect,
        onWebSocketError: (dynamic error) =>
            debugPrint('WebSocket error: $error'),
      ),
    );

    _stompClient.activate();
  }

  void _onConnect(StompFrame frame) {
    final topic = '/user/$_userId/queue/notifications';
    _stompClient.subscribe(
      destination: topic,
      callback: (frame) {
        if (frame.body != null) {
          final data = jsonDecode(frame.body!);
          final message = {
            "sender": data['sender'] ?? "Unknown",
            "message": data['message'] ?? "",
            "timestamp": data['timestamp'] ?? DateTime.now().toIso8601String(),
          };

          // Avoid duplicates
          if (!_notifications.any((e) =>
              e['message'] == message['message'] &&
              e['sender'] == message['sender'])) {
            setState(() {
              _notifications.insert(0, message);
            });
          }
        }
      },
    );
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
      case 4:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  @override
  void dispose() {
    _stompClient.deactivate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5874C6),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon:
                          Image.asset('assets/Back.png', width: 35, height: 35),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Text(
                          "Notifications",
                          style: GoogleFonts.sora(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (_notifications.isNotEmpty)
                          Positioned(
                            right: -6,
                            child: CircleAvatar(
                              radius: 7,
                              backgroundColor: Colors.red,
                              child: Text(
                                _notifications.length.toString(),
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.white),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 35),
                  ],
                ),
              ),
            ),
          ),
          _notifications.isEmpty
              ? const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        "No notifications yet.",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final notif = _notifications[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          elevation: 4,
                          child: ListTile(
                            isThreeLine: true,
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Text(
                                notif["sender"]![0],
                                style: GoogleFonts.sora(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              notif["sender"]!,
                              style:
                                  GoogleFonts.sora(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '${notif["message"]}\n${_formatTime(notif["timestamp"]!)}',
                              style: GoogleFonts.sora(fontSize: 14),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: _notifications.length,
                  ),
                ),
        ],
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.circular(0.0),
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
