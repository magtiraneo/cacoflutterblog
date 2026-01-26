import 'package:image_picker/image_picker.dart';

import 'package:caco_flutter_blog/core/error/exception.dart';
import 'package:caco_flutter_blog/features/blog/data/models/blog_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class BlogSupabaseSource {
  Future<BlogModel> uploadBlog(BlogModel blog);
  Future<BlogModel> updateBlog(BlogModel blog);
  Future<String> uploadBlogImage({
    required XFile image,
    required BlogModel blog,
  });
  Future<List<BlogModel>> getAllBlogs();
  Future<void> deleteBlog(String blogId);
}

class BlogSupabaseSourceImpl implements BlogSupabaseSource {
  final SupabaseClient supabaseClient;
  BlogSupabaseSourceImpl(this.supabaseClient);

  @override
  Future<BlogModel> uploadBlog(BlogModel blog) async {
    try {
      // Use authenticated user's ID from session instead of passed user_id
      final authenticatedUserId = supabaseClient.auth.currentSession?.user.id;
      if (authenticatedUserId == null) {
        throw ServerException('No authenticated user found');
      }
      
      // Create blog data with authenticated user's ID
      final blogData = <String, dynamic>{
        'id': blog.id,
        'user_id': authenticatedUserId,
        'created_at': blog.created_at.toIso8601String(),
        'title': blog.title,
        'content': blog.content,
        'image_url': blog.image_url,
      };
      
      final response = 
        await supabaseClient.from('posts').insert(blogData).select();
      
      return BlogModel.fromJson(response.first);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<BlogModel> updateBlog(BlogModel blog) async {
    try {
      // Use authenticated user's ID from session instead of passed user_id
      final authenticatedUserId = supabaseClient.auth.currentSession?.user.id;
      if (authenticatedUserId == null) {
        throw ServerException('No authenticated user found');
      }
      
      // Create blog data with authenticated user's ID
      final blogData = <String, dynamic>{
        'id': blog.id,
        'user_id': authenticatedUserId,
        'created_at': blog.created_at.toIso8601String(),
        'title': blog.title,
        'content': blog.content,
        'image_url': blog.image_url,
      };
      
      final response = 
        await supabaseClient.from('posts').update(blogData).eq('id', blog.id).select();
      
      return BlogModel.fromJson(response.first);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
  
  @override
  Future<String> uploadBlogImage({required XFile image, required BlogModel blog}) async {
    try {
      final bytes = await image.readAsBytes();
      if (bytes.isEmpty) {
        throw ServerException('Image file is empty');
      }
      
      // Create a unique filename to avoid conflicts
      final filename = '${blog.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Upload image with upsert enabled to replace existing file
      await supabaseClient.storage.from('blog-images').uploadBinary(
        filename,
        bytes,
        fileOptions: const FileOptions(upsert: true),
      );

      return supabaseClient.storage.from('blog-images').getPublicUrl(filename);
    } on StorageException catch (e) {
      throw ServerException('Storage error: ${e.message}');
    } catch (e) {
      throw ServerException('Image upload failed: ${e.toString()}');
    }
  }
  
  @override
  Future<List<BlogModel>> getAllBlogs() async {
    try {
      final blogs = await supabaseClient
        .from('posts')
        .select('*, profiles (username)')
        .order('created_at', ascending: false);
      return blogs.map((blog) => BlogModel.fromJson(blog).copyWith(
        username: blog['profiles']['username']
      )).toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
  
  @override
  Future<void> deleteBlog(String blogId) async {
    try {
      await supabaseClient
        .from('posts')
        .delete()
        .eq('id', blogId);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
