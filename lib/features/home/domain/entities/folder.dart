class Folder {
  final String id;
  final String title;
  final String? parentFolderId;
   String createdBy;
  final DateTime createdAt;
  final Map<String, String> permissions;

  final bool isPublic;
   Folder({
    required this.id,
    required this.title,
    this.parentFolderId,
    required this.createdBy,
    required this.createdAt,
    required this.permissions,
   
    this.isPublic = false,
  });
} 