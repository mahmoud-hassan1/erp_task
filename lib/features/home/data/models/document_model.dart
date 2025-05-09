import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/document.dart';

class DocumentModel extends Document {
  const DocumentModel({
    required super.id,
    required super.parentFolderId,
    required super.title,
    required super.tags,
    required super.type,
    required super.docLink,
    required super.createdBy,
    required super.createdAt,
    required super.permissions,
    required super.isPublic,
    required super.comments,
    required super.versionHistory,
    required super.currentVersion,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] as String,
      parentFolderId: json['parentFolderId'] as String,
      title: json['title'] as String,
      tags: List<String>.from(json['tags'] as List),
      type: json['type'] as String,
      docLink: json['docLink'] as String,
      createdBy: json['createdBy'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      permissions: Map<String, String>.from(json['permissions'] as Map),
      isPublic: json['isPublic'] as bool? ?? false,
      comments: (json['comments'] as List?)
          ?.map((e) => Comment(
                userId: e['userId'] as String,
                text: e['text'] as String,
                createdAt: (e['createdAt'] as Timestamp).toDate(),
              ))
          .toList() ??
          [],
      versionHistory: (json['versionHistory'] as List?)
          ?.map((e) => Version(
                version: e['version'] as int,
                docLink: e['docLink'] as String,
                uploadedAt: (e['uploadedAt'] as Timestamp).toDate(),
              ))
          .toList() ??
          [],
      currentVersion: json['currentVersion'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parentFolderId': parentFolderId,
      'title': title,
      'tags': tags,
      'type': type,
      'docLink': docLink,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'permissions': permissions,
      'isPublic': isPublic,
      'comments': comments
          .map((e) => {
                'userId': e.userId,
                'text': e.text,
                'createdAt': Timestamp.fromDate(e.createdAt),
              })
          .toList(),
      'versionHistory': versionHistory
          .map((e) => {
                'version': e.version,
                'docLink': e.docLink,
                'uploadedAt': Timestamp.fromDate(e.uploadedAt),
              })
          .toList(),
      'currentVersion': currentVersion,
    };
  }
} 