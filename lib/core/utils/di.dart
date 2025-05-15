import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erp_task/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:erp_task/features/auth/domain/repositories/auth_repository.dart';
import 'package:erp_task/features/home/data/repositories/home_repository_impl.dart';
import 'package:erp_task/features/home/domain/repositories/home_repository.dart';
import 'package:erp_task/features/home/domain/usecases/create_document.dart';
import 'package:erp_task/features/home/domain/usecases/create_folder.dart';
import 'package:erp_task/features/home/domain/usecases/get_documents.dart';
import 'package:erp_task/features/home/domain/usecases/get_folders.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';

Future<void> setup() async {
  final getIt = GetIt.instance;
  
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<FirebaseAuth>()),
  );
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );
  getIt.registerLazySingleton<FirebaseStorage>(
    () => FirebaseStorage.instance,
  );
  getIt.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(
      firestore: getIt<FirebaseFirestore>(),
      storage: getIt<FirebaseStorage>(),
    ),
  );
  getIt.registerLazySingleton<GetFolders>(
    () => GetFolders(getIt<HomeRepository>(), getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<GetDocuments>(
    () => GetDocuments(getIt<HomeRepository>(), getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<CreateFolder>(
    () => CreateFolder(getIt<HomeRepository>(), getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<CreateDocument>(
    () => CreateDocument(getIt<HomeRepository>(), getIt<AuthRepository>()),
  );
}