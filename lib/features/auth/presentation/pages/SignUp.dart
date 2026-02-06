import 'package:caco_flutter_blog/core/common/widgets/loader.dart';
import 'package:caco_flutter_blog/core/theme/app_palette.dart';
import 'package:caco_flutter_blog/core/utils/show_snackbar.dart';
import 'package:caco_flutter_blog/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:caco_flutter_blog/features/auth/presentation/pages/Login.dart';
import 'package:caco_flutter_blog/features/auth/presentation/widgets/auth_button.dart';
import 'package:caco_flutter_blog/features/auth/presentation/widgets/auth_field.dart';
import 'package:caco_flutter_blog/features/blog/presentation/pages/blog_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUp extends StatefulWidget {
  static route() => MaterialPageRoute(builder: (context) => const SignUp());
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if(state is AuthFailure){
                showSnackBar(context, state.message);
              } else if(state is AuthSuccess){
                Navigator.pushAndRemoveUntil(
                  context,
                  BlogPage.route(),
                  (route) => false,
                );
              }
            },
            builder: (context, state) {
              if(state is AuthLoading) {
                return const Loader();
              }
              
              return Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    AuthField(hintText: 'Username', controller: nameController),
                    const SizedBox(height: 15),
                    AuthField(hintText: 'Email', controller: emailController),
                    const SizedBox(height: 15),
                    AuthField(
                      hintText: 'Password',
                      controller: passwordController,
                      isObscureText: true,
                    ),
                    const SizedBox(height: 20),
                    AuthButton(
                      buttonText: 'Create Account',
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          context.read<AuthBloc>().add(
                            AuthSignUp(
                              email: emailController.text.trim(),
                              password: passwordController.text.trim(),
                              username: nameController.text.trim(),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
