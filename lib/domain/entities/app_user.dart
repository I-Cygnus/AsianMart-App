class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
  });

  final int id;
  final String email;
  final String name;
  final String phone;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final info = (json['userInfo'] as Map<String, dynamic>? ?? const {});
    return AppUser(
      id: (info['id'] as num?)?.toInt() ?? 0,
      email: info['email'] as String? ?? '',
      name: info['name'] as String? ?? '',
      phone: info['phone'] as String? ?? '',
    );
  }
}
