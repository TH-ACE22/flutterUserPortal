import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:badges/badges.dart' as badges;
import 'package:share_plus/share_plus.dart';

class Discussion extends StatefulWidget {
  const Discussion({super.key});

  @override
  State<Discussion> createState() => _DiscussionState();
}

class _DiscussionState extends State<Discussion> {
  int notificationCount = 3;
  int _bottomNavIndex = 2; // Default to Discussions (index 2)

  Map<int, bool> showReplyBox = {};
  Map<int, int> likes = {};
  Map<int, bool> likedPosts = {};
  Map<int, bool> savedPosts = {};
  Map<int, List<Map<String, dynamic>>> comments = {};
  Map<int, TextEditingController> commentControllers = {};

  // New maps to manage edit and reply states and controllers for comments.
  Map<String, bool> showCommentEditBox = {};
  Map<String, bool> showCommentReplyBox = {};
  Map<String, TextEditingController> commentEditControllers = {};
  Map<String, TextEditingController> commentReplyControllers = {};

  // Variables to store the main user's status
  bool isUserOnline = true;
  String userRole = "Member"; // Change to "Police Officer" as needed

  void _onBottomNavTap(int index) {
    if (index == 0) {
      // If "Explore" is tapped, navigate to the explore route.
      Navigator.pushNamed(context, '/dashboard');
    } else if (index == 2) {
      // If "Discussions" is tapped, navigate to the discussion route.
      Navigator.pushNamed(context, '/discussion');
    } else if (index == 3) {
      // If "Notifications" is tapped, navigate to the notifications route.
      Navigator.pushNamed(context, '/notifications');
    } else {
      setState(() {
        _bottomNavIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/Module.png', fit: BoxFit.cover),
          ),
          Column(
            children: [
              const SizedBox(height: 40),
              _buildHeader(),
              Expanded(
                child: ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return _buildProfileCard(index);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: _bottomNavIndex,
          selectedItemColor: Colors.blue, // Selected item color
          unselectedItemColor: Colors.grey, // Unselected item color
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Image.asset('assets/Back.png', width: 35, height: 35),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'Discussion',
            style: GoogleFonts.sora(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Stack(
            children: [
              IconButton(
                icon: Image.asset('assets/Notification.png',
                    width: 37, height: 37),
                onPressed: () {},
              ),
              if (notificationCount > 0)
                Positioned(
                  right: 10,
                  top: 10,
                  child: badges.Badge(
                    badgeContent: Text(
                      notificationCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(int index) {
    commentControllers.putIfAbsent(index, () => TextEditingController());

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: const DecorationImage(
            image: AssetImage('assets/Module.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPostHeader(),
            const SizedBox(height: 12),
            Text(
              'This is a sample post content. It can have multiple lines.',
              style: GoogleFonts.sora(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Image.asset('assets/sample_post_image.png',
                width: double.infinity, height: 180, fit: BoxFit.cover),
            const SizedBox(height: 10),
            _buildActionButtons(index),
            if (showReplyBox[index] == true) _buildCommentSection(index),
          ],
        ),
      ),
    );
  }

  Widget _buildPostHeader() {
    return Row(
      children: [
        // Profile image with online indicator
        Stack(
          children: [
            const CircleAvatar(
              radius: 24,
              backgroundImage: AssetImage('assets/profile_pic.png'),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isUserOnline ? Colors.green : Colors.grey,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Name
              Text(
                'User Name',
                style: GoogleFonts.sora(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              // User Role and Time in a Single Row
              Row(
                children: [
                  // User role badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: userRole == "Member"
                          ? Colors.green
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      userRole,
                      style: GoogleFonts.sora(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Time display
                  Text(
                    '2 hours ago',
                    style: GoogleFonts.sora(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(int index) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
              likedPosts[index] == true
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: likedPosts[index] == true ? Colors.red : Colors.white),
          onPressed: () {
            setState(() {
              likedPosts[index] = !(likedPosts[index] ?? false);
              likes[index] = likedPosts[index] == true
                  ? (likes[index] ?? 0) + 1
                  : (likes[index] ?? 1) - 1;
            });
          },
        ),
        Text('${likes[index] ?? 10} Likes',
            style: GoogleFonts.sora(fontSize: 12, color: Colors.white)),
        IconButton(
          icon: const Icon(Icons.comment, color: Colors.white),
          onPressed: () {
            setState(() {
              showReplyBox[index] = !(showReplyBox[index] ?? false);
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: () {
            Share.share('Check out this discussion post!');
          },
        ),
        IconButton(
          icon: Icon(
            savedPosts[index] == true ? Icons.bookmark : Icons.bookmark_border,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              savedPosts[index] = !(savedPosts[index] ?? false);
            });
          },
        ),
      ],
    );
  }

  Widget _buildCommentSection(int index) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: commentControllers[index],
                  decoration: InputDecoration(
                    hintText: "Add a comment...",
                    hintStyle:
                        GoogleFonts.sora(fontSize: 12, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: () {
                  String commentText = commentControllers[index]!.text;
                  if (commentText.isNotEmpty) {
                    setState(() {
                      comments.putIfAbsent(index, () => []);
                      comments[index]!.add({
                        "user": "John Doe",
                        "comment": commentText,
                        "likes": 0,
                        "timestamp": DateTime.now(),
                        "replies": [],
                        "role": "Member",
                        "isOnline": true,
                      });
                      commentControllers[index]!.clear();
                    });
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Column(
          children: List.generate(comments[index]?.length ?? 0, (i) {
            var comment = comments[index]![i];
            String commentKey = "$index-$i";

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        backgroundImage: AssetImage('assets/profile_pic.png'),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            showCommentEditBox[commentKey] == true
                                ? TextField(
                                    controller:
                                        commentEditControllers.putIfAbsent(
                                            commentKey,
                                            () => TextEditingController(
                                                text: comment["comment"])),
                                    style: GoogleFonts.sora(
                                        fontSize: 14, color: Colors.white),
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "${comment["user"]}",
                                            style: GoogleFonts.sora(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                fontSize: 14),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "(${comment["role"] ?? "Member"})",
                                            style: GoogleFonts.sora(
                                              fontSize: 12,
                                              color:
                                                  (comment["role"] == "Member")
                                                      ? Colors.green
                                                      : Colors.white70,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color:
                                                  (comment["isOnline"] ?? false)
                                                      ? Colors.green
                                                      : Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        comment["comment"],
                                        style: GoogleFonts.sora(
                                            fontSize: 14, color: Colors.white),
                                      ),
                                    ],
                                  ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  _formatTimestamp(comment["timestamp"]),
                                  style: GoogleFonts.sora(
                                      fontSize: 12, color: Colors.grey),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      comment["likes"] =
                                          (comment["likes"] ?? 0) + 1;
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.favorite,
                                        color: (comment["likes"] ?? 0) > 0
                                            ? Colors.red
                                            : Colors.white,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        comment["likes"].toString(),
                                        style: GoogleFonts.sora(
                                            fontSize: 12, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.white, size: 18),
                                  onPressed: () {
                                    setState(() {
                                      showCommentEditBox[commentKey] =
                                          !(showCommentEditBox[commentKey] ??
                                              false);
                                      if (!(showCommentEditBox[commentKey] ??
                                          false)) {
                                        commentEditControllers[commentKey]
                                            ?.clear();
                                      }
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.reply,
                                      color: Colors.white, size: 18),
                                  onPressed: () {
                                    setState(() {
                                      showCommentReplyBox[commentKey] =
                                          !(showCommentReplyBox[commentKey] ??
                                              false);
                                      if (showCommentReplyBox[commentKey] ==
                                          true) {
                                        commentReplyControllers.putIfAbsent(
                                            commentKey,
                                            () => TextEditingController());
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.red, size: 18),
                        onPressed: () {
                          setState(() {
                            comments[index]!.removeAt(i);
                          });
                        },
                      ),
                    ],
                  ),
                  if (showCommentEditBox[commentKey] == true)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            comments[index]![i]["comment"] =
                                commentEditControllers[commentKey]?.text ??
                                    comment["comment"];
                            showCommentEditBox[commentKey] = false;
                          });
                        },
                        child: Text(
                          "Save",
                          style: GoogleFonts.sora(
                              fontSize: 12, color: Colors.blue),
                        ),
                      ),
                    ),
                  if (showCommentReplyBox[commentKey] == true)
                    Padding(
                      padding: const EdgeInsets.only(left: 40, top: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: commentReplyControllers[commentKey],
                              decoration: InputDecoration(
                                hintText: "Reply...",
                                hintStyle: GoogleFonts.sora(
                                    fontSize: 12, color: Colors.grey),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send, color: Colors.blue),
                            onPressed: () {
                              String replyText =
                                  commentReplyControllers[commentKey]?.text ??
                                      "";
                              if (replyText.isNotEmpty) {
                                setState(() {
                                  (comment["replies"] as List).add({
                                    "user": "Jane Smith",
                                    "comment": replyText,
                                    "likes": 0,
                                    "timestamp": DateTime.now(),
                                    "role": "Police Officer",
                                    "isOnline": false,
                                  });
                                  commentReplyControllers[commentKey]?.clear();
                                  showCommentReplyBox[commentKey] = false;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  _buildCommentReplies(comment),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCommentReplies(Map<String, dynamic> comment) {
    List replies = comment["replies"] ?? [];
    if (replies.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(left: 40, top: 6),
      child: Column(
        children: List.generate(replies.length, (i) {
          var reply = replies[i];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 14,
                  backgroundImage: AssetImage('assets/profile_pic.png'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "${reply["user"]}",
                            style: GoogleFonts.sora(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 13),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "(${reply["role"] ?? "Member"})",
                            style: GoogleFonts.sora(
                                fontSize: 11,
                                color: (reply["role"] == "Member")
                                    ? Colors.green
                                    : Colors.white70),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (reply["isOnline"] ?? false)
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        reply["comment"],
                        style:
                            GoogleFonts.sora(fontSize: 13, color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            _formatTimestamp(reply["timestamp"]),
                            style: GoogleFonts.sora(
                                fontSize: 11, color: Colors.grey),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                reply["likes"] = (reply["likes"] ?? 0) + 1;
                              });
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.favorite,
                                  color: (reply["likes"] ?? 0) > 0
                                      ? Colors.red
                                      : Colors.white,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  reply["likes"].toString(),
                                  style: GoogleFonts.sora(
                                      fontSize: 11, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

String _formatTimestamp(DateTime timestamp) {
  Duration diff = DateTime.now().difference(timestamp);
  if (diff.inMinutes < 1) return "Just now";
  if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
  if (diff.inHours < 24) return "${diff.inHours}h ago";
  return "${diff.inDays}d ago";
}
