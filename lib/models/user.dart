class User {
  final String uuid;
  final String email;
  final String username;
  final String? fullName;
  final bool isAdmin;
  final int storageQuota;
  final int storageUsed;

  const User({
    required this.uuid,
    required this.email,
    required this.username,
    this.fullName,
    required this.isAdmin,
    required this.storageQuota,
    required this.storageUsed,
  });

  factory User.fromJson(Map<String, dynamic> j) => User(
        uuid: j['uuid'] as String,
        email: j['email'] as String,
        username: j['username'] as String,
        fullName: j['full_name'] as String?,
        isAdmin: j['is_admin'] as bool? ?? false,
        storageQuota: j['storage_quota'] as int? ?? 0,
        storageUsed: j['storage_used'] as int? ?? 0,
      );

  String get displayName {
    if (fullName != null && fullName!.isNotEmpty) {
      return fullName!.split(' ').first;
    }
    return username;
  }
}
