import 'package:image_picker/image_picker.dart';

import 'package:caco_flutter_blog/core/error/exception.dart';
import 'package:caco_flutter_blog/features/blog/data/models/comment_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class CommentSupabaseSource {
  Future<CommentModel> addComment(CommentModel comment);
  Future<List<CommentModel>> getCommentsByBlogId(String blogId);
  Future<void> deleteComment(String commentId);
  Future<String> uploadCommentImage({
    required XFile image,
    required String commentId,
  });
}

class CommentSupabaseSourceImpl implements CommentSupabaseSource {
  final SupabaseClient supabaseClient;
  CommentSupabaseSourceImpl(this.supabaseClient);

  @override
  Future<CommentModel> addComment(CommentModel comment) async {
    try {
      final commentData = await supabaseClient
          .from('comments')
          .insert(comment.toJson())
          .select();

      return CommentModel.fromJson(commentData.first);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<CommentModel>> getCommentsByBlogId(String blogId) async {
    try {
      final commentsData = await supabaseClient
          .from('comments')
          .select()
          .eq('post_id', blogId)
          .order('created_at', ascending: false);

      return List<CommentModel>.from(
        (commentsData as List<dynamic>).map<CommentModel>(
          (x) => CommentModel.fromJson(x as Map<String, dynamic>),
        ),
      );
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteComment(String commentId) async {
    try {
      await supabaseClient.from('comments').delete().eq('id', commentId);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> uploadCommentImage({
    required XFile image,
    required String commentId,
  }) async {
    try {
      final imageBytes = await image.readAsBytes();
      if (imageBytes.isEmpty) {
        throw ServerException('Image file is empty');
      }
      
      // Create a unique filename to avoid conflicts and enable upsert
      final filename = 'comment_${commentId}_${DateTime.now().millisecondsSinceEpoch}';

      await supabaseClient.storage
          .from('comment-images')
          .uploadBinary(
            filename,
            imageBytes,
            fileOptions: const FileOptions(upsert: true),
          );

      final publicUrl = supabaseClient.storage
          .from('comment-images')
          .getPublicUrl(filename);

      return publicUrl;
    } on StorageException catch (e) {
      throw ServerException('Storage error: ${e.message}');
    } catch (e) {
      throw ServerException('Image upload failed: ${e.toString()}');
    }
  }
}
