class Community {
  final String id;
  final String name;
  final String description;
  final String authorId;

  Community({required this.id, required this.name, required this.description,required this.authorId});

  factory Community.fromMap(Map<String, dynamic> data, String id) {
    return Community(
      id: id, // Use the 'id' passed directly, not from 'data'
      name: data['name'],
      description: data['description'],
      authorId: data['authorId']
    );
  }

  Map<String, dynamic> toMap() {
    return {
      // 'id' is typically not included here since it's used as the document ID in Firestore
      'name': name,
      'description': description,
    };
  }
}
