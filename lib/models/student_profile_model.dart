class StudentProfile {
  final String name;
  final String email;
  final String studentId;
  final String language;
  final String avatarUrl;
  
  StudentProfile({
    required this.name,
    required this.email,
    required this.studentId,
    required this.language,
    required this.avatarUrl,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      studentId: json['studentId'] ?? '',
      language: json['language'] ?? 'English',
      avatarUrl: json['avatar'] ?? 'https://api.dicebear.com/7.x/avataaars/png?seed=Felix', // Default fallback
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'language': language,
      'avatar': avatarUrl,
    };
  }
}
