import 'package:caco_flutter_blog/core/theme/app_palette.dart';
import 'package:caco_flutter_blog/features/blog/domain/entities/blog.dart';
import 'package:caco_flutter_blog/features/blog/domain/usecases/get_all_blogs.dart';
import 'package:caco_flutter_blog/features/blog/presentation/bloc/blog_bloc.dart';
import 'package:caco_flutter_blog/features/blog/presentation/pages/blog_viewer_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlogCard extends StatelessWidget {
  final Blog blog;
  final Color color;
  const BlogCard({
    super.key, 
    required this.blog, 
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final deleted = Navigator.push(
          context, 
          BlogViewerPage.route(blog)
        );
        if (deleted == true) {
          context.read<BlogBloc>().add(BlogFetchAllBlogs());
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Blog list refreshed')));
        }
      },
      child: Container(
          height: 200,
          margin: const EdgeInsets.all(16).copyWith(
            bottom: 4,
          ),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10)
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                blog.title,
                style: const TextStyle(
                  color: AppPalette.cardFontColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'by ${blog.username!}',
                style: const TextStyle(
                  color: AppPalette.cardFontColor,
                  fontWeight: FontWeight.bold
                ),
              ),
            ],
          )
      ),
    );
  }
}