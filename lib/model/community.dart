class Community {
  final String id;
  final String name;
  final String description;
  final String authorId;
  final int memberCount; // New field

  Community({
    required this.id,
    required this.name,
    required this.description,
    required this.authorId,
    this.memberCount = 0, // Default to 0
  });

  factory Community.fromMap(Map<String, dynamic> data, String id) {
    return Community(
      id: id,
      name: data['name'],
      description: data['description'],
      authorId: data['authorId'],
      memberCount: data['memberCount'] ?? 0, // Safely handle null with default value
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'authorId': authorId,
      'memberCount': memberCount, // Include in map for updates
    };
  }
}
