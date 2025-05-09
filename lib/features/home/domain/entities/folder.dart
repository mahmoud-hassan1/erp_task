class Folder {
  final String id;
  final String title;
  final String? parentFolderId;
  final String createdBy;
  final DateTime createdAt;
  final Map<String, String> permissions;
  final List<String> path;
  final bool isPublic;

  const Folder({
    required this.id,
    required this.title,
    this.parentFolderId,
    required this.createdBy,
    required this.createdAt,
    required this.permissions,
    required this.path,
    this.isPublic = false,
  });
} 