import 'dart:io';

import 'package:caco_flutter_blog/core/error/exception.dart';
import 'package:caco_flutter_blog/core/error/failure.dart';
import 'package:caco_flutter_blog/features/blog/data/datasources/blog_supabase_source.dart';
import 'package:caco_flutter_blog/features/blog/data/models/blog_model.dart';
import 'package:caco_flutter_blog/features/blog/domain/entities/blog.dart';
import 'package:caco_flutter_blog/features/blog/domain/repositories/blog_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

class BlogRepositoryImpl implements BlogRepository {
  final BlogSupabaseSource blogSupabaseSource;
  BlogRepositoryImpl(this.blogSupabaseSource);
  @override
  Future<Either<Failure, Blog>> uploadBlog({
    required File image, 
    required String title, 
    required String content, 
    required String user_id,
    }) async {
      try {
        BlogModel blogModel = BlogModel(
          id: const Uuid().v1(), 
          user_id: user_id, 
          title: title, 
          content: content,
          image_url: '', 
          username: '',
          created_at: DateTime.now(),  
        );
        final imageUrl = await blogSupabaseSource.uploadBlogImage(
          image: image, 
          blog: blogModel
        );
        blogModel = blogModel.copyWith(
          image_url: imageUrl,
        );
        final uploadedBlog = await blogSupabaseSource.uploadBlog(blogModel);
        return Right(uploadedBlog);
      } on ServerException catch (e) {
        return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Blog>> updateBlog({
    required File image, 
    required String title, 
    required String content, 
    required String user_id,
    }) async {
      try {
        BlogModel blogModel = BlogModel(
          id: const Uuid().v1(), 
          user_id: user_id, 
          title: title, 
          content: content,
          image_url: '', 
          username: '',
          created_at: DateTime.now(),  
        );
        final imageUrl = await blogSupabaseSource.uploadBlogImage(
          image: image, 
          blog: blogModel
        );
        blogModel = blogModel.copyWith(
          image_url: imageUrl,
        );
        final uploadedBlog = await blogSupabaseSource.updateBlog(blogModel);
        return Right(uploadedBlog);
      } on ServerException catch (e) {
        return Left(Failure(e.message));
    }
  }
  
  @override
  Future<Either<Failure, List<Blog>>> getAllBlogs() async {
    try {
      final blogs = await blogSupabaseSource.getAllBlogs();
      return Right(blogs);
    } on ServerException catch (e) {
      return Left(Failure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> deleteBlog(String blogId) async {
    try {
      await blogSupabaseSource.deleteBlog(blogId);
      return Right(null);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }
}