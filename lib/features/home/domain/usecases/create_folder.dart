import 'package:dartz/dartz.dart';
import 'package:erp_task/features/auth/domain/repositories/auth_repository.dart';
import '../entities/folder.dart';
import '../repositories/home_repository.dart';

class CreateFolder {
  final HomeRepository repository;
  final AuthRepository authRepository;
  CreateFolder(this.repository, this.authRepository);

  Future<Either<Exception, void>> call(Folder folder) async {
    final currentUser = authRepository.getCurrentUserEmail();
    return await currentUser.fold(
      (error) => Left(error),
      (user) async{
        folder.createdBy = user;
        return await repository.createFolder(folder);
      },
    );
  }
} 