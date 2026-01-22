import 'package:caco_flutter_blog/core/error/exception.dart';
import 'package:caco_flutter_blog/core/error/failure.dart';
import 'package:caco_flutter_blog/core/network/connection_checker.dart';
import 'package:caco_flutter_blog/features/auth/data/datasources/auth_supabase_source.dart';
import 'package:caco_flutter_blog/core/common/entities/user.dart';
import 'package:caco_flutter_blog/features/auth/data/models/user_model.dart';
import 'package:caco_flutter_blog/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/src/either.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class AuthRepositoryImpl implements AuthRepository {
  final AuthSupabaseSource authSupabaseSource;
  final ConnectionChecker connectionChecker;
  const AuthRepositoryImpl(
    this.authSupabaseSource,
    this.connectionChecker,
  );

  @override
  Future<Either<Failure, User>> currentUser() async {
    try {
      if (!await (connectionChecker.isConnected)) {
        final session = authSupabaseSource.currentSession;
          if (session == null) {
            return Left(Failure('No user logged in'));
          }
        return Right(UserModel(
          id: session.user.id,
          email: session.user.email ?? '',
          username: ''
        ));
      }
      final user = await authSupabaseSource.getCurrentUser();
      if (user == null) {
        return Left(Failure('No user logged in'));
      }
      return Right(user);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, User>> loginWithEmailAndPassword({
    required String email, 
    required String password
  }) async {
    return _getUser(
        () async => await authSupabaseSource.loginWithEmailAndPassword(
          email: email, 
          password: password
      ),
    );
  }

  @override
  Future<Either<Failure, User>> signUpWithEmailAndPassword({
    required String username, 
    required String email, 
    required String password
  }) async {
      return _getUser(
        () async => await authSupabaseSource.signUpWithEmailAndPassword(
          username: username, 
          email: email, 
          password: password
      ),
    );
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await authSupabaseSource.signOut();
      return Right(null);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }

  Future<Either<Failure, User>> _getUser(
    Future<User> Function() fn,
  ) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return Left(Failure('You are offline.'));
      }
      final user = await fn();

      return Right(user);
    } on sb.AuthException catch (e) {
      return Left(Failure(e.message));
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }
  
}