part of 'blog_bloc.dart';

@immutable
sealed class BlogEvent {}

final class BlogUpload extends BlogEvent {
  final String user_id;
  final String username;
  final String title;
  final String content;
  final File image;

  BlogUpload({
    required this.user_id, 
    required this.title,
    required this.content, 
    required this.image, 
    required this.username, 
  });
}

final class BlogUpdate extends BlogEvent {
  final String user_id;
  final String username;
  final String title;
  final String content;
  final File image;

  BlogUpdate({
    required this.user_id, 
    required this.title,
    required this.content, 
    required this.image, 
    required this.username, 
  });
}

final class BlogFetchAllBlogs extends BlogEvent {

}

final class BlogDelete extends BlogEvent {
  final String blogId;
  BlogDelete(this.blogId);
}