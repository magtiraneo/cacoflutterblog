import 'package:caco_flutter_blog/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:caco_flutter_blog/core/theme/app_palette.dart';
import 'package:caco_flutter_blog/core/utils/show_snackbar.dart';
import 'package:caco_flutter_blog/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:caco_flutter_blog/features/auth/presentation/pages/Login.dart';
import 'package:caco_flutter_blog/features/blog/presentation/widgets/alerts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountPage extends StatefulWidget {
  static route() => MaterialPageRoute(builder: (context) => const AccountPage());
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
      ),
      body: BlocBuilder<AppUserCubit, AppUserState>(
        builder: (context, state) {
          // If user is not logged in, show login message
          if (state is! AppUserLoggedIn) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_outline, size: 80, color: Colors.grey),
                  const SizedBox(height: 20),
                  Text(
                    'Not logged in',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        Login.route(),
                        (route) => false,
                      );
                    },
                    child: const Text('Go to Login'),
                  ),
                ],
              ),
            );
          }

          // Extract user from the logged-in state
          final user = state.user;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Profile Avatar Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppPalette.cardColor1,
                          AppPalette.cardColor2,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          child: Text(
                            user.username.isNotEmpty
                                ? user.username[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: AppPalette.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Username
                        Text(
                          user.username,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Email
                        Text(
                          user.email,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // User Details Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow('Username', user.username),
                        Divider(color: Colors.grey.shade300),
                        _buildDetailRow('Email', user.email),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Action Buttons
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        // Show confirmation dialog before logout
                        final confirmed =
                            await showConfirmDialog(
                          context: context,
                          title: 'Log Out',
                          content:
                              'Are you sure you want to sign out?',
                          confirmText: 'Log out',
                        );
                        if (!confirmed) return;
                        if (!context.mounted) return;

                        // Trigger logout
                        context.read<AuthBloc>().add(AuthSignOut());
                        if (!context.mounted) return;

                        // Navigate to login page
                        Navigator.pushAndRemoveUntil(
                          context,
                          Login.route(),
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Sign Out'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Helper widget to display a detail row (key: value pair)
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
