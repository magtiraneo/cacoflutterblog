import 'package:caco_flutter_blog/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:caco_flutter_blog/core/theme/app_palette.dart';
import 'package:caco_flutter_blog/core/utils/show_snackbar.dart';
import 'package:caco_flutter_blog/features/blog/domain/entities/blog.dart';
import 'package:caco_flutter_blog/features/blog/presentation/bloc/blog_bloc.dart';
import 'package:caco_flutter_blog/features/blog/presentation/pages/blog_viewer_page.dart';
import 'package:caco_flutter_blog/features/blog/presentation/pages/update_blog_page.dart';
import 'package:caco_flutter_blog/features/blog/presentation/widgets/alerts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlogCard extends StatefulWidget {
  final Blog blog;
  final Color color;
  const BlogCard({
    super.key,
    required this.blog,
    required this.color,
  });

  @override
  State<BlogCard> createState() => _BlogCardState();
}

class _BlogCardState extends State<BlogCard> {
  bool _isDeleting = false;

  void _deleteBlog(BuildContext context) {
    context.read<BlogBloc>().add(BlogDelete(widget.blog.id));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BlogBloc, BlogState>(
      listener: (context, state) {
        if (state is BlogDeleteSuccess) {
          _isDeleting = false;
          showSnackBar(context, 'Blog deleted!');
          context.read<BlogBloc>().add(BlogFetchAllBlogs());
        } else if (state is BlogFailure) {
          _isDeleting = false;
          showSnackBar(context, state.error);
        } else if (state is BlogLoading) {
          _isDeleting = true;
        }
      },
      child: _buildCard(context),
    );
  }

  Widget _buildCard(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final deleted =
            Navigator.push(context, BlogViewerPage.route(widget.blog));
        if (deleted == true) {
          context.read<BlogBloc>().add(BlogFetchAllBlogs());
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Blog list refreshed')));
        }
      },
      child: Container(
          height: 200,
          margin: const EdgeInsets.all(16).copyWith(
            bottom: 4,
          ),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: widget.color, borderRadius: BorderRadius.circular(10)),
          child: _isDeleting
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.blog.title,
                            style: const TextStyle(
                              color: AppPalette.cardFontColor,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        BlocSelector<AppUserCubit, AppUserState, bool>(
                          selector: (userState) {
                            if (userState is AppUserLoggedIn) {
                              return userState.user.id == widget.blog.user_id;
                            }
                            return false;
                          },
                          builder: (context, isAuthor) {
                            if (!isAuthor) return const SizedBox.shrink();
                            return PopupMenuButton<String>(
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  Navigator.push(
                                    context,
                                    UpdateBlogPage.route(widget.blog),
                                  ).then((_) {
                                    context.read<BlogBloc>().add(BlogFetchAllBlogs());
                                  });
                                } else if (value == 'delete') {
                                  final confirmed = await showConfirmDialog(
                                    context: context,
                                    title: 'Delete Post',
                                    content:
                                        'Are you sure?\nThis action cannot be undone!',
                                    confirmText: 'Delete',
                                  );
                                  if (!confirmed) return;
                                  _deleteBlog(context);
                                }
                              },
                              itemBuilder: (BuildContext context) => [
                                const PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.add_circle,
                                          size: 18),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete,
                                          color: Colors.red, size: 18),
                                      SizedBox(width: 8),
                                      Text('Delete',
                                          style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                              icon: const Icon(Icons.more_vert,
                                  color: AppPalette.cardFontColor),
                            );
                          },
                        ),
                      ],
                    ),
                    Text(
                      'by ${widget.blog.username!}',
                      style: const TextStyle(
                          color: AppPalette.cardFontColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                )),
    );
  }
}
