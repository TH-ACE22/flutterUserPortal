import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class CreatePostForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onPostCreated;
  final bool isModal;
  const CreatePostForm({
    super.key,
    required this.onPostCreated,
    this.isModal = true,
  });

  @override
  State<CreatePostForm> createState() => _CreatePostFormState();
}

class _CreatePostFormState extends State<CreatePostForm> {
  final TextEditingController _postController = TextEditingController();
  List<String> uploadedUrls = [];
  final ImagePicker _picker = ImagePicker();
  bool isUploading = false;

  Future<void> _uploadFile(File file) async {
    final uri = Uri.parse('http://10.0.2.2:8081/api/v1/images/upload');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    if (response.statusCode == 201) {
      final body = await response.stream.bytesToString();
      final data = jsonDecode(body);
      setState(() {
        uploadedUrls.add(data['secure_url']);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Upload failed")),
      );
    }
  }

  Future<void> _pickAttachment() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      allowedExtensions: ["png", "jpg", "jpeg", "pdf", "doc", "docx"],
      type: FileType.custom,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() => isUploading = true);
      for (var file in result.files) {
        if (file.path != null) {
          await _uploadFile(File(file.path!));
        }
      }
      setState(() => isUploading = false);
    }
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() => isUploading = true);
      await _uploadFile(File(photo.path));
      setState(() => isUploading = false);
    }
  }

  void _removeAttachment(String url) {
    setState(() => uploadedUrls.remove(url));
  }

  void _createPost() {
    if (_postController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please write something before posting.',
              style: GoogleFonts.sora()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newPost = {
      'profileImage': 'assets/profile_pic.png',
      'userName': 'You',
      'status': 'Just Posted',
      'timePosted': 'Now',
      'subtitle': _postController.text.trim(),
      'likeCount': 0,
      'commentCount': 0,
      'attachments': uploadedUrls,
    };
    widget.onPostCreated(newPost);
    if (widget.isModal) Navigator.pop(context);
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
                  onPressed: isUploading ? null : _pickAttachment,
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
                  onPressed: isUploading ? null : _takePhoto,
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
            if (uploadedUrls.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: uploadedUrls
                      .map((url) => Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Chip(
                              label: Text(
                                'File',
                                style: GoogleFonts.sora(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              avatar: url.endsWith(".jpg") ||
                                      url.endsWith(".jpeg") ||
                                      url.endsWith(".png")
                                  ? CircleAvatar(
                                      backgroundImage: NetworkImage(url),
                                    )
                                  : const Icon(Icons.insert_drive_file),
                              backgroundColor: Colors.blueGrey,
                              onDeleted: () => _removeAttachment(url),
                            ),
                          ))
                      .toList(),
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isUploading ? null : _createPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: isUploading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
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
