import 'dart:io';

import 'package:erp_task/features/home/domain/usecases/create_document.dart';
import 'package:erp_task/features/home/domain/usecases/create_folder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/folder.dart';
import '../../domain/entities/document.dart';
import '../../domain/repositories/home_repository.dart';
import '../../domain/usecases/get_folders.dart';
import '../../domain/usecases/get_documents.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetFolders _getFolders;
  final GetDocuments _getDocuments;
  final HomeRepository _repository;
  final CreateFolder _createFolder;
  final CreateDocument _createDocument;

  HomeCubit({
    required GetFolders getFolders,
    required GetDocuments getDocuments,
    required HomeRepository repository,
    required CreateFolder createFolder,
    required CreateDocument createDocument,
  })  : _getFolders = getFolders,
        _getDocuments = getDocuments,
        _repository = repository,
        _createFolder = createFolder,
        _createDocument = createDocument,
        super(HomeInitial());

  List<Folder> foldersList = [];
  List<Document> documentsList = [];

  Future<void> loadContent(String? parentFolderId) async {
    emit(HomeLoading());

    final foldersResult = await _getFolders(parentFolderId);
    final documentsResult = await _getDocuments(parentFolderId);

    foldersResult.fold(
      (error) => emit(HomeError(error.toString())),
      (folders) {
        documentsResult.fold(
          (error) => emit(HomeError(error.toString())),
          (documents) {
            foldersList = folders;
            documentsList = documents;
            emit(HomeLoaded(
              folders: folders,
              documents: documents,
            ));

          },
        );
      },
    );
  }


  Future<void> createNewFolder(Folder folder) async {
    emit(FolderLoading());
    final result = await _createFolder(folder);
    result.fold(
      (error) => emit(FolderError(error.toString())),
      (_) { 
        emit(FolderLoaded(folder));
        loadContent(folder.parentFolderId);
      },
    );
  }

  Future<void> createDocument(Document document, String path, File file) async {
    emit(DocumentLoading());
    final result = await _createDocument(document, path, file);
    result.fold(
      (error) => emit(DocumentError(error.toString())),
      (_) {

        emit(DocumentLoaded(document));
        loadContent(document.parentFolderId);
      },
    );
  }

  Future<void> updateDocument(Document document,String path,File? file) async {
    emit(DocumentLoading());
    final result = await _repository.updateDocument(document,path,file);
    result.fold(
      (error) => emit(DocumentError(error.toString())),
      (_) {
        emit(DocumentLoaded(document));
        loadContent(document.parentFolderId);
      },
    );
  }

  // void test() {
  //   emit(HomeLoaded(
  //     folders: foldersList,
  //     documents: documentsList,
  //   ));
  // }

  // Future<void> updateFolderPermissions(String folderId, Map<String, String> permissions) async {
  //   emit(HomeLoading());

  //   final result = await repository.updateFolderPermissions(folderId, permissions);
  //   result.fold(
  //     (error) => emit(HomeError(error.toString())),
  //     (_) {
  //       if (state is HomeLoaded) {
  //         final currentState = state as HomeLoaded;
  //         loadContent(currentState.folders.length > 1 ? currentState.folders.last.id : null);
  //       }
  //     },
  //   );
  // }

  // Future<void> updateDocumentPermissions(String documentId, Map<String, String> permissions) async {
  //   emit(HomeLoading());

  //   final result = await repository.updateDocumentPermissions(documentId, permissions);
  //   result.fold(
  //     (error) => emit(HomeError(error.toString())),
  //     (_) {
  //       if (state is HomeLoaded) {
  //         final currentState = state as HomeLoaded;
  //         loadContent(currentState.folders.length > 1 ? currentState.folders.last.id : null);
  //       }
  //     },
  //   );
  // }

  Future<void> addComment(String documentId, Comment comment) async {
    emit(HomeLoading());

    final result = await _repository.addComment(documentId, comment);
    result.fold(
      (error) => emit(HomeError(error.toString())),
      (_) {
        if (state is HomeLoaded) {
          final currentState = state as HomeLoaded;
          loadContent(currentState.folders.length > 1 ? currentState.folders.last.id : null);
        }
      },
    );
  }

Future<void> updateFolder(Folder folder) async {
  emit(FolderLoading());
  final result = await _repository.updateFolder(folder);
  result.fold(
    (error) => emit(FolderError(error.toString())),
    (_) {
      emit(FolderLoaded(folder));
      loadContent(folder.parentFolderId);
    }
  );
}
  // Future<void> addVersion(String documentId, Version version) async {
  //   emit(HomeLoading());

  //   final result = await _repository.addVersion(documentId, version);
  //   result.fold(
  //     (error) => emit(HomeError(error.toString())),
  //     (_) {
  //       if (state is HomeLoaded) {
  //         final currentState = state as HomeLoaded;
  //         loadContent(currentState.folders.length > 1 ? currentState.folders.last.id : null);
  //       }
  //     },
  //   );
  // }
} 