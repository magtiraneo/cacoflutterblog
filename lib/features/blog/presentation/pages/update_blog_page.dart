import 'dart:io';

import 'package:caco_flutter_blog/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:caco_flutter_blog/core/common/widgets/loader.dart';
import 'package:caco_flutter_blog/core/theme/app_palette.dart';
import 'package:caco_flutter_blog/core/utils/pick_image.dart';
import 'package:caco_flutter_blog/core/utils/show_snackbar.dart';
import 'package:caco_flutter_blog/features/blog/domain/entities/blog.dart';
import 'package:caco_flutter_blog/features/blog/presentation/bloc/blog_bloc.dart';
import 'package:caco_flutter_blog/features/blog/presentation/pages/blog_page.dart';
import 'package:caco_flutter_blog/features/blog/presentation/widgets/blog_editor.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UpdateBlogPage extends StatefulWidget {
  static route(Blog blog) =>
      MaterialPageRoute(builder: (context) => UpdateBlogPage(blog: blog));
  
  final Blog blog;
  const UpdateBlogPage({super.key, required this.blog});

  @override
  State<UpdateBlogPage> createState() => _UpdateBlogState();
}

class _UpdateBlogState extends State<UpdateBlogPage> {
  late TextEditingController titleController;
  late TextEditingController contentController;
  final formKey = GlobalKey<FormState>();
  File? image;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.blog.title);
    contentController = TextEditingController(text: widget.blog.content);
  }

  void selectImage() async {
    final pickedImage = await pickImage();
    if (pickedImage != null) {
      setState(() {
        image = pickedImage;
      });
    }
  }

  void updateBlog() {
    if (formKey.currentState!.validate()) {
      if (image == null && widget.blog.image_url.isEmpty) {
        showSnackBar(context, 'Please select an image');
        return;
      }
      final userId =
          (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;
      final userName =
          (context.read<AppUserCubit>().state as AppUserLoggedIn).user.username;
      context.read<BlogBloc>().add(
        BlogUpdate(
          blogId: widget.blog.id,
          user_id: userId,
          title: titleController.text.trim(),
          content: contentController.text.trim(),
          image: image ?? File(''),
          username: userName,
        ),
      );
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              updateBlog();
            },
            icon: const Icon(Icons.done_rounded),
          ),
        ],
      ),
      body: BlocConsumer<BlogBloc, BlogState>(
        listener: (context, state) {
          if (state is BlogFailure) {
            showSnackBar(context, state.error);
          } else if (state is BlogUpdateSuccess) {
            Navigator.pushAndRemoveUntil(
              context, 
              BlogPage.route(), 
              (route) => false,
              );
          }
        },
        builder: (context, state) {
          if (state is BlogLoading) {
            return const Loader();
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    image != null
                        ? GestureDetector(
                            onTap: selectImage,
                            child: SizedBox(
                              width: double.infinity,
                              height: 150,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(image!, fit: BoxFit.cover),
                              ),
                            ),
                          )
                        : GestureDetector(
                            onTap: () {
                              selectImage();
                            },
                            child: DottedBorder(
                              options: RectDottedBorderOptions(
                                color: AppPalette.primaryColor,
                                dashPattern: const [10, 4],
                                strokeCap: StrokeCap.round,
                              ),
                              child: Container(
                                height: 150,
                                width: double.infinity,
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.folder_open, size: 40),
                                    SizedBox(height: 15),
                                    Text(
                                      'Upload Cover Image',
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                    const SizedBox(height: 10),
                    BlogEditor(
                      controller: titleController,
                      hintText: 'Enter your title here...',
                    ),
                    const SizedBox(height: 10),
                    BlogEditor(
                      controller: contentController,
                      hintText: 'Enter your thoughts here...',
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
