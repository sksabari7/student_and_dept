import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class AccountSection extends StatefulWidget {
  final BuildContext parentContext;

  const AccountSection({super.key, required this.parentContext});

  @override
  State<AccountSection> createState() => _AccountSectionState();
}

class _AccountSectionState extends State<AccountSection> {
  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureCurrentPassword = true;
    bool obscureNewPassword = true;
    bool obscureConfirmPassword = true;
    String passwordStrength = '';
    Color strengthColor = Colors.grey;

    void _checkPasswordStrength(String password) {
      if (password.isEmpty) {
        passwordStrength = '';
        strengthColor = Colors.grey;
      } else if (password.length < 6) {
        passwordStrength = 'Weak';
        strengthColor = Colors.red;
      } else if (password.length < 8 ||
          !RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(password)) {
        passwordStrength = 'Medium';
        strengthColor = Colors.orange;
      } else {
        passwordStrength = 'Strong';
        strengthColor = Colors.green;
      }
    }

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: Text('Change Password'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: currentPasswordController,
                          obscureText: obscureCurrentPassword,
                          decoration: InputDecoration(
                            labelText: 'Current Password',
                            prefixIcon: CustomIconWidget(
                              iconName: 'lock',
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                            suffixIcon: IconButton(
                              icon: CustomIconWidget(
                                iconName:
                                    obscureCurrentPassword
                                        ? 'visibility'
                                        : 'visibility_off',
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                size: 20,
                              ),
                              onPressed: () {
                                setDialogState(() {
                                  obscureCurrentPassword =
                                      !obscureCurrentPassword;
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: newPasswordController,
                          obscureText: obscureNewPassword,
                          onChanged: (value) {
                            setDialogState(() {
                              _checkPasswordStrength(value);
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'New Password',
                            prefixIcon: CustomIconWidget(
                              iconName: 'lock_outline',
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                            suffixIcon: IconButton(
                              icon: CustomIconWidget(
                                iconName:
                                    obscureNewPassword
                                        ? 'visibility'
                                        : 'visibility_off',
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                size: 20,
                              ),
                              onPressed: () {
                                setDialogState(() {
                                  obscureNewPassword = !obscureNewPassword;
                                });
                              },
                            ),
                          ),
                        ),
                        if (passwordStrength.isNotEmpty) ...[
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                'Strength: ',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                passwordStrength,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(
                                  color: strengthColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                        SizedBox(height: 16),
                        TextField(
                          controller: confirmPasswordController,
                          obscureText: obscureConfirmPassword,
                          decoration: InputDecoration(
                            labelText: 'Confirm New Password',
                            prefixIcon: CustomIconWidget(
                              iconName: 'lock_outline',
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                            suffixIcon: IconButton(
                              icon: CustomIconWidget(
                                iconName:
                                    obscureConfirmPassword
                                        ? 'visibility'
                                        : 'visibility_off',
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                size: 20,
                              ),
                              onPressed: () {
                                setDialogState(() {
                                  obscureConfirmPassword =
                                      !obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (newPasswordController.text ==
                                confirmPasswordController.text &&
                            newPasswordController.text.isNotEmpty &&
                            currentPasswordController.text.isNotEmpty) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'check_circle',
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Password changed successfully'),
                                ],
                              ),
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                            ),
                          );
                        }
                      },
                      child: Text('Change Password'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                CustomIconWidget(
                  iconName: 'logout',
                  color: Theme.of(context).colorScheme.error,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text('Logout'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Are you sure you want to logout?'),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.errorContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'warning',
                        color: Theme.of(context).colorScheme.error,
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This will clear your session and offline data',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(
                    widget.parentContext,
                    '/login-screen',
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                child: Text('Logout'),
              ),
            ],
          ),
    );
  }

  Widget _buildAccountTile({
    required String title,
    required String subtitle,
    required String iconName,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (iconColor ?? Theme.of(context).colorScheme.primary)
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomIconWidget(
            iconName: iconName,
            color: iconColor ?? Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: CustomIconWidget(
          iconName: 'arrow_forward_ios',
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Management',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 24),
          _buildAccountTile(
            title: 'Change Password',
            subtitle: 'Update your account password',
            iconName: 'lock',
            onTap: _showChangePasswordDialog,
          ),
          _buildAccountTile(
            title: 'Privacy Settings',
            subtitle: 'Manage your privacy preferences',
            iconName: 'privacy_tip',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Privacy settings coming soon')),
              );
            },
            iconColor: Colors.blue,
          ),
          _buildAccountTile(
            title: 'Data Export',
            subtitle: 'Download your personal data',
            iconName: 'download',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'download',
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text('Data export initiated'),
                    ],
                  ),
                ),
              );
            },
            iconColor: Colors.green,
          ),
          _buildAccountTile(
            title: 'Logout',
            subtitle: 'Sign out of your account',
            iconName: 'logout',
            onTap: _showLogoutDialog,
            iconColor: Theme.of(context).colorScheme.error,
            textColor: Theme.of(context).colorScheme.error,
          ),
          SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'security',
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Security Information',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'Last login: ',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      'Today at 2:30 PM',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Active sessions: ',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '2 devices',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
