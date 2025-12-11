class UserModel {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final bool isOnline;
  final DateTime? lastSeen;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.isOnline = false,
    this.lastSeen,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      avatarUrl: data['avatarUrl'],
      isOnline: data['isOnline'] ?? false,
      lastSeen: data['lastSeen'] != null 
        ? DateTime.parse(data['lastSeen']) 
        : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'isOnline': isOnline,
      'lastSeen': lastSeen?.toIso8601String(),
    };
  }
}