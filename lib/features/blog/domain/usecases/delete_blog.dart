import 'package:caco_flutter_blog/core/error/failure.dart';
import 'package:caco_flutter_blog/core/usecase/usecase.dart';
import 'package:caco_flutter_blog/features/blog/domain/repositories/blog_repository.dart';
import 'package:fpdart/fpdart.dart';

class DeleteBlog implements UseCase<void, String> {
  final BlogRepository blogRepository;
  DeleteBlog(this.blogRepository);

  @override
  Future<Either<Failure, void>> call(String blogId) {
    return blogRepository.deleteBlog(blogId);
  }

}