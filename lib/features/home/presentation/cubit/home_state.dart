import '../../domain/entities/folder.dart';
import '../../domain/entities/document.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<Folder> folders;
  final List<Document> documents;


  HomeLoaded({
    required this.folders,
    required this.documents,
  });
}

class HomeError extends HomeState {
  final String message;

  HomeError(this.message);
} 
class DocumentLoading extends HomeState {}
class DocumentLoaded extends HomeState {
  String message;

  DocumentLoaded(this.message);
}
class DocumentError extends HomeState {
  final String message;

  DocumentError(this.message);
}

class FolderLoading extends HomeState {}
class FolderLoaded extends HomeState {
  String message;

  FolderLoaded(this.message);

}
class FolderError extends HomeState {
  final String message;

  FolderError(this.message);
}
