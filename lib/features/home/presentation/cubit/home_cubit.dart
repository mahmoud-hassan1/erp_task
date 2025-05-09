import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/folder.dart';
import '../../domain/entities/document.dart';
import '../../domain/repositories/home_repository.dart';
import '../../domain/usecases/get_folders.dart';
import '../../domain/usecases/get_documents.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetFolders getFolders;
  final GetDocuments getDocuments;
  final HomeRepository repository;

  HomeCubit({
    required this.getFolders,
    required this.getDocuments,
    required this.repository,
  }) : super(HomeInitial());

  Future<void> loadContent(String? parentFolderId) async {
    emit(HomeLoading());

    final foldersResult = await getFolders(parentFolderId);
    final documentsResult = await getDocuments(parentFolderId);

    foldersResult.fold(
      (error) => emit(HomeError(error.toString())),
      (folders) {
        documentsResult.fold(
          (error) => emit(HomeError(error.toString())),
          (documents) => emit(HomeLoaded(
            folders: folders,
            documents: documents,
          )),
        );
      },
    );
  }

  void navigateToFolder(Folder folder) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      final newPath = [...currentState.currentPath, folder.title];
      emit(HomeLoaded(
        folders: currentState.folders,
        documents: currentState.documents,
        currentPath: newPath,
      ));
      loadContent(folder.id);
    }
  }

  void navigateBack() {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      if (currentState.currentPath.length > 1) {
        final newPath = currentState.currentPath.sublist(0, currentState.currentPath.length - 1);
        emit(HomeLoaded(
          folders: currentState.folders,
          documents: currentState.documents,
          currentPath: newPath,
        ));
        loadContent(null); // Load root content
      }
    }
  }

  Future<void> createFolder(Folder folder) async {
    emit(HomeLoading());

    final result = await repository.createFolder(folder);
    result.fold(
      (error) => emit(HomeError(error.toString())),
      (_) => loadContent(folder.parentFolderId),
    );
  }

  Future<void> createDocument(Document document) async {
    emit(HomeLoading());

    final result = await repository.createDocument(document);
    result.fold(
      (error) => emit(HomeError(error.toString())),
      (_) => loadContent(document.parentFolderId),
    );
  }

  Future<void> updateFolderPermissions(String folderId, Map<String, String> permissions) async {
    emit(HomeLoading());

    final result = await repository.updateFolderPermissions(folderId, permissions);
    result.fold(
      (error) => emit(HomeError(error.toString())),
      (_) {
        if (state is HomeLoaded) {
          final currentState = state as HomeLoaded;
          loadContent(currentState.currentPath.length > 1 ? currentState.currentPath.last : null);
        }
      },
    );
  }

  Future<void> updateDocumentPermissions(String documentId, Map<String, String> permissions) async {
    emit(HomeLoading());

    final result = await repository.updateDocumentPermissions(documentId, permissions);
    result.fold(
      (error) => emit(HomeError(error.toString())),
      (_) {
        if (state is HomeLoaded) {
          final currentState = state as HomeLoaded;
          loadContent(currentState.currentPath.length > 1 ? currentState.currentPath.last : null);
        }
      },
    );
  }

  Future<void> addComment(String documentId, Comment comment) async {
    emit(HomeLoading());

    final result = await repository.addComment(documentId, comment);
    result.fold(
      (error) => emit(HomeError(error.toString())),
      (_) {
        if (state is HomeLoaded) {
          final currentState = state as HomeLoaded;
          loadContent(currentState.currentPath.length > 1 ? currentState.currentPath.last : null);
        }
      },
    );
  }

  Future<void> addVersion(String documentId, Version version) async {
    emit(HomeLoading());

    final result = await repository.addVersion(documentId, version);
    result.fold(
      (error) => emit(HomeError(error.toString())),
      (_) {
        if (state is HomeLoaded) {
          final currentState = state as HomeLoaded;
          loadContent(currentState.currentPath.length > 1 ? currentState.currentPath.last : null);
        }
      },
    );
  }
} 