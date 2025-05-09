import 'package:dartz/dartz.dart';
import '../entities/folder.dart';
import '../entities/document.dart';

abstract class HomeRepository {
  Future<Either<Exception, List<Folder>>> getFolders(String? parentFolderId);
  Future<Either<Exception, List<Document>>> getDocuments(String? parentFolderId);
  Future<Either<Exception, void>> createFolder(Folder folder);
  Future<Either<Exception, void>> createDocument(Document document);
  Future<Either<Exception, void>> updateFolderPermissions(String folderId, Map<String, String> permissions);
  Future<Either<Exception, void>> updateDocumentPermissions(String documentId, Map<String, String> permissions);
  Future<Either<Exception, void>> addComment(String documentId, Comment comment);
  Future<Either<Exception, void>> addVersion(String documentId, Version version);
  Future<Either<Exception, String>> uploadFile(String path, List<int> bytes, String fileName);
} 