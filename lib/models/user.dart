class UserProfile {
  final String id;
  final String name;
  final String profileImage;
  final DateTime joinedDate;
  final List<String> friends;

  UserProfile({
    required this.id,
    required this.name,
    required this.profileImage,
    required this.joinedDate,
    required this.friends,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      name: map['name'],
      profileImage: map['profileImage'] ?? 'https://via.placeholder.com/150',
      joinedDate: DateTime.parse(map['joinedDate']),
      friends: List<String>.from(map['friends']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'profileImage': profileImage,
      'joinedDate': joinedDate.toIso8601String(),
      'friends': friends,
    };
  }
}
