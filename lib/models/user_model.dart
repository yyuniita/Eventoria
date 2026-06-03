enum UserRole { user, organizer }

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? token;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.token,
  });

  bool get isOrganizer => role == UserRole.organizer;
  bool get isUser => role == UserRole.user;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] == 'organizer' ? UserRole.organizer : UserRole.user,
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role == UserRole.organizer ? 'organizer' : 'user',
        'token': token,
      };
}