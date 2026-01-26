import 'package:caco_flutter_blog/features/blog/domain/entities/comment.dart';
import 'package:caco_flutter_blog/features/blog/domain/usecases/add_comment.dart';
import 'package:caco_flutter_blog/features/blog/domain/usecases/delete_comment.dart';
import 'package:caco_flutter_blog/features/blog/domain/usecases/get_comments.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

part 'comment_event.dart';
part 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final GetComments _getComments;
  final AddComment _addComment;
  final DeleteComment _deleteComment;

  CommentBloc({
    required GetComments getComments,
    required AddComment addComment,
    required DeleteComment deleteComment,
  })  : _getComments = getComments,
        _addComment = addComment,
        _deleteComment = deleteComment,
        super(CommentInitial()) {
    on<CommentFetch>(_onFetchComments);
    on<CommentAdd>(_onAddComment);
    on<CommentDeleteEvent>(_onDeleteComment);
  }

  Future<void> _onFetchComments(
    CommentFetch event,
    Emitter<CommentState> emit,
  ) async {
    emit(CommentLoading());
    final res = await _getComments(GetCommentsParams(blogId: event.blogId));
    res.fold(
      (failure) => emit(CommentFailure(failure.message)),
      (comments) => emit(CommentLoaded(comments)),
    );
  }

  Future<void> _onAddComment(
    CommentAdd event,
    Emitter<CommentState> emit,
  ) async {
    emit(CommentLoading());
    final res = await _addComment(
      AddCommentParams(
        blogId: event.blogId,
        userId: event.userId,
        content: event.content,
        username: event.username,
        image: event.image,
      ),
    );
    res.fold(
      (failure) => emit(CommentFailure(failure.message)),
      (comment) => emit(CommentAdded(comment)),
    );
  }

  Future<void> _onDeleteComment(
    CommentDeleteEvent event,
    Emitter<CommentState> emit,
  ) async {
    emit(CommentLoading());
    final res = await _deleteComment(
      DeleteCommentParams(commentId: event.commentId),
    );
    res.fold(
      (failure) => emit(CommentFailure(failure.message)),
      (_) => emit(CommentDeleted()),
    );
  }
}
