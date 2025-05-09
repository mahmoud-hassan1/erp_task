import 'package:erp_task/core/utils/app_strings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erp_task/features/auth/domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(AuthInitial());

  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());
    final result = await _authRepository.signInWithEmailAndPassword(email, password);
    result.fold(
      (error) { 
        if (cleanErrorMessage(error) == AppStrings.pleaseVerifyEmailFirst) {
          emit(AuthUnverified(null));
        } else {
          emit(AuthError(error.toString()));
        }
      
      },
      (user) => emit(AuthAuthenticated(user.user!)),
    );
  }

  Future<void> signUp(String email, String password) async {
    emit(AuthLoading());
    final result = await _authRepository.signUpWithEmailAndPassword(email, password);
    result.fold(
      (error) => emit(AuthError(error.toString())),
      (user) => emit(AuthUnverified(user.user!)),
    );
  }

  Future<void> signOut() async {
    emit(AuthLoading());
    final result = await _authRepository.signOut();
    result.fold(
      (error) => emit(AuthError(error.toString())),
      (_) => emit(AuthUnauthenticated()),
    );
  }

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    final result = await _authRepository.getCurrentUser();
    result.fold(
      (error) => emit(AuthError(error.toString())),
      (user) {
        if (user == null) {
          emit(AuthUnauthenticated());
        } else {
          _authRepository.isEmailVerified().then((verificationResult) {
            verificationResult.fold(
              (error) => emit(AuthError(error.toString())),
              (isVerified) {
                if (isVerified) {
                  emit(AuthAuthenticated(user));
                } else {
                  emit(AuthUnverified(user));
                }
              },
            );
          });
        }
      },
    );
  }

  Future<void> resendVerificationEmail() async {
    emit(AuthLoading());
    final result = await _authRepository.sendEmailVerification();
    result.fold(
      (error) => emit(AuthError(error.toString())),
      (_) async {
        final userResult = await _authRepository.getCurrentUser();
        userResult.fold(
          (error) => emit(AuthError(error.toString())),
          (user) {
            if (user != null) {
              emit(AuthUnverified(user));
            } else {
              emit(AuthUnauthenticated());
            }
          },
        );
      },
    );
  }

  String? getCurrentUserEmail()  {
    final result =  _authRepository.getCurrentUserEmail();
    result.fold(
      (error) {
        emit(GetEmailError(error.toString()));
        return null;
      },
      (email) {
        return email;
      },
    );
  }
  String cleanErrorMessage(Object error) {
    final str = error.toString();
    // Remove 'Exception: ' if it exists
    return str.startsWith('Exception: ')
        ? str.replaceFirst('Exception: ', '')
        : str;
  }
} 