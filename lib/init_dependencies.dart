import 'package:caco_flutter_blog/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:caco_flutter_blog/core/network/connection_checker.dart';
import 'package:caco_flutter_blog/core/secrets/supabaseEnv.dart';
import 'package:caco_flutter_blog/features/auth/data/datasources/auth_supabase_source.dart';
import 'package:caco_flutter_blog/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:caco_flutter_blog/features/auth/domain/repository/auth_repository.dart';
import 'package:caco_flutter_blog/features/auth/domain/usecases/current_user.dart';
import 'package:caco_flutter_blog/features/auth/domain/usecases/user_logIn.dart';
import 'package:caco_flutter_blog/features/auth/domain/usecases/user_signUp.dart';
import 'package:caco_flutter_blog/features/auth/domain/usecases/user_signOut.dart';
import 'package:caco_flutter_blog/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:caco_flutter_blog/features/blog/data/datasources/blog_supabase_source.dart';
import 'package:caco_flutter_blog/features/blog/data/repositories/blog_repository_impl.dart';
import 'package:caco_flutter_blog/features/blog/domain/repositories/blog_repository.dart';
import 'package:caco_flutter_blog/features/blog/domain/usecases/get_all_blogs.dart';
import 'package:caco_flutter_blog/features/blog/domain/usecases/upload_blog.dart';
import 'package:caco_flutter_blog/features/blog/presentation/bloc/blog_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _initAuth();
  _initBlog();
  final supabase = await Supabase.initialize(
    url: SupabaseEnv.supabaseUrl, 
    anonKey: SupabaseEnv.supabaseKey,
  );
  serviceLocator.registerLazySingleton(() => supabase.client);
  serviceLocator.registerFactory(() => InternetConnection());
  serviceLocator.registerLazySingleton(() => AppUserCubit());
  serviceLocator.registerFactory<ConnectionChecker>(
    () => ConnectionCheckerImpl(
      serviceLocator(),
      ),
    );
}

void _initAuth() {
  serviceLocator
  ..registerFactory<AuthSupabaseSource>(
    () => AuthSupabaseSourceImpl(
      serviceLocator(),
    ),
  )
  ..registerFactory<AuthRepository>(
    () => AuthRepositoryImpl(
      serviceLocator(),
      serviceLocator(),
    ),
  )
  ..registerFactory(
    () => UserSignup(
      serviceLocator(),
    ),
  )
  ..registerFactory(
    () => UserLogin(
      serviceLocator(),
    ),
  )
  ..registerFactory(
    () => CurrentUser(
      serviceLocator(),
    ),
  )
  ..registerFactory(
    () => UserSignOut(
      serviceLocator(),
    )
  )
  ..registerLazySingleton(
    () => AuthBloc(
      userSignUp: serviceLocator(),
      userLogIn: serviceLocator(),
      userSignOut: serviceLocator(),
      currentUser: serviceLocator(),
      appUserCubit: serviceLocator(),
    ),
  );
}

void _initBlog() {
  serviceLocator
  ..registerFactory<BlogSupabaseSource>(
    () => BlogSupabaseSourceImpl(
      serviceLocator(),
    ),
  )
  ..registerFactory<BlogRepository>(
    () => BlogRepositoryImpl(
      serviceLocator(),
    ),
  )
  ..registerFactory(
    () => UploadBlog(
      serviceLocator(),
    )
  )
  ..registerFactory(
    () => GetAllBlogs(
      serviceLocator(),
    )
  )
  ..registerLazySingleton(
    () => BlogBloc(
      uploadBlog: serviceLocator(), 
      getAllBlogs: serviceLocator(),
    ),
  );
}