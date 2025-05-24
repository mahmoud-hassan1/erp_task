import 'package:dartz/dartz.dart';
import 'package:erp_task/core/utils/app_strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:erp_task/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepositoryImpl(this._firebaseAuth);

  @override
  Future<Either<Exception, UserCredential>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (!userCredential.user!.emailVerified) {
        return Left(Exception(AppStrings.pleaseVerifyEmailFirst));
      }
      return Right(userCredential);
    } on FirebaseAuthException catch (e) {
      return Left(Exception(e.message ?? AppStrings.authenticationFailed));
    } catch (e) {
      return Left(Exception(AppStrings.anUnexpectedErrorOccurred));
    }
  }

  @override
  Future<Either<Exception, UserCredential>> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user!.sendEmailVerification();
      await _firebaseAuth.signOut();
      return Right(userCredential);
    } on FirebaseAuthException catch (e) {
      return Left(Exception(e.message ?? AppStrings.registrationFailed));
    } catch (e) {
      return Left(Exception(AppStrings.anUnexpectedErrorOccurred));
    }
  }

  @override
  Future<Either<Exception, void>> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
        return const Right(null);
      }
      return Left(Exception(AppStrings.noUserIsCurrentlySignedIn));
    } catch (e) {
      return Left(Exception(AppStrings.failedToSendVerificationEmail));
    }
  }

  @override
  Future<Either<Exception, void>> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return const Right(null);
    } catch (e) {
      return Left(Exception(AppStrings.failedToSignOut));
    }
  }

  @override
  Either<Exception, User?> getCurrentUser() {
    try {
      return Right(_firebaseAuth.currentUser);
    } catch (e) {
      return Left(Exception(AppStrings.failedToGetCurrentUser));
    }
  }

  @override
  Future<Either<Exception, bool>> isEmailVerified() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.reload();
        return Right(user.emailVerified);
      }
      return Left(Exception(AppStrings.noUserIsCurrentlySignedIn));
    } catch (e) {
      return Left(Exception(AppStrings.failedToCheckEmailVerificationStatus));
    }
  }

  @override
  Either<Exception, String> getCurrentUserEmail() {
    try {
      return Right(_firebaseAuth.currentUser!.email!);
    } catch (e) {
      return Left(Exception(AppStrings.failedToGetCurrentUserEmail));
    }
  }
}
