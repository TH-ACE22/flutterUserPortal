import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class CreatePostForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onPostCreated;
  final bool isModal;
  const CreatePostForm({
    super.key,
    required this.onPostCreated,
    this.isModal = true, // defaults to modal usage
  });

  @override
  State<CreatePostForm> createState() => _CreatePostFormState();
}

class _CreatePostFormState extends State<CreatePostForm> {
  final TextEditingController _postController = TextEditingController();
  List<String> attachments = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAttachment() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowedExtensions: [
        "png",
        "jpg",
        "jpeg",
        "mp4",
        "mp3",
        "pdf",
        "doc",
        "docx"
      ],
      type: FileType.custom,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        attachments.add(result.files.first.name);
      });
    }
  }

  // Capture an image from the camera.
  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        attachments.add(photo.path);
      });
    }
  }

  void _removeAttachment(String file) {
    setState(() {
      attachments.remove(file);
    });
  }

  void _createPost() {
    if (_postController.text.trim().isNotEmpty) {
      final newPost = {
        'profileImage': 'assets/profile_pic.png',
        'userName': 'You',
        'status': 'Just Posted',
        'timePosted': 'Now',
        'subtitle': _postController.text.trim(),
        'likeCount': 0,
        'commentCount': 0,
        'attachments': attachments,
      };
      widget.onPostCreated(newPost);
      // Only pop the modal if the form was launched as a modal.
      if (widget.isModal) {
        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please write something before posting.',
            style: GoogleFonts.sora(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Create Post',
              style: GoogleFonts.sora(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _postController,
              maxLines: 4,
              style: GoogleFonts.sora(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'What\'s on your mind?',
                hintStyle: GoogleFonts.sora(color: Colors.white70),
                filled: true,
                fillColor: Colors.black45,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickAttachment,
                  icon: const Icon(Icons.attach_file, color: Colors.white),
                  label: Text(
                    'Attach File',
                    style: GoogleFonts.sora(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _takePhoto,
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  label: Text(
                    'Take Photo',
                    style: GoogleFonts.sora(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (attachments.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: attachments
                      .map((file) => Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Chip(
                              label: Text(
                                file,
                                style: GoogleFonts.sora(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              backgroundColor: Colors.blueGrey,
                              onDeleted: () => _removeAttachment(file),
                            ),
                          ))
                      .toList(),
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _createPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Post',
                style: GoogleFonts.sora(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }
}
