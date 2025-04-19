class CommunitySummary {
  final String id;
  final String name;
  final String description;
  final String location; // 👈 add this
  final int memberCount;

  CommunitySummary({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.memberCount,
  });

  factory CommunitySummary.fromJson(Map<String, dynamic> json) =>
      CommunitySummary(
        id: json['id'],
        name: json['name'],
        description: json['description'] ?? '',
        location: json['location'] ?? 'Unknown', // 👈 parse location
        memberCount: json['memberCount'] ?? 0,
      );
}
