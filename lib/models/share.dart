class Share {
  final String uuid;
  final String publicLink;
  final String fileName;
  final bool isFolder;
  final bool hasPassword;
  final String? expiresAt;
  final int downloadCount;
  final bool isActive;
  final String createdAt;

  const Share({
    required this.uuid,
    required this.publicLink,
    required this.fileName,
    required this.isFolder,
    required this.hasPassword,
    this.expiresAt,
    required this.downloadCount,
    required this.isActive,
    required this.createdAt,
  });

  factory Share.fromJson(Map<String, dynamic> j) => Share(
        uuid: j['uuid'] as String,
        publicLink: j['public_link'] as String,
        fileName: j['file_name'] as String,
        isFolder: j['is_folder'] as bool? ?? false,
        hasPassword: j['has_password'] as bool? ?? false,
        expiresAt: j['expires_at'] as String?,
        downloadCount: j['download_count'] as int? ?? 0,
        isActive: j['is_active'] as bool? ?? true,
        createdAt: j['created_at'] as String,
      );

  ({String text, String cls}) get expiryInfo {
    if (!isActive) return (text: 'inactivo', cls: 'err');
    if (expiresAt != null) {
      final exp = DateTime.tryParse(expiresAt!);
      if (exp != null && exp.isBefore(DateTime.now())) return (text: 'expirado', cls: 'err');
      if (exp != null) {
        final days = exp.difference(DateTime.now()).inDays;
        return (text: 'en $days días', cls: 'ok');
      }
    }
    return (text: 'permanente', cls: 'info');
  }
}
