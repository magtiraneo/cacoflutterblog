import 'package:caco_flutter_blog/core/error/exception.dart';
import 'package:caco_flutter_blog/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AuthSupabaseSource {
  Session? get currentSession;
  Future<UserModel> signUpWithEmailAndPassword({
    required String username,
    required String email,
    required String password,
  });
  Future<UserModel> loginWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<UserModel?> signOut();
  Future<UserModel?> getCurrentUser();
}

class AuthSupabaseSourceImpl implements AuthSupabaseSource {
  final SupabaseClient supabaseClient;
  AuthSupabaseSourceImpl(this.supabaseClient);

  @override
  Session? get currentSession => supabaseClient.auth.currentSession;

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String username,
    required String email,
    required String password,
  }) async { 
    try {
      final response = await supabaseClient.auth.signUp(
        password: password, 
        email: email, 
        data: {
          'username': username,
        }
      );
      if (response.user == null) {
        throw const ServerException('Failed to sign up user');
      }
      return UserModel.fromJson(response.user!.toJson());
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
  @override
  Future<UserModel> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async { 
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        password: password, 
        email: email, 
      );
      if (response.user == null) {
        throw const ServerException('User does not exist!');
      }
      return UserModel.fromJson(response.user!.toJson());
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
  @override
  Future<UserModel?> signOut() async {
    await supabaseClient.auth.signOut();
    return null;
  }
  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      if (currentSession != null) {
        final userData = await supabaseClient.from('profiles').select().eq(
        'id', 
        currentSession!.user.id
        );
        return UserModel.fromJson(userData.first).copyWith(
          email: currentSession!.user.email,
        );
      }
      return null;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}   