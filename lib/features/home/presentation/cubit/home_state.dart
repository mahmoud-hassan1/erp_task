import '../../domain/entities/folder.dart';
import '../../domain/entities/document.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<Folder> folders;
  final List<Document> documents;
  final List<String> currentPath;

  HomeLoaded({
    required this.folders,
    required this.documents,
    this.currentPath = const ['/Document Manager'],
  });
}

class HomeError extends HomeState {
  final String message;

  HomeError(this.message);
} 