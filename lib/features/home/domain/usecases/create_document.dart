import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:erp_task/features/auth/domain/repositories/auth_repository.dart';
import 'package:erp_task/features/home/domain/entities/document.dart';
import 'package:erp_task/features/home/domain/repositories/home_repository.dart';

class CreateDocument {
  final HomeRepository repository;
  final AuthRepository authRepository;
  CreateDocument(this.repository, this.authRepository);

  Future<Either<Exception, void>> call(Document document, String path, File file) async {
    final currentUser = authRepository.getCurrentUserEmail();
    return await currentUser.fold(
      (error) => Left(error),
      (user) async{
        document.createdBy = user;
        return await repository.createDocument(document, path, file);
      },
    );
  }
} 