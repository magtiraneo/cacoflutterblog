import 'package:caco_flutter_blog/core/error/failure.dart';
import 'package:caco_flutter_blog/core/usecase/usecase.dart';
import 'package:caco_flutter_blog/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class UserSignOut implements UseCase<void, NoParams> {
  final AuthRepository authRepository;
  UserSignOut(this.authRepository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return authRepository.signOut();
  }
}