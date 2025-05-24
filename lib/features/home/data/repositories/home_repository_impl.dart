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
     
      final fileUrl = await uploadFile(
          path, file.readAsBytesSync(), document.title);
      return fileUrl.fold(
        (error) => Left(error),
        (url) async {
          document.docLink = url;
          final documentModel = DocumentModel.fromEntity(document);

          await _firestore.collection('documents').add(
                documentModel.toJson(),
              );
          return const Right(null);
        },
      );
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }



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

        final fileUrl = await uploadFile(
            path, file.readAsBytesSync(), document.title);
        return fileUrl.fold(
          (error) => Left(error),
          (url) async {
            document.docLink = url;
        
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
  @override
  Future<Either<Exception, void>> deleteDocument(Document document) async {
    try {
      // Extract the storage path from the download URL
      final uri = Uri.parse(document.docLink);
      final path = uri.path.split('/o/').last.split('?').first;
      final decodedPath = Uri.decodeFull(path);
      
      // Delete from storage
      await _storage.ref().child(decodedPath).delete();
      
      // Delete from Firestore
      await _firestore.collection('documents').doc(document.id).delete();
      
      return const Right(null);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }
  @override
  Future<Either<Exception, void>> deleteFolder(Folder folder) async {
    try {
      // First, get all subfolders
      final subfoldersQuery = await _firestore
          .collection('folders')
          .where('parentFolderId', isEqualTo: folder.id)
          .get();

      // Recursively delete each subfolder
      for (var subfolderDoc in subfoldersQuery.docs) {
        final subfolder = FolderModel.fromJson({...subfolderDoc.data(), 'id': subfolderDoc.id});
        await deleteFolder(subfolder.toEntity());
      }

      // Get all documents in this folder
      final documentsQuery = await _firestore
          .collection('documents')
          .where('parentFolderId', isEqualTo: folder.id)
          .get();

      // Delete all documents in this folder
      for (var doc in documentsQuery.docs) {
        final document = DocumentModel.fromJson({...doc.data(), 'id': doc.id});
        
        // Delete the document (this will handle both storage and Firestore)
        await deleteDocument(document.toEntity());
      }

      // Finally, delete the folder itself
      await _firestore.collection('folders').doc(folder.id).delete();
      
      return const Right(null);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }
}

