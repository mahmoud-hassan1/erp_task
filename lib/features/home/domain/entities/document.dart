class Document {
  final String id;
  final String parentFolderId;
  final String title;
  final List<String> tags;
  final String type;
  final String docLink;
  final String createdBy;
  final DateTime createdAt;
  final Map<String, String> permissions;
  final bool isPublic;
  final List<Comment> comments;
  final List<Version> versionHistory;
  final int currentVersion;

  const Document({
    required this.id,
    required this.parentFolderId,
    required this.title,
    required this.tags,
    required this.type,
    required this.docLink,
    required this.createdBy,
    required this.createdAt,
    required this.permissions,
    required this.isPublic,
    required this.comments,
    required this.versionHistory,
    required this.currentVersion,
  });
}

class Comment {
  final String userId;
  final String text;
  final DateTime createdAt;

  const Comment({
    required this.userId,
    required this.text,
    required this.createdAt,
  });
}

class Version {
  final int version;
  final String docLink;
  final DateTime uploadedAt;

  const Version({
    required this.version,
    required this.docLink,
    required this.uploadedAt,
  });
} 