import 'package:dartz/dartz.dart';
import 'package:erp_task/features/auth/domain/repositories/auth_repository.dart';
import '../entities/folder.dart';
import '../repositories/home_repository.dart';

class GetFolders {
  final HomeRepository repository;
  final AuthRepository authRepository;
  GetFolders(this.repository, this.authRepository);

  Future<Either<Exception, List<Folder>>> call(String? parentFolderId) async {
    final folders = await repository.getFolders(parentFolderId);
    return folders.fold(
      (error) => Left(error),
      (folders) {
        final currentUser = authRepository.getCurrentUserEmail();
        return currentUser.fold(
          (error) => Left(error),
          (user) {
            final filteredFolders = folders.where((folder) => folder.isPublic || folder.createdBy == user).toList();
            filteredFolders.sort((a, b) => a.title.compareTo(b.title));
            return Right(filteredFolders);
          },
        );
      },
    );
  }
} 