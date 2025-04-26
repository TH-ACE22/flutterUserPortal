import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:badges/badges.dart' as badges;
import 'package:share_plus/share_plus.dart';

// --- Models ---
class DiscussionPost {
  final int id;
  final String userName;
  final String userRole;
  final bool isOnline;
  final String content;
  final String imageUrl;
  final DateTime timestamp;
  int likes;
  bool isLiked;
  bool isSaved;
  List<CommentModel> comments;

  DiscussionPost({
    required this.id,
    required this.userName,
    required this.userRole,
    required this.isOnline,
    required this.content,
    required this.imageUrl,
    required this.timestamp,
    this.likes = 0,
    this.isLiked = false,
    this.isSaved = false,
    List<CommentModel>? comments,
  }) : comments = comments ?? [];
}

class CommentModel {
  final String user;
  final String role;
  final bool isOnline;
  final String comment;
  final DateTime timestamp;
  int likes;
  List<CommentModel> replies;

  CommentModel({
    required this.user,
    required this.role,
    required this.isOnline,
    required this.comment,
    required this.timestamp,
    this.likes = 0,
    List<CommentModel>? replies,
  }) : replies = replies ?? [];
}

class Discussion extends StatefulWidget {
  const Discussion({super.key});

  @override
  State<Discussion> createState() => _DiscussionState();
}

class _DiscussionState extends State<Discussion> {
  final Color primaryColor = const Color(0xFF5874C6);
  int notificationCount = 3;
  int _bottomNavIndex = 2;

  List<DiscussionPost> _originalPosts = [];
  List<DiscussionPost> _displayedPosts = [];

  @override
  void initState() {
    super.initState();
    _loadSamplePosts();
  }

  void _loadSamplePosts() {
    _originalPosts = List.generate(
      5,
      (i) => DiscussionPost(
        id: i,
        userName: 'User $i',
        userRole: i.isEven ? 'Member' : 'Official',
        isOnline: i.isEven,
        content: 'Here is some vibrant discussion content for post #$i.',
        imageUrl: 'assets/sample_post_image.png',
        timestamp: DateTime.now().subtract(Duration(hours: i * 3 + 1)),
        likes: i * 3,
        comments: List.generate(
          i,
          (j) => CommentModel(
            user: 'Commenter $j',
            role: 'Member',
            isOnline: j.isEven,
            comment: 'Reply $j to post $i',
            timestamp: DateTime.now().subtract(Duration(minutes: j * 5)),
            replies: List.generate(
              j % 2, // Some comments have one reply for demonstration.
              (k) => CommentModel(
                user: 'Replier $k',
                role: 'Member',
                isOnline: true,
                comment: 'Reply $k to comment $j on post $i',
                timestamp: DateTime.now().subtract(Duration(minutes: k * 3)),
              ),
            ),
          ),
        ),
      ),
    );
    _displayedPosts = List.from(_originalPosts);
    setState(() {});
  }

  Future<void> _refreshPosts() async {
    await Future.delayed(const Duration(seconds: 1));
    _loadSamplePosts();
  }

