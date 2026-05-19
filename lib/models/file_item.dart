enum FileKind { folder, img, vid, aud, pdf, zip, code, doc }

FileKind mimeToKind(String? mime, bool isFolder) {
  if (isFolder) return FileKind.folder;
  if (mime == null) return FileKind.doc;
  if (mime.startsWith('image/')) return FileKind.img;
  if (mime.startsWith('video/')) return FileKind.vid;
  if (mime.startsWith('audio/')) return FileKind.aud;
  if (mime == 'application/pdf') return FileKind.pdf;
  if (mime.contains('zip') || mime.contains('tar') || mime.contains('gzip')) return FileKind.zip;
  if (mime.contains('javascript') ||
      mime.contains('typescript') ||
      mime.contains('json') ||
      mime.contains('xml') ||
      mime.contains('html') ||
      mime.contains('css') ||
      mime.contains('python') ||
      mime.contains('yaml')) return FileKind.code;
  return FileKind.doc;
}

class FileItem {
  final String uuid;
  final String name;
  final String path;
  final bool isFolder;
  final String? mimeType;
  final int size;
  final String? parentId;
  final bool isStarred;
  final bool isTrashed;
  final bool hasThumbnail;
  final String createdAt;
  final String? updatedAt;

  const FileItem({
    required this.uuid,
    required this.name,
    required this.path,
    required this.isFolder,
    this.mimeType,
    required this.size,
    this.parentId,
    required this.isStarred,
    required this.isTrashed,
    required this.hasThumbnail,
    required this.createdAt,
    this.updatedAt,
  });

  factory FileItem.fromJson(Map<String, dynamic> j) => FileItem(
        uuid: j['uuid'] as String,
        name: j['name'] as String,
        path: j['path'] as String? ?? '/',
        isFolder: j['is_folder'] as bool? ?? false,
        mimeType: j['mime_type'] as String?,
        size: j['size'] as int? ?? 0,
        parentId: j['parent_id']?.toString(),
        isStarred: j['is_starred'] as bool? ?? false,
        isTrashed: j['is_trashed'] as bool? ?? false,
        hasThumbnail: j['has_thumbnail'] as bool? ?? false,
        createdAt: j['created_at'] as String,
        updatedAt: j['updated_at'] as String?,
      );

  FileKind get kind => mimeToKind(mimeType, isFolder);

  String get ext => name.contains('.') ? name.split('.').last.toUpperCase() : '?';

  DateTime get modifiedAt => DateTime.tryParse(updatedAt ?? createdAt) ?? DateTime.now();

  FileItem copyWith({bool? isStarred}) => FileItem(
        uuid: uuid,
        name: name,
        path: path,
        isFolder: isFolder,
        mimeType: mimeType,
        size: size,
        parentId: parentId,
        isStarred: isStarred ?? this.isStarred,
        isTrashed: isTrashed,
        hasThumbnail: hasThumbnail,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
