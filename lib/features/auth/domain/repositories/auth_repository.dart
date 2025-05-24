import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Future<Either<Exception, UserCredential>> signInWithEmailAndPassword(
    String email,
    String password,
  );
  
  Future<Either<Exception, UserCredential>> signUpWithEmailAndPassword(
    String email,
    String password,
  );
  
  Future<Either<Exception, void>> sendEmailVerification();
  
  Future<Either<Exception, void>> signOut();
  
  Either<Exception, User?> getCurrentUser();
  
  Future<Either<Exception, bool>> isEmailVerified();
  Either<Exception, String> getCurrentUserEmail();
}   