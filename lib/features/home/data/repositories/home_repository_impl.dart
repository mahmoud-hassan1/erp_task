import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entities/folder.dart';
import '../../domain/entities/document.dart';
import '../../domain/repositories/home_repository.dart';
import '../models/folder_model.dart';
import '../models/document_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  HomeRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<Either<Exception, List<Folder>>> getFolders(
      String? parentFolderId) async {
    try {
      final query = _firestore.collection('folders');
      final snapshot = parentFolderId == null
          ? await query.where('parentFolderId', isNull: true).get()
          : await query
              .where('parentFolderId', isEqualTo: parentFolderId)
              .get();

      final folders = snapshot.docs
          .map((doc) => FolderModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      return Right(folders);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, List<Document>>> getDocuments(
      String? parentFolderId) async {
    try {
      final query = _firestore.collection('documents');
      final snapshot = parentFolderId == null
          ? await query.where('parentFolderId', isNull: true).get()
          : await query
              .where('parentFolderId', isEqualTo: parentFolderId)
              .get();

      final documents = snapshot.docs
          .map((doc) => DocumentModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      return Right(documents);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, void>> createFolder(Folder folder) async {
    try {
      final folderModel = FolderModel.fromEntity(folder);

      await _firestore.collection('folders').doc(folder.id).set(
            folderModel.toJson(),
          );
      return const Right(null);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, void>> createDocument(
      Document document, String path, File file) async {
    try {
      final fileName = file.path.split('/').last;
      final fileUrl = await uploadFile(
          path, file.readAsBytesSync(), fileName);
      return fileUrl.fold(
        (error) => Left(error),
        (url) async {
          document.docLink = url;
          document.title = fileName;
          final documentModel = DocumentModel.fromEntity(document);

          await _firestore.collection('documents').add(
                documentModel.toJson(),
              );
          return const Right(null);
        },
      );
    } catch (e) {
      print("Error creating document: $e");
      return Left(Exception(e.toString()));
    }
  }

  // @override
  // Future<Either<Exception, void>> updateFolderPermissions(
  //   String folderId,
  //   Map<String, String> permissions,
  // ) async {
  //   try {
  //     await _firestore.collection('folders').doc(folderId).update({
  //       'permissions': permissions,
  //     });
  //     return const Right(null);
  //   } catch (e) {
  //     return Left(Exception(e.toString()));
  //   }
  // }

  // @override
  // Future<Either<Exception, void>> updateDocumentPermissions(
  //   String documentId,
  //   Map<String, String> permissions,
  // ) async {
  //   try {
  //     await _firestore.collection('documents').doc(documentId).update({
  //       'permissions': permissions,
  //     });
  //     return const Right(null);
  //   } catch (e) {
  //     return Left(Exception(e.toString()));
  //   }
  // }

  @override
  Future<Either<Exception, void>> addComment(
      String documentId, Comment comment) async {
    try {
      final commentData = {
        'userId': comment.userId,
        'text': comment.text,
        'createdAt': Timestamp.fromDate(comment.createdAt),
      };

      await _firestore.collection('documents').doc(documentId).update({
        'comments': FieldValue.arrayUnion([commentData]),
      });
      return const Right(null);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  // @override
  // Future<Either<Exception, void>> addVersion(
  //     String documentId, Version version) async {
  //   try {
  //     final versionData = {
  //       'version': version.version,
  //       'docLink': version.docLink,
  //       'uploadedAt': Timestamp.fromDate(version.uploadedAt),
  //     };

  //     await _firestore.collection('documents').doc(documentId).update({
  //       'versionHistory': FieldValue.arrayUnion([versionData]),
  //       'currentVersion': version.version,
  //     });
  //     return const Right(null);
  //   } catch (e) {
  //     return Left(Exception(e.toString()));
  //   }
  // }

  @override
  Future<Either<Exception, String>> uploadFile(
    String path,
    List<int> bytes,
    String fileName,
  ) async {
    try {
      final ref = _storage.ref().child('$path/$fileName');
      await ref.putData(Uint8List.fromList(bytes));
      final downloadUrl = await ref.getDownloadURL();
      print("downloadUrl: $downloadUrl");
      return Right(downloadUrl);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }
  @override
  Future<Either<Exception, void>> updateFolder(Folder folder) async {
    try {
      await _firestore.collection('folders').doc(folder.id).update(FolderModel.fromEntity(folder).toJson());
      return const Right(null);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }
  @override
  Future<Either<Exception, void>> updateDocument(Document document,String path,File? file) async {
    try {
      if (file != null) {
        final fileName = file.path.split('/').last;
        final fileUrl = await uploadFile(
            path, file.readAsBytesSync(), fileName);
        return fileUrl.fold(
          (error) => Left(error),
          (url) async {
            document.docLink = url;
            document.title = fileName;
            await _firestore.collection('documents').doc(document.id).update(DocumentModel.fromEntity(document).toJson());
            return const Right(null);
          },
        );
      }
      await _firestore.collection('documents').doc(document.id).update(DocumentModel.fromEntity(document).toJson());
      return const Right(null);
    } catch (e) { 
      return Left(Exception(e.toString()));
    }
  }
}


