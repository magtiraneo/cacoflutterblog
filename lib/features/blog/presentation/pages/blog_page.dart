import 'package:caco_flutter_blog/core/common/widgets/loader.dart';
import 'package:caco_flutter_blog/core/theme/app_palette.dart';
import 'package:caco_flutter_blog/core/utils/show_snackbar.dart';
import 'package:caco_flutter_blog/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:caco_flutter_blog/features/auth/presentation/pages/Login.dart';
import 'package:caco_flutter_blog/features/blog/presentation/bloc/blog_bloc.dart';
import 'package:caco_flutter_blog/features/blog/presentation/pages/write_new_blog.dart';
import 'package:caco_flutter_blog/features/blog/presentation/widgets/alerts.dart';
import 'package:caco_flutter_blog/features/blog/presentation/widgets/blog_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlogPage extends StatefulWidget {
  static route() => MaterialPageRoute(builder: (context) => const BlogPage());
  const BlogPage({super.key});

  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {

  @override
  void initState() {
    super.initState();
    context.read<BlogBloc>().add(BlogFetchAllBlogs());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('cacocacoblog!'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, WriteNewBlog.route());
            }, 
            icon: const Icon(CupertinoIcons.add_circled),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
            showAlertDialog(context);
            },
          ),
        ],
      ),
      body: BlocConsumer<BlogBloc, BlogState>(
        listener: (context, state) {
          if (state is BlogFailure) {
            showSnackBar(context, state.error);
          }
        },
        builder: (context, state) {
          if (state is BlogLoading) {
            return const Loader();
          }
          if (state is BlogSuccess) {
            return ListView.builder(
              itemCount: state.blogs.length,
              itemBuilder: (context, index) {
                final blog = state.blogs[index];
                return BlogCard(
                  blog: blog, 
                  color: 
                    index % 3 == 0 
                    ? AppPalette.cardColor1
                    : index % 3 == 1
                      ? AppPalette.cardColor2
                      : AppPalette.cardColor3,
                );
              },
            );
          }
          return Center(
            child: Text('No posts to display.\nCreate one now!')
          );
        },
      ),
    );
  }
}