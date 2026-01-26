import 'package:caco_flutter_blog/core/error/exception.dart';
import 'package:caco_flutter_blog/core/error/failure.dart';
import 'package:caco_flutter_blog/core/network/connection_checker.dart';
import 'package:caco_flutter_blog/features/blog/data/datasources/comment_supabase_source.dart';
import 'package:caco_flutter_blog/features/blog/data/models/comment_model.dart';
import 'package:caco_flutter_blog/features/blog/domain/entities/comment.dart';
import 'package:caco_flutter_blog/features/blog/domain/repositories/comment_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class CommentRepositoryImpl implements CommentRepository {
  final CommentSupabaseSource commentSupabaseSource;
  final ConnectionChecker connectionChecker;
  CommentRepositoryImpl(this.commentSupabaseSource, this.connectionChecker);

  @override
  Future<Either<Failure, Comment>> addComment({
    required String blogId,
    required String userId,
    required String content,
    String? username,
    XFile? image,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(
          Failure('No internet connection'),
        );
      }

      final commentId = const Uuid().v1();
      String? imageUrl;

      // Upload image if provided
      if (image != null) {
        imageUrl =
            await commentSupabaseSource.uploadCommentImage(
          image: image,
          commentId: commentId,
        );
      }

      final comment = CommentModel(
        id: commentId,
        blogId: blogId,
        userId: userId,
        content: content,
        createdAt: DateTime.now(),
        username: username,
        imageUrl: imageUrl,
      );

      final result = await commentSupabaseSource.addComment(comment);
      return right(result);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Comment>>> getCommentsByBlogId(
      String blogId) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(
          Failure('No internet connection'),
        );
      }

      final comments =
          await commentSupabaseSource.getCommentsByBlogId(blogId);
      return right(comments);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteComment(String commentId) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(
          Failure('No internet connection'),
        );
      }

      await commentSupabaseSource.deleteComment(commentId);
      return right(null);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
