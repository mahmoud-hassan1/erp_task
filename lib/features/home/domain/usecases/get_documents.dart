import 'package:dartz/dartz.dart';
import 'package:erp_task/features/auth/domain/repositories/auth_repository.dart';
import '../entities/document.dart';
import '../repositories/home_repository.dart';

class GetDocuments {
  final HomeRepository repository;
  final AuthRepository authRepository;
  GetDocuments(this.repository, this.authRepository);

  Future<Either<Exception, List<Document>>> call(String? parentFolderId) async {
    final documents = await repository.getDocuments(parentFolderId);
    return documents.fold(
      (error) => Left(error),
      (documents) {
        final currentUser = authRepository.getCurrentUserEmail();
       return currentUser.fold(
          (error) => Left(error),
          (user) {
            final filteredDocuments = documents.where((doc) => doc.isPublic || doc.createdBy == user).toList();
            filteredDocuments.sort((a, b) => a.title.compareTo(b.title));
            return Right(filteredDocuments);
          },
        );
      },
    );
  }
} 