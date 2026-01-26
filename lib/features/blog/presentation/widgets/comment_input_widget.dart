import 'dart:typed_data';

import 'package:caco_flutter_blog/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:caco_flutter_blog/core/utils/show_snackbar.dart';
import 'package:caco_flutter_blog/features/blog/presentation/bloc/comment_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class CommentInputWidget extends StatefulWidget {
  final String blogId;

  const CommentInputWidget({super.key, required this.blogId});

  @override
  State<CommentInputWidget> createState() => _CommentInputWidgetState();
}

class _CommentInputWidgetState extends State<CommentInputWidget> {
  final TextEditingController _controller = TextEditingController();
  XFile? _selectedImage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CommentBloc, CommentState>(
      listener: (context, state) {
        if (state is CommentAdded) {
          _controller.clear();
          setState(() {
            _selectedImage = null;
          });
          showSnackBar(context, 'Comment added!');
          context.read<CommentBloc>().add(
            CommentFetch(blogId: widget.blogId),
          );
        } else if (state is CommentFailure) {
          showSnackBar(context, state.error);
        } else if (state is CommentDeleted) {
          showSnackBar(context, 'Comment deleted!');
          context.read<CommentBloc>().add(
            CommentFetch(blogId: widget.blogId),
          );
        }
      },
      child: BlocSelector<AppUserCubit, AppUserState, (String?, String?)>(
        selector: (userState) {
          if (userState is AppUserLoggedIn) {
            return (userState.user.id, userState.user.username);
          }
          return (null, null);
        },
        builder: (context, userData) {
          final userId = userData.$1;
          final username = userData.$2;
          if (userId == null) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Sign in to comment',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              children: [
                if (_selectedImage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: FutureBuilder<List<int>>(
                            future: _selectedImage!.readAsBytes(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Image.memory(
                                  Uint8List.fromList(snapshot.data!),
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                );
                              }
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedImage = null;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Add a comment...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        maxLines: null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.image),
                      onPressed: _pickImage,
                    ),
                    BlocBuilder<CommentBloc, CommentState>(
                      builder: (context, state) {
                        return IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: state is CommentLoading
                              ? null
                              : () {
                                  if (_controller.text.trim().isEmpty) {
                                    showSnackBar(
                                        context, 'Comment cannot be empty');
                                    return;
                                  }
                                  context.read<CommentBloc>().add(
                                    CommentAdd(
                                      blogId: widget.blogId,
                                      userId: userId,
                                      content: _controller.text.trim(),
                                      username: username,
                                      image: _selectedImage,
                                    ),
                                  );
                                },
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
