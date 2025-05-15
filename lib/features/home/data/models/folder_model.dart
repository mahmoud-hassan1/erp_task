import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/folder.dart';

class FolderModel extends Folder {
   FolderModel({
    required super.id,
    required super.title,
    super.parentFolderId,
    required super.createdBy,
    required super.createdAt,
    required super.permissions,
    super.isPublic = false,
  });

  factory FolderModel.fromJson(Map<String, dynamic> json) {
    return FolderModel(
      id: json['id'] as String,
      title: json['title'] as String,
      parentFolderId: json['parentFolderId'] as String?,
      createdBy: json['createdBy'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      permissions: Map<String, String>.from(json['permissions'] as Map),
      isPublic: json['isPublic'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'parentFolderId': parentFolderId,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'permissions': permissions,
      'isPublic': isPublic,
    };
  }
} 