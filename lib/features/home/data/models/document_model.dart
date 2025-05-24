import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erp_task/features/home/data/models/permetions_model.dart';
import '../../domain/entities/document.dart';

class DocumentModel extends Document {
   DocumentModel({
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
    required super.currentVersion,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] as String,
      parentFolderId: json['parentFolderId'] as String?,
      title: json['title'] as String,
      tags: List<String>.from(json['tags'] as List),
      type: json['type'] as String,
      docLink: json['docLink'] as String,
      createdBy: json['createdBy'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      isPublic: json['isPublic'] as bool? ?? false,
      comments: (json['comments'] as List?)
          ?.map((e) => Comment(
                userId: e['userId'] as String,
                text: e['text'] as String,
                createdAt: (e['createdAt'] as Timestamp).toDate(),
              ))
          .toList() ??
          [],
      permissions: PermissionsModel.fromJson(json['permissions'] as Map<String, dynamic>),
 
      currentVersion: json['currentVersion'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'parentFolderId': parentFolderId,
      'title': title,
      'tags': tags,
      'type': type,
      'docLink': docLink,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'permissions': PermissionsModel.fromEntity(permissions).toJson(),
      'isPublic': isPublic,
      'comments': comments
          .map((e) => {
                'userId': e.userId,
                'text': e.text,
                'createdAt': Timestamp.fromDate(e.createdAt),
              })
          .toList(),
      'currentVersion': currentVersion,
    };
  }
  factory DocumentModel.fromEntity(Document document) {
    return DocumentModel(
      id: document.id,
      parentFolderId: document.parentFolderId,
      title: document.title,
      tags: document.tags,
      type: document.type,
      docLink: document.docLink,
      createdBy: document.createdBy,
      createdAt: document.createdAt,
      permissions: document.permissions,
      isPublic: document.isPublic,
      comments: document.comments,
      currentVersion: document.currentVersion,
    );
  }

  Document toEntity() {
    return Document(
      id: id,
      parentFolderId: parentFolderId,
      title: title,
      tags: tags,
      type: type,
      docLink: docLink,
      createdBy: createdBy,
      createdAt: createdAt,
      permissions: permissions,
      isPublic: isPublic,
      comments: comments,
      currentVersion: currentVersion,
    );
  }
} 