  void _onBottomNavTap(int index) {
    if (_bottomNavIndex == index) return;
    setState(() => _bottomNavIndex = index);
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/dashboard');
        break;
      case 1:
        Navigator.pushNamed(context, '/channels');
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
      backgroundColor: primaryColor,
      floatingActionButton: FloatingActionButton.extended(
        elevation: 6,
        backgroundColor: Colors.white,
        icon: Icon(Icons.create, color: primaryColor),
        label: Text('New Post', style: GoogleFonts.sora(color: primaryColor)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onPressed: () {
          Navigator.pushNamed(context, '/create-post');
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshPosts,
                color: Colors.white,
                child: _displayedPosts.isEmpty
                    ? ListView(
                        children: [const SizedBox(height: 100), _emptyView()])
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount: _displayedPosts.length,
                        itemBuilder: (context, index) =>
                            _buildPostCard(_displayedPosts[index]),
                      ),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.circular(0.0),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: _bottomNavIndex,
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          selectedLabelStyle:
              GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelStyle:
              GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w400),
          type: BottomNavigationBarType.fixed,
          onTap: _onBottomNavTap,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.explore), label: 'Explore'),
            BottomNavigationBarItem(
                icon: Icon(Icons.view_list), label: 'Channels'),
            BottomNavigationBarItem(
                icon: Icon(Icons.chat), label: 'Discussions'),
            BottomNavigationBarItem(
                icon: Icon(Icons.notifications), label: 'Alerts'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _emptyView() => Center(
        child: Text(
          'No discussions yet',
          style: GoogleFonts.sora(
              color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w500),
        ),
      );

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withOpacity(0.7)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'Discussions',
            style: GoogleFonts.sora(
                fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          badges.Badge(
            badgeStyle: const badges.BadgeStyle(
              badgeColor: Colors.redAccent,
              padding: EdgeInsets.all(6),
            ),
            position: badges.BadgePosition.topEnd(top: 0, end: 4),
            showBadge: notificationCount > 0,
            badgeContent: Text(
              '$notificationCount',
              style: GoogleFonts.sora(color: Colors.white, fontSize: 10),
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.white),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(DiscussionPost post) {
    return Card(
      elevation: 6,
      shadowColor: primaryColor.withOpacity(0.2),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with user info
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundImage: AssetImage('assets/profile_pic.png'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.userName,
                          style: GoogleFonts.sora(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(post.userRole,
                                style: GoogleFonts.sora(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ),
                          const SizedBox(width: 8),
                          Text(_formatTimestamp(post.timestamp),
                              style: GoogleFonts.sora(
                                  fontSize: 11, color: Colors.grey[600])),
                        ],
                      ),
                    ],
                  ),
                ),
                if (post.isOnline)
                  const Icon(Icons.circle, size: 12, color: Colors.green),
              ],
            ),
          ),
          // Post image
          ClipRRect(
            child: Image.asset(
              post.imageUrl,
              height: 180,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 180,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image),
              ),
            ),
          ),
          // Post content and interaction row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.content,
                    style: GoogleFonts.sora(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87)),
                const SizedBox(height: 12),
                // Interaction row: likes, comment icon (opens modal), share, bookmark
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                              post.isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: post.isLiked ? Colors.red : Colors.grey),
                          onPressed: () {
                            setState(() {
                              post.isLiked = !post.isLiked;
                              post.likes += post.isLiked ? 1 : -1;
                            });
                          },
                        ),
                        Text('${post.likes}',
                            style: GoogleFonts.sora(
                                fontSize: 13, color: Colors.black)),
                        IconButton(
                          icon: const Icon(Icons.mode_comment_outlined,
                              color: Colors.grey),
                          onPressed: () {
                            _openCommentsModal(post);
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.share, color: Colors.grey),
                          onPressed: () async {
                            await Share.share(post.content);
                          },
                        ),
                        IconButton(
                          icon: Icon(
                              post.isSaved
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: post.isSaved ? primaryColor : Colors.grey),
                          onPressed: () {
                            setState(() {
                              post.isSaved = !post.isSaved;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Optionally, show a snippet of first two comments inline
                if (post.comments.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Comments (${post.comments.length})',
                        style: GoogleFonts.sora(
                            fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      ...post.comments
                          .take(2)
                          .map((c) => _buildCommentItem(c, post)),
                      if (post.comments.length > 2)
                        TextButton(
                          onPressed: () {
                            _openCommentsModal(post);
                          },
                          child: Text("View more...",
                              style: GoogleFonts.sora(
                                  color: primaryColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500)),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Updated comment item widget with inline reply functionality
  Widget _buildCommentItem(CommentModel comment, DiscussionPost post) {
    // Using StatefulBuilder to manage local reply input visibility
    return StatefulBuilder(
      builder: (context, setStateLocal) {
        bool isReplying = false;
        final TextEditingController replyController = TextEditingController();
        return Padding(
          padding: const EdgeInsets.only(top: 6.0, left: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                      radius: 16,
                      backgroundImage: AssetImage('assets/profile_pic.png')),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(comment.user,
                              style: GoogleFonts.sora(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87)),
                          const SizedBox(height: 2),
                          Text(comment.comment,
                              style: GoogleFonts.sora(
                                  fontSize: 13, color: Colors.black54)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(_formatTimestamp(comment.timestamp),
                                  style: GoogleFonts.sora(
                                      fontSize: 11, color: Colors.grey)),
                              const SizedBox(width: 8),
                              if (comment.isOnline)
                                const Icon(Icons.circle,
                                    size: 10, color: Colors.green),
                              const Spacer(),
                              IconButton(
                                icon: Icon(Icons.thumb_up_alt_outlined,
                                    size: 18, color: Colors.grey[700]),
                                onPressed: () {
                                  setState(() {
                                    comment.likes++;
                                  });
                                },
                              ),
                              Text('${comment.likes}',
                                  style: GoogleFonts.sora(fontSize: 12)),
                              IconButton(
                                icon: const Icon(Icons.reply_outlined,
                                    size: 18, color: Colors.grey),
                                onPressed: () {
                                  setStateLocal(() {
                                    isReplying = !isReplying;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Display reply input if toggled
              if (isReplying)
                Padding(
                  padding: const EdgeInsets.only(left: 40, top: 4, right: 8),
                  child: TextField(
                    controller: replyController,
                    decoration: InputDecoration(
                      hintText: 'Reply...',
                      hintStyle: GoogleFonts.sora(fontSize: 13),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        setState(() {
                          comment.replies.add(CommentModel(
                            user: "You",
                            role: "Member",
                            isOnline: true,
                            comment: value.trim(),
                            timestamp: DateTime.now(),
                          ));
                        });
                        replyController.clear();
                        setStateLocal(() {
                          isReplying = false;
                        });
                      }
                    },
                  ),
                ),
              // Show replies if available
              if (comment.replies.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 40, top: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: comment.replies
                        .map((reply) => _buildReplyItem(reply))
                        .toList(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // Simple widget for displaying a reply (read-only)
  Widget _buildReplyItem(CommentModel reply) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
              radius: 14,
              backgroundImage: AssetImage('assets/profile_pic.png')),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(reply.user,
                      style: GoogleFonts.sora(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87)),
                  const SizedBox(height: 2),
                  Text(reply.comment,
                      style: GoogleFonts.sora(
                          fontSize: 12, color: Colors.black54)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(_formatTimestamp(reply.timestamp),
                          style: GoogleFonts.sora(
                              fontSize: 10, color: Colors.grey)),
                      const SizedBox(width: 8),
                      if (reply.isOnline)
                        const Icon(Icons.circle, size: 8, color: Colors.green),
                      const Spacer(),
                      IconButton(
                        icon: Icon(Icons.thumb_up_alt_outlined,
                            size: 16, color: Colors.grey[700]),
                        onPressed: () {
                          setState(() {
                            reply.likes++;
                          });
                        },
                      ),
                      Text('${reply.likes}',
                          style: GoogleFonts.sora(fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
  }

  // Open full comment view modal from main post interaction
  void _openCommentsModal(DiscussionPost post) {
    final TextEditingController commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.95, // Take up to 95% of screen height
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Drag handle
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              // Header row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text("Comments",
                        style: GoogleFonts.sora(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Comments list
              Expanded(
                child: post.comments.isEmpty
                    ? Center(
                        child: Text("No comments yet",
                            style: GoogleFonts.sora(
                                fontSize: 14, color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: post.comments.length,
                        itemBuilder: (context, index) =>
                            _buildCommentItem(post.comments[index], post),
                      ),
              ),
              const Divider(height: 1),
              // Comment input field
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 16,
                      backgroundImage: AssetImage('assets/profile_pic.png'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        decoration: InputDecoration(
                          hintText: 'Write a comment...',
                          hintStyle: GoogleFonts.sora(fontSize: 13),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 14),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (value) {
                          if (value.trim().isNotEmpty) {
                            setState(() {
                              post.comments.add(CommentModel(
                                user: "You",
                                role: "Member",
                                isOnline: true,
                                comment: value.trim(),
                                timestamp: DateTime.now(),
                              ));
                            });
                            commentController.clear();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
