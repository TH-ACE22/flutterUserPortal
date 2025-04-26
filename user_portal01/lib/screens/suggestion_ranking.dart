import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SuggestionRankingPage extends StatefulWidget {
  const SuggestionRankingPage({super.key});

  @override
  State<SuggestionRankingPage> createState() => _SuggestionRankingPageState();
}

class _SuggestionRankingPageState extends State<SuggestionRankingPage> {
  final storage = const FlutterSecureStorage();
  List<Map<String, dynamic>> _suggestions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchSuggestions();
  }

  Future<void> _fetchSuggestions() async {
    final token = await storage.read(key: 'jwt_token');
    final communityId = await storage.read(key: 'joined_community_id');
    final channelId = await storage.read(key: 'selected_channel_id');

    if (token == null || communityId == null || channelId == null) {
      setState(() => _loading = false);
      return;
    }

    final uri = Uri.parse(
        'http://10.0.2.2:8081/api/v1/polls/suggestions/community/$communityId/channel/$channelId');
    final res =
        await http.get(uri, headers: {'Authorization': 'Bearer $token'});

    if (res.statusCode == 200) {
      final List<dynamic> data = json.decode(res.body);
      setState(() {
        _suggestions = List<Map<String, dynamic>>.from(data);
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _submitPriorities() async {
    final token = await storage.read(key: 'jwt_token');
    final userId = await storage.read(key: 'user_id');

    if (token == null || userId == null) return;

    final uri = Uri.parse('http://10.0.2.2:8081/api/v1/polls/suggestions/rank');
    final ranked = _suggestions
        .asMap()
        .entries
        .map((e) => {
              'suggestionId': e.value['id'],
              'priority': e.key + 1,
              'userId': userId
            })
        .toList();

    final res = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(ranked),
    );

    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ranking submitted successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit rankings')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5874C6),
      appBar: AppBar(
        title: Text('Rank Suggestions',
            style: GoogleFonts.sora(
                color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF5874C6),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : ReorderableListView.builder(
              itemCount: _suggestions.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = _suggestions.removeAt(oldIndex);
                  _suggestions.insert(newIndex, item);
                });
              },
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final suggestion = _suggestions[index];
                return Card(
                  key: ValueKey(suggestion['id']),
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(
                      suggestion['suggestionText'],
                      style: GoogleFonts.sora(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Priority: ${index + 1}',
                        style: GoogleFonts.sora()),
                    trailing: const Icon(Icons.drag_handle),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _submitPriorities,
        backgroundColor: Colors.blue,
        label: Text('Submit', style: GoogleFonts.sora()),
        icon: const Icon(Icons.save),
      ),
    );
  }
}
