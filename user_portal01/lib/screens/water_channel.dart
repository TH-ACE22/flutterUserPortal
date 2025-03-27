// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:badges/badges.dart' as badges;
import 'package:user_portal01/widgets/create_post_form.dart';
import 'package:user_portal01/widgets/poll_survey_section.dart';
import 'package:user_portal01/widgets/profile_card.dart';
import 'package:user_portal01/widgets/requests_section.dart';
import 'package:user_portal01/widgets/report_form.dart';

class WaterChannel extends StatefulWidget {
  const WaterChannel({super.key});

  @override
  State<WaterChannel> createState() => _WaterChannelState();
}

class _WaterChannelState extends State<WaterChannel> {
  final List<String> categories = [
    'Latest',
    'Report',
    'Requests',
    'Polls & Survey',
    'Post'
  ];
  String selectedCategory = 'Latest';

  // Example notification count.
  int notificationCount = 3;

  // Water-related members (update as needed).
  final List<Map<String, dynamic>> members = [
    {
      'name': 'Engineer Sara',
      'role': 'Engineer',
      'image': 'assets/profile_pic.png'
    },
    {
      'name': 'Technician Mark',
      'role': 'Technician',
      'image': 'assets/profile_pic.png'
    },
    {
      'name': 'Customer Liam',
      'role': 'Customer',
      'image': 'assets/profile_pic.png'
    },
    {
      'name': 'Customer Zoe',
      'role': 'Customer',
      'image': 'assets/profile_pic.png'
    },
  ];

  // Posts for the "Latest" view (initially empty to show only dynamic posts).
  List<Map<String, dynamic>> posts = [];

  // Sample static requests.
  final List<Map<String, String>> staticRequests = [
    {"text": "Water supply disruption in Zone 1", "status": "Ongoing"},
    {"text": "Leak detected in Main Pipeline", "status": "Received"},
    {"text": "Request additional water tank", "status": "Ongoing"},
  ];

  // Poll requests.
  final List<Map<String, String>> pollRequests = [];

  // Bottom navigation state.
  int _bottomNavIndex = 1;

  void _onBottomNavTap(int index) {
    if (index == 0) {
      Navigator.pushNamed(context, '/dashboard');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/discussion');
    } else {
      setState(() {
        _bottomNavIndex = index;
      });
    }
  }

  // Open CreatePostForm as a modal bottom sheet.

  @override
  Widget build(BuildContext context) {
    // Sort members: Engineers/Technicians first.
    final List<Map<String, dynamic>> sortedMembers = List.from(members)
      ..sort((a, b) {
        if (a['role'] == 'Engineer' && b['role'] != 'Engineer') return -1;
        if (a['role'] != 'Engineer' && b['role'] == 'Engineer') return 1;
        return 0;
      });

    // Combine static and poll requests.
    final List<Map<String, String>> combinedRequests = [
      ...staticRequests,
      ...pollRequests,
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Background image.
          Positioned.fill(
            child: Image.asset('assets/Module.png', fit: BoxFit.cover),
          ),
          CustomScrollView(
            slivers: [
              // Header AppBar.
              SliverAppBar(
                automaticallyImplyLeading: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                expandedHeight: 80,
                flexibleSpace: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back button: if in Report, Requests, Polls & Survey, or Post, reset to Latest.
                        IconButton(
                          icon: Image.asset(
                            'assets/Back.png',
                            width: 35,
                            height: 35,
                          ),
                          onPressed: () {
                            if (selectedCategory == "Report" ||
                                selectedCategory == "Requests" ||
                                selectedCategory == "Polls & Survey" ||
                                selectedCategory == "Post") {
                              setState(() {
                                selectedCategory = "Latest";
                              });
                            } else {
                              Navigator.pop(context);
                            }
                          },
                        ),
                        Text(
                          selectedCategory == "Report"
                              ? "Report"
                              : selectedCategory == "Requests"
                                  ? "Requests"
                                  : selectedCategory == "Polls & Survey"
                                      ? "Polls & Survey"
                                      : selectedCategory == "Post"
                                          ? "Post"
                                          : "Water",
                          style: GoogleFonts.sora(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Stack(
                          children: [
                            IconButton(
                              icon: Image.asset(
                                'assets/Notification.png',
                                width: 37,
                                height: 37,
                              ),
                              onPressed: () {},
                            ),
                            if (notificationCount > 0)
                              Positioned(
                                right: 10,
                                top: 10,
                                child: badges.Badge(
                                  badgeContent: Text(
                                    notificationCount.toString(),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Categories row.
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Show Members only if not in special categories.
                      if (selectedCategory != "Report" &&
                          selectedCategory != "Requests" &&
                          selectedCategory != "Polls & Survey" &&
                          selectedCategory != "Post") ...[
                        Text(
                          'Members',
                          style: GoogleFonts.sora(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: sortedMembers.length,
                            itemBuilder: (context, index) {
                              final member = sortedMembers[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundImage:
                                          AssetImage(member['image']),
                                    ),
                                    const SizedBox(height: 4),
                                    SizedBox(
                                      width: 70,
                                      child: Text(
                                        member['name'],
                                        style: GoogleFonts.sora(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      // Categories Section.
                      Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: const DecorationImage(
                              image: AssetImage('assets/Module.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: categories.map((category) {
                                bool isSelected = selectedCategory == category;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedCategory = category;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    alignment: Alignment.center,
                                    decoration: isSelected
                                        ? const BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: Colors.blue,
                                                width: 4.0,
                                              ),
                                            ),
                                          )
                                        : null,
                                    child: Text(
                                      category,
                                      style: GoogleFonts.sora(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Conditional content based on selected category.
              if (selectedCategory == "Report")
                const SliverToBoxAdapter(child: ReportForm())
              else if (selectedCategory == "Requests")
                SliverToBoxAdapter(
                  child: RequestsSection(requests: combinedRequests),
                )
              else if (selectedCategory == "Polls & Survey")
                SliverToBoxAdapter(
                  child: PollSurveySection(
                    onPollSent: (Map<String, String> pollReq) {
                      setState(() {
                        pollRequests.add(pollReq);
                      });
                    },
                  ),
                )
              else if (selectedCategory == "Post")
                // Inline CreatePostForm for Post category.
                SliverToBoxAdapter(
                  child: CreatePostForm(
                    isModal: false,
                    onPostCreated: (newPost) {
                      setState(() {
                        posts.insert(0, newPost);
                        selectedCategory = "Latest";
                      });
                    },
                  ),
                )
              else
                // For "Latest", display the posts container.
                posts.isEmpty
                    ? const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text(
                              "No posts yet.",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final post = posts[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8),
                              child: ProfileCard(
                                profileImage: post['profileImage'],
                                userName: post['userName'],
                                status: post['status'],
                                timePosted: post['timePosted'],
                                subtitle: post['subtitle'],
                                likeCount: post['likeCount'],
                                commentCount: post['commentCount'],
                                attachments: post['attachments'] ?? [],
                              ),
                            );
                          },
                          childCount: posts.length,
                        ),
                      ),
            ],
          ),
        ],
      ),
      floatingActionButton: selectedCategory == "Latest"
          ? FloatingActionButton(
              backgroundColor: Colors.blue,
              onPressed: () {
                setState(() {
                  selectedCategory = "Post";
                });
              },
              child: const Icon(Icons.add, size: 30, color: Colors.white),
            )
          : null,
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: _bottomNavIndex,
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
