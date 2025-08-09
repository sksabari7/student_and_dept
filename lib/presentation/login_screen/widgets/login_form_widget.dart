import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class LoginFormWidget extends StatefulWidget {
  final Function(String email, String password, String role) onLogin;
  final bool isLoading;

  const LoginFormWidget({
    super.key,
    required this.onLogin,
    required this.isLoading,
  });

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  String _selectedRole = 'Student';
  bool _isEmailValid = false;
  bool _isPasswordValid = false;
  String? _emailError;
  String? _passwordError;

  final List<String> _roles = ['Admin', 'Teacher', 'Student'];

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateEmail() {
    final email = _emailController.text.trim();
    setState(() {
      if (email.isEmpty) {
        _emailError = null;
        _isEmailValid = false;
      } else if (_isValidEmail(email) || _isValidMobile(email)) {
        _emailError = null;
        _isEmailValid = true;
      } else {
        _emailError = 'Enter valid email or mobile number';
        _isEmailValid = false;
      }
    });
  }

  void _validatePassword() {
    final password = _passwordController.text;
    setState(() {
      if (password.isEmpty) {
        _passwordError = null;
        _isPasswordValid = false;
      } else if (password.length < 6) {
        _passwordError = 'Password must be at least 6 characters';
        _isPasswordValid = false;
      } else {
        _passwordError = null;
        _isPasswordValid = true;
      }
    });
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidMobile(String mobile) {
    return RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(mobile);
  }

  TextInputType _getKeyboardType() {
    final text = _emailController.text.trim();
    if (text.isNotEmpty && _isValidMobile(text)) {
      return TextInputType.phone;
    }
    return TextInputType.emailAddress;
  }

  void _handleLogin() {
    if (_isEmailValid && _isPasswordValid && !widget.isLoading) {
      HapticFeedback.lightImpact();
      widget.onLogin(
        _emailController.text.trim(),
        _passwordController.text,
        _selectedRole,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email/Mobile Input Field
          Container(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _emailController,
                  keyboardType: _getKeyboardType(),
                  textInputAction: TextInputAction.next,
                  enabled: !widget.isLoading,
                  decoration: InputDecoration(
                    labelText: 'Email or Mobile Number',
                    hintText: 'Enter your email or mobile number',
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(12.w),
                      child: CustomIconWidget(
                        iconName: _getKeyboardType() == TextInputType.phone
                            ? 'phone'
                            : 'email',
                        color: _isEmailValid
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 20.sp,
                      ),
                    ),
                    suffixIcon: _emailController.text.isNotEmpty
                        ? IconButton(
                            onPressed: widget.isLoading
                                ? null
                                : () {
                                    _emailController.clear();
                                    _validateEmail();
                                  },
                            icon: CustomIconWidget(
                              iconName: 'clear',
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                              size: 18.sp,
                            ),
                          )
                        : null,
                    errorText: _emailError,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.w),
                      borderSide: BorderSide(
                        color: AppTheme.lightTheme.colorScheme.outline,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.w),
                      borderSide: BorderSide(
                        color: AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.w),
                      borderSide: BorderSide(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.w),
                      borderSide: BorderSide(
                        color: AppTheme.lightTheme.colorScheme.error,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 2.h),

          // Password Input Field
          Container(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  enabled: !widget.isLoading,
                  onFieldSubmitted: (_) => _handleLogin(),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(12.w),
                      child: CustomIconWidget(
                        iconName: 'lock',
                        color: _isPasswordValid
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 20.sp,
                      ),
                    ),
                    suffixIcon: IconButton(
                      onPressed: widget.isLoading
                          ? null
                          : () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                      icon: CustomIconWidget(
                        iconName:
                            _obscurePassword ? 'visibility' : 'visibility_off',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 20.sp,
                      ),
                    ),
                    errorText: _passwordError,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.w),
                      borderSide: BorderSide(
                        color: AppTheme.lightTheme.colorScheme.outline,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.w),
                      borderSide: BorderSide(
                        color: AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.w),
                      borderSide: BorderSide(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.w),
                      borderSide: BorderSide(
                        color: AppTheme.lightTheme.colorScheme.error,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 1.h),

          // Forgot Password Link
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: widget.isLoading
                  ? null
                  : () {
                      _showForgotPasswordDialog();
                    },
              child: Text(
                'Forgot Password?',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ),
          ),

          SizedBox(height: 2.h),

          // Role Selection Chips
          Text(
            'Select Role',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),

          SizedBox(height: 1.h),

          Wrap(
            spacing: 2.w,
            children: _roles.map((role) {
              final isSelected = _selectedRole == role;
              return FilterChip(
                label: Text(
                  role,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? AppTheme.lightTheme.colorScheme.onPrimary
                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                selected: isSelected,
                onSelected: widget.isLoading
                    ? null
                    : (selected) {
                        if (selected) {
                          setState(() {
                            _selectedRole = role;
                          });
                        }
                      },
                backgroundColor: AppTheme.lightTheme.colorScheme.surface,
                selectedColor: AppTheme.lightTheme.colorScheme.primary,
                checkmarkColor: AppTheme.lightTheme.colorScheme.onPrimary,
                side: BorderSide(
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.5),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.w),
                ),
              );
            }).toList(),
          ),

          SizedBox(height: 3.h),

          // Login Button
          SizedBox(
            width: double.infinity,
            height: 6.h,
            child: ElevatedButton(
              onPressed:
                  (_isEmailValid && _isPasswordValid && !widget.isLoading)
                      ? _handleLogin
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
                disabledBackgroundColor: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                disabledForegroundColor:
                    AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                elevation: widget.isLoading ? 0 : 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.w),
                ),
              ),
              child: widget.isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20.sp,
                          height: 20.sp,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.lightTheme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          'Signing In...',
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'Login',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Forgot Password?',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To reset your password, please contact your institution administrator with the following information:',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8.w),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• Your registered email/mobile number',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    '• Your student/employee ID',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    '• Your role (Student/Teacher/Admin)',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
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
            child: Text(
              'Got it',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
