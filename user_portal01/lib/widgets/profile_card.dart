import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileCard extends StatelessWidget {
  final String profileImage;
  final String userName;
  final String status;
  final String timePosted;
  final String subtitle;
  final int likeCount;
  final int commentCount;
  final List<String> attachments;

  const ProfileCard({
    super.key,
    required this.profileImage,
    required this.userName,
    required this.status,
    required this.timePosted,
    required this.subtitle,
    required this.likeCount,
    required this.commentCount,
    required this.attachments,
  });

  /// Builds a horizontal list of attachments.
  Widget _buildAttachments() {
    if (attachments.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: SizedBox(
        height: 120,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: attachments.length,
          itemBuilder: (context, index) {
            final file = attachments[index];
            Widget content;
            // Check if the file string appears to be a file path (contains a directory separator).
            if (file.contains('/')) {
              // For file paths, use Image.file
              content = Image.file(
                File(file),
                fit: BoxFit.cover,
                width: 120,
                height: 120,
              );
            } else if (file.endsWith(".png") ||
                file.endsWith(".jpg") ||
                file.endsWith(".jpeg")) {
              // For asset images.
              content = Image.asset(
                file,
                fit: BoxFit.cover,
                width: 120,
                height: 120,
              );
            } else if (file.endsWith(".mp4")) {
              content =
                  const Icon(Icons.videocam, color: Colors.white, size: 50);
            } else if (file.endsWith(".mp3")) {
              content =
                  const Icon(Icons.audiotrack, color: Colors.white, size: 50);
            } else {
              content = const Icon(Icons.insert_drive_file,
                  color: Colors.white, size: 50);
            }
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: content,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ImageProvider imageProvider = profileImage.startsWith('http')
        ? NetworkImage(profileImage)
        : AssetImage(profileImage) as ImageProvider;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: const DecorationImage(
            image: AssetImage('assets/Module.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile image and details.
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
                        userName,
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
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              status,
                              style: GoogleFonts.sora(
                                fontSize: 10,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            timePosted,
                            style: GoogleFonts.sora(
                              fontSize: 11,
                              color: Colors.white,
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
            Text(
              subtitle,
              style: GoogleFonts.sora(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            // Attachments display.
            _buildAttachments(),
            const SizedBox(height: 8),
            // Like and comment metrics.
            Row(
              children: [
                Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.red, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '$likeCount',
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
                      '$commentCount Comments',
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
