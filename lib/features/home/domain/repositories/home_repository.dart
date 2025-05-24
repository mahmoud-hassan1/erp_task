import 'dart:io';

import 'package:dartz/dartz.dart';
import '../entities/folder.dart';
import '../entities/document.dart';

abstract class HomeRepository {
  Future<Either<Exception, List<Folder>>> getFolders(String? parentFolderId);
  Future<Either<Exception, List<Document>>> getDocuments(String? parentFolderId);
  Future<Either<Exception, void>> createFolder(Folder folder);
  Future<Either<Exception, void>> createDocument(Document document, String path,File file);
  Future<Either<Exception, void>> updateFolder(Folder folder);
  Future<Either<Exception, String>> uploadFile(String path, List<int> bytes, String fileName);
  Future<Either<Exception, void>> updateDocument(Document document,String path,File? file);
  Future<Either<Exception, void>> deleteDocument(Document document);
  Future<Either<Exception, void>> deleteFolder(Folder folder);
} 