import 'package:dartz/dartz.dart';
import '../entities/folder.dart';
import '../repositories/home_repository.dart';

class GetFolders {
  final HomeRepository repository;

  GetFolders(this.repository);

  Future<Either<Exception, List<Folder>>> call(String? parentFolderId) async {
    return await repository.getFolders(parentFolderId);
  }
} 