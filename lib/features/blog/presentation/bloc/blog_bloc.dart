import 'dart:io';

import 'package:caco_flutter_blog/core/usecase/usecase.dart';
import 'package:caco_flutter_blog/features/blog/domain/entities/blog.dart';
import 'package:caco_flutter_blog/features/blog/domain/usecases/delete_blog.dart';
import 'package:caco_flutter_blog/features/blog/domain/usecases/get_all_blogs.dart';
import 'package:caco_flutter_blog/features/blog/domain/usecases/update_blog.dart';
import 'package:caco_flutter_blog/features/blog/domain/usecases/upload_blog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'blog_event.dart';
part 'blog_state.dart';

class BlogBloc extends Bloc<BlogEvent, BlogState> {
  final UploadBlog _uploadBlog;
  final GetAllBlogs _getAllBlogs;
  final DeleteBlog _deleteBlog;
  final UpdateBlog _updateBlog;
  BlogBloc({
    required UploadBlog uploadBlog, 
    required GetAllBlogs getAllBlogs,
    required DeleteBlog deleteBlog,
    required UpdateBlog updateBlog,
  })  : _uploadBlog = uploadBlog,
        _getAllBlogs = getAllBlogs,
        _deleteBlog = deleteBlog,
        _updateBlog = updateBlog,
        super(BlogInitial()) {
    on<BlogEvent>((event, emit) => emit(BlogLoading()));
    on<BlogUpload>(_onBlogUpload);
    on<BlogUpdate>(_onBlogUpdate);
    on<BlogFetchAllBlogs>(_onFetchAllBlogs);
    on<BlogDelete>(_onDeleteBlog);
  }

  void _onBlogUpload(
    BlogUpload event, 
    Emitter<BlogState> emit
  ) async {
    final res = await _uploadBlog(UploadBlogParams(
      user_id: event.user_id, 
      title: event.title, 
      content: event.content, 
      image: event.image, 
      ),
    );
    res.fold(
      (l) => emit(BlogFailure(l.message)),
      (r) => emit(BlogUploadSuccess()), 
    );
  }

  void _onBlogUpdate(
    BlogUpdate event, 
    Emitter<BlogState> emit
  ) async {
    final res = await _updateBlog(UpdateBlogParams(
      blogId: event.blogId,
      user_id: event.user_id, 
      title: event.title, 
      content: event.content, 
      image: event.image, 
      ),
    );
    res.fold(
      (l) => emit(BlogFailure(l.message)),
      (r) => emit(BlogUploadSuccess()), 
    );
  }

  void _onFetchAllBlogs(
    BlogFetchAllBlogs event,
    Emitter<BlogState> emit
  ) async {
    final res = await _getAllBlogs(NoParams());
    res.fold(
      (l) => emit(BlogFailure(l.message)), 
      (r) => emit(BlogSuccess(r)),
    );
  }

  void _onDeleteBlog(
    BlogDelete event, 
    Emitter<BlogState> emit
  ) async {
    final res = await _deleteBlog(event.blogId);
    res.fold(
      (l) => emit(BlogFailure(l.message)),
      (_) => emit(BlogDeleteSuccess())
    );
  }
}
