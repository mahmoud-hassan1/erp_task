import 'package:erp_task/features/auth/domain/repositories/auth_repository.dart';
import 'package:erp_task/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:erp_task/features/home/domain/repositories/home_repository.dart';
import 'package:erp_task/features/home/domain/usecases/get_documents.dart';
import 'package:erp_task/features/home/domain/usecases/get_folders.dart';
import 'package:erp_task/features/home/presentation/cubit/home_cubit.dart';
import 'package:erp_task/features/home/presentation/views/home_view.dart';
import 'package:flutter/material.dart';
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
        builder: (context, state) => MultiBlocProvider(
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
              ),
            ),
          ],
          child: const HomeView(),
        ),
      ),
    ],
  );
}
