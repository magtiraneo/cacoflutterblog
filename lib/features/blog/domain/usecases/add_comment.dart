import 'package:caco_flutter_blog/core/error/failure.dart';
import 'package:caco_flutter_blog/core/usecase/usecase.dart';
import 'package:caco_flutter_blog/features/blog/domain/entities/comment.dart';
import 'package:caco_flutter_blog/features/blog/domain/repositories/comment_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';

class AddComment implements UseCase<Comment, AddCommentParams> {
  final CommentRepository commentRepository;
  AddComment(this.commentRepository);

  @override
  Future<Either<Failure, Comment>> call(AddCommentParams params) async {
    return await commentRepository.addComment(
      blogId: params.blogId,
      userId: params.userId,
      content: params.content,
      username: params.username,
      image: params.image,
    );
  }
}

class AddCommentParams {
  final String blogId;
  final String userId;
  final String content;
  final String? username;
  final XFile? image;

  AddCommentParams({
    required this.blogId,
    required this.userId,
    required this.content,
    this.username,
    this.image,
  });
}
