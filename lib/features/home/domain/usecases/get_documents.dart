import 'package:dartz/dartz.dart';
import '../entities/document.dart';
import '../repositories/home_repository.dart';

class GetDocuments {
  final HomeRepository repository;

  GetDocuments(this.repository);

  Future<Either<Exception, List<Document>>> call(String? parentFolderId) async {
    return await repository.getDocuments(parentFolderId);
  }
} 