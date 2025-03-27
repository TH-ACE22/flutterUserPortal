import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PollSurveySection extends StatefulWidget {
  final Function(Map<String, String>) onPollSent;
  const PollSurveySection({super.key, required this.onPollSent});

  @override
  State<PollSurveySection> createState() => _PollSurveySectionState();
}

class _PollSurveySectionState extends State<PollSurveySection> {
  final TextEditingController _pollController = TextEditingController();
  // Start with an empty list of polls.
  final List<Map<String, dynamic>> polls = [];

  // Create a new poll.
  void _createPoll() {
    String text = _pollController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        polls.add({
          "pollText": text,
          "agreeVotes": 0,
          "disagreeVotes": 0,
          "isCreator": true,
        });
        _pollController.clear();
      });
    }
  }

  // Function to simulate voting.
  void _vote(int pollIndex, bool agree) {
    setState(() {
      if (agree) {
        polls[pollIndex]["agreeVotes"] += 1;
      } else {
        polls[pollIndex]["disagreeVotes"] += 1;
      }
    });
  }

  // Function to simulate sending the poll.
  void _sendPoll(int pollIndex) {
    widget.onPollSent(
        {"text": polls[pollIndex]["pollText"], "status": "Ongoing"});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Poll "${polls[pollIndex]["pollText"]}" sent successfully!',
          style: GoogleFonts.sora(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
    );
  }

  // Function to delete a poll.
  void _deletePoll(int pollIndex) {
    setState(() {
      polls.removeAt(pollIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Polls & Surveys',
              style: GoogleFonts.sora(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // New poll creation.
          TextField(
            controller: _pollController,
            maxLines: 2,
            style: GoogleFonts.sora(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter your poll suggestion...',
              hintStyle: GoogleFonts.sora(color: Colors.white70),
              filled: true,
              fillColor: Colors.black45,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: _createPoll,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                "Create Poll",
                style: GoogleFonts.sora(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: polls.length,
            itemBuilder: (context, index) {
              final poll = polls[index];
              int totalVotes = poll["agreeVotes"] + poll["disagreeVotes"];
              double agreePercent =
                  totalVotes > 0 ? poll["agreeVotes"] / totalVotes : 0.0;
              double disagreePercent =
                  totalVotes > 0 ? poll["disagreeVotes"] / totalVotes : 0.0;
              bool conditionMet = agreePercent >= 0.7;
              return Card(
                color: Colors.transparent,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Poll header with delete icon if creator.
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              poll["pollText"],
                              style: GoogleFonts.sora(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (poll["isCreator"])
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () => _deletePoll(index),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Options displayed with progress bars.
                      _PollOption(
                        optionText: "Agree",
                        voteCount: poll["agreeVotes"],
                        percentage: agreePercent,
                        onTap: () => _vote(index, true),
                      ),
                      const SizedBox(height: 8),
                      _PollOption(
                        optionText: "Disagree",
                        voteCount: poll["disagreeVotes"],
                        percentage: disagreePercent,
                        onTap: () => _vote(index, false),
                      ),
                      const SizedBox(height: 8),
                      // Show Send button if creator and condition met.
                      if (poll["isCreator"] && conditionMet)
                        Center(
                          child: ElevatedButton(
                            onPressed: () => _sendPoll(index),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                            child: Text(
                              "Send Poll",
                              style: GoogleFonts.sora(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// _PollOption widget definition.
class _PollOption extends StatelessWidget {
  final String optionText;
  final int voteCount;
  final double percentage;
  final VoidCallback onTap;

  const _PollOption({
    // ignore: unused_element
    super.key,
    required this.optionText,
    required this.voteCount,
    required this.percentage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$optionText ($voteCount)",
              style: GoogleFonts.sora(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            // Progress bar-like indicator.
            Stack(
              children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      height: 10,
                      width: constraints.maxWidth * percentage,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "${(percentage * 100).toStringAsFixed(1)}%",
              style: GoogleFonts.sora(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
