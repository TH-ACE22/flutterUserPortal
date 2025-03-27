import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CommunitiesPage extends StatefulWidget {
  const CommunitiesPage({super.key});

  @override
  State<CommunitiesPage> createState() => _CommunitiesPageState();
}

class _CommunitiesPageState extends State<CommunitiesPage> {
  // Sample community data.
  final List<Map<String, dynamic>> communities = [
    {
      "name": "Community A",
      "description": "A vibrant community focused on sustainability.",
      "members": 120,
    },
    {
      "name": "Community B",
      "description": "A creative community for art and culture enthusiasts.",
      "members": 85,
    },
    {
      "name": "Community C",
      "description": "A community dedicated to tech and innovation.",
      "members": 200,
    },
    {
      "name": "Community D",
      "description": "A local business networking community.",
      "members": 50,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a Stack to overlay the background image.
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/Module.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Header with back button and title.
                Row(
                  children: [
                    IconButton(
                      icon:
                          Image.asset('assets/Back.png', width: 35, height: 35),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Communities",
                      style: GoogleFonts.sora(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // List of communities.
                ...communities.map((community) {
                  return Card(
                    color: Colors.black45,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        community["name"],
                        style: GoogleFonts.sora(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            community["description"],
                            style: GoogleFonts.sora(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.group,
                                  size: 16, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                "${community['members']} members",
                                style: GoogleFonts.sora(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      onTap: () {
                        // You can replace this with any action, such as selecting the community.
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                "Selected ${community['name']} community."),
                            backgroundColor: Colors.blue,
                          ),
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
