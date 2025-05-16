import 'package:erp_task/features/auth/domain/repositories/auth_repository.dart';
import 'package:erp_task/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:erp_task/features/home/domain/entities/document.dart';
import 'package:erp_task/features/home/domain/repositories/home_repository.dart';
import 'package:erp_task/features/home/domain/usecases/create_document.dart';
import 'package:erp_task/features/home/domain/usecases/create_folder.dart';
import 'package:erp_task/features/home/domain/usecases/get_documents.dart';
import 'package:erp_task/features/home/domain/usecases/get_folders.dart';
import 'package:erp_task/features/home/presentation/cubit/home_cubit.dart';
import 'package:erp_task/features/home/presentation/views/add_document_view.dart';
import 'package:erp_task/features/home/presentation/views/edit_document_view.dart';
import 'package:erp_task/features/home/presentation/views/home_view.dart';
import 'package:erp_task/features/auth/presentation/views/login_view.dart';
import 'package:erp_task/features/auth/presentation/views/signup_view.dart';
import 'package:erp_task/features/auth/presentation/views/email_verification_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';

class AppRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String verifyEmail = '/verify-email';
  static const String home = '/home';
  static const String addDocument = '/add-document';
  static const String editDocument = '/edit-document';
  static final GoRouter router = GoRouter(
    initialLocation: login,
    routes: [
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => BlocProvider(
          create: (context) => AuthCubit(GetIt.instance.get<AuthRepository>())
            ..checkAuthStatus(),
          child: const LoginView(),
        ),
      ),
      GoRoute(
        path: signup,
        name: 'signup',
        builder: (context, state) => BlocProvider(
          create: (context) => AuthCubit(GetIt.instance.get<AuthRepository>()),
          child: const SignUpView(),
        ),
      ),
      GoRoute(
        path: verifyEmail,
        name: 'verify-email',
        builder: (context, state) => BlocProvider(
          create: (context) => AuthCubit(GetIt.instance.get<AuthRepository>()),
          child: const EmailVerificationView(),
        ),
      ),
      GoRoute(
          path: home,
          name: 'home',
          builder: (context, state) {
            final extras = state.extra as List<dynamic>?;
            final String path = extras?[1] ?? 'Document-Manager';
            final parentFolderId = extras?[0];
            return MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) =>
                      AuthCubit(GetIt.instance.get<AuthRepository>()),
                ),
                BlocProvider(
                  create: (context) => HomeCubit(
                    getFolders: GetIt.instance.get<GetFolders>(),
                    getDocuments: GetIt.instance.get<GetDocuments>(),
                    repository: GetIt.instance.get<HomeRepository>(),
                    createFolder: GetIt.instance.get<CreateFolder>(),
                    createDocument: GetIt.instance.get<CreateDocument>(),
                  )..loadContent(parentFolderId),
                ),
              ],
              child: HomeView(path: path, parentFolderId: parentFolderId),
            );
          }),
      GoRoute(
        path: addDocument,
        name: 'add-document',
        builder: (context, state) {
          final extras = state.extra as List<dynamic>?;
          final parentFolderId = extras?[0] as String?;
          final path = extras?[1] as String;
          final cubit = extras?[2] as HomeCubit;
          return BlocProvider.value(
            value: cubit,
            child: AddDocumentView(parentFolderId: parentFolderId, path: path),
          );
        },
      ),
      GoRoute(
        path: editDocument,
        name: 'edit-document',
        builder: (context, state) {
          final extras = state.extra as List<dynamic>?;
          final document = extras?[0] as Document;
          final parentFolderId = extras?[1] as String?;
          final path = extras?[2] as String;
          final cubit = extras?[3] as HomeCubit;
          return BlocProvider.value(
            value: cubit,
            child: EditDocumentView(document: document, parentFolderId: parentFolderId, path: path),
          );
        },
      ),
    ],
  );
}
