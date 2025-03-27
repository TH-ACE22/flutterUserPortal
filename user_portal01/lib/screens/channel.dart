import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChannelsPage extends StatefulWidget {
  const ChannelsPage({super.key});

  @override
  State<ChannelsPage> createState() => _ChannelsPageState();
}

class _ChannelsPageState extends State<ChannelsPage> {
  // Sample channels data with description and joined count.
  List<Map<String, dynamic>> channels = [
    {
      'name': 'Water Utilities',
      'icon': Icons.water_drop,
      'color': Colors.blue,
      'route': '/waterUtilities',
      'description':
          'Get updates about water supply, maintenance, and outage information.',
      'joinedCount': 10,
    },
    {
      'name': 'Electricity',
      'icon': Icons.electrical_services,
      'color': Colors.yellow,
      'route': '/electricity',
      'description':
          'Stay informed about power outages, billing, and energy conservation.',
      'joinedCount': 15,
    },
    {
      'name': 'Health Services',
      'icon': Icons.local_hospital,
      'color': Colors.red,
      'route': '/healthServices',
      'description':
          'Find news on local healthcare, appointments, and health programs.',
      'joinedCount': 20,
    },
    {
      'name': 'Police Services',
      'icon': Icons.local_police,
      'color': Colors.green,
      'route': '/policeServices',
      'description':
          'Receive alerts and updates from your local police department.',
      'joinedCount': 25,
    },
  ];

  // When a channel card is tapped, prompt the user to join or cancel.
  void _onChannelTap(Map<String, dynamic> channel) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Join ${channel['name']}?',
              style: GoogleFonts.sora(fontWeight: FontWeight.bold)),
          content: Text(channel['description'],
              style: GoogleFonts.sora(fontSize: 14)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  Text('Cancel', style: GoogleFonts.sora(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  channel['joinedCount'] = (channel['joinedCount'] as int) + 1;
                });
                Navigator.pop(context); // Close the dialog
                Navigator.pushNamed(context, channel['route']);
              },
              child: Text('Join', style: GoogleFonts.sora(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background image to maintain theme.
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/Module.png', fit: BoxFit.cover),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: channels.length,
                itemBuilder: (context, index) {
                  final channel = channels[index];
                  return GestureDetector(
                    onTap: () => _onChannelTap(channel),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: channel['color'].withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(channel['icon'],
                                  size: 30, color: Colors.white),
                              const SizedBox(width: 12),
                              Text(
                                channel['name'],
                                style: GoogleFonts.sora(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            channel['description'],
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
                                '${channel['joinedCount']} members',
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
            ),
          ),
        ],
      ),
      // Bottom Navigation Bar (shared design theme)
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BottomNavigationBar(
          currentIndex: 1, // Adjust as needed
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
            // Example navigation handling; update routes as needed.
            if (index == 0) {
              Navigator.pushNamed(context, '/dashboard');
            } else if (index == 2) {
              Navigator.pushNamed(context, '/discussion');
            } else if (index == 3) {
              Navigator.pushNamed(context, '/notifications');
            } else if (index == 4) {
              Navigator.pushNamed(context, '/profile');
            }
          },
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
