import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_export.dart';
import './widgets/app_logo_widget.dart';
import './widgets/login_form_widget.dart';
import './widgets/support_info_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  // Mock credentials for different roles
  final Map<String, Map<String, String>> _mockCredentials = {
    'Admin': {'email': 'admin@institution.edu', 'password': 'admin123'},
    'Teacher': {'email': 'teacher@institution.edu', 'password': 'teacher123'},
    'Student': {'email': 'student@institution.edu', 'password': 'student123'},
  };

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleLogin(String email, String password, String role) async {
    setState(() {
      _isLoading = true;
    });

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      // Check mock credentials
      final mockCreds = _mockCredentials[role];
      if (mockCreds != null &&
          (email == mockCreds['email'] || email == '1234567890') &&
          password == mockCreds['password']) {
        // Success - trigger haptic feedback
        HapticFeedback.mediumImpact();

        // Navigate based on role
        _navigateToRoleDashboard(role);
      } else {
        // Show error message
        _showErrorMessage(
          'Invalid credentials. Please check your email/mobile, password, and selected role.',
        );
      }
    } catch (e) {
      _showErrorMessage(
        'Network error. Please check your connection and try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToRoleDashboard(String role) {
    switch (role) {
      case 'Admin':
        // For now, navigate to teacher dashboard as admin dashboard is not specified
        Navigator.pushReplacementNamed(context, '/teacher-dashboard');
        break;
      case 'Teacher':
        Navigator.pushReplacementNamed(context, '/teacher-dashboard');
        break;
      case 'Student':
        Navigator.pushReplacementNamed(context, '/student-dashboard');
        break;
    }
  }

  void _showErrorMessage(String message) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'error_outline',
              color: AppTheme.lightTheme.colorScheme.onError,
              size: 20.sp,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.lightTheme.colorScheme.onError,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(4.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.w)),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: AppTheme.lightTheme.colorScheme.onError,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                children: [
                  SizedBox(height: 6.h),

                  // App Logo Section
                  const AppLogoWidget(),

                  SizedBox(height: 4.h),

                  // Login Form Section
                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(maxWidth: 90.w),
                    child: LoginFormWidget(
                      onLogin: _handleLogin,
                      isLoading: _isLoading,
                    ),
                  ),

                  SizedBox(height: 4.h),

                  // Support Information Section
                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(maxWidth: 90.w),
                    child: const SupportInfoWidget(),
                  ),

                  SizedBox(height: 4.h),

                  // Footer Information
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    child: Column(
                      children: [
                        Text(
                          'EduManage Pro v1.0.0',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.7),
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          '© 2025 Educational Institution',
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w400,
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
