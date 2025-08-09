import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class SupportInfoWidget extends StatelessWidget {
  const SupportInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.5,
        ),
        borderRadius: BorderRadius.circular(12.w),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'info_outline',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20.sp,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'New to the institution?',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 1.h),

          Text(
            'Contact your institution administrator to get your login credentials and access to the EduManage Pro system.',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),

          SizedBox(height: 2.h),

          // Contact Options
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showContactDialog(context),
                  icon: CustomIconWidget(
                    iconName: 'contact_support',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 16.sp,
                  ),
                  label: Text(
                    'Contact Admin',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.lightTheme.colorScheme.primary,
                    side: BorderSide(
                      color: AppTheme.lightTheme.colorScheme.primary.withValues(
                        alpha: 0.5,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.w),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 1.h,
                    ),
                  ),
                ),
              ),

              SizedBox(width: 2.w),

              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showHelpDialog(context),
                  icon: CustomIconWidget(
                    iconName: 'help_outline',
                    color: AppTheme.lightTheme.colorScheme.secondary,
                    size: 16.sp,
                  ),
                  label: Text(
                    'Get Help',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.lightTheme.colorScheme.secondary,
                    side: BorderSide(
                      color: AppTheme.lightTheme.colorScheme.secondary
                          .withValues(alpha: 0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.w),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 1.h,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                CustomIconWidget(
                  iconName: 'admin_panel_settings',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 24.sp,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Contact Administrator',
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'To get access to EduManage Pro, please contact your institution administrator:',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),

                SizedBox(height: 2.h),

                _buildContactItem(
                  context,
                  'Email',
                  'admin@institution.edu',
                  'email',
                  () => _copyToClipboard(
                    context,
                    'admin@institution.edu',
                    'Email',
                  ),
                ),

                SizedBox(height: 1.h),

                _buildContactItem(
                  context,
                  'Phone',
                  '+1 (555) 123-4567',
                  'phone',
                  () => _copyToClipboard(
                    context,
                    '+1 (555) 123-4567',
                    'Phone number',
                  ),
                ),

                SizedBox(height: 1.h),

                _buildContactItem(
                  context,
                  'Office',
                  'Administration Building, Room 101',
                  'location_on',
                  null,
                ),

                SizedBox(height: 2.h),

                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primaryContainer
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8.w),
                  ),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'schedule',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 16.sp,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          'Office Hours: Mon-Fri 9:00 AM - 5:00 PM',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color:
                                AppTheme
                                    .lightTheme
                                    .colorScheme
                                    .onSurfaceVariant,
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
                child: Text(
                  'Close',
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

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                CustomIconWidget(
                  iconName: 'help_center',
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  size: 24.sp,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Help & Support',
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Common Login Issues:',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),

                SizedBox(height: 1.h),

                _buildHelpItem(
                  context,
                  'Forgot Password',
                  'Contact your administrator to reset your password',
                ),

                _buildHelpItem(
                  context,
                  'Account Not Found',
                  'Ensure you\'re using the correct email/mobile and role',
                ),

                _buildHelpItem(
                  context,
                  'Network Issues',
                  'Check your internet connection and try again',
                ),

                _buildHelpItem(
                  context,
                  'New User',
                  'Contact administrator for account creation',
                ),

                SizedBox(height: 2.h),

                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.secondaryContainer
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8.w),
                  ),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'lightbulb_outline',
                        color: AppTheme.lightTheme.colorScheme.secondary,
                        size: 16.sp,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          'Tip: Make sure to select the correct role before logging in',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color:
                                AppTheme
                                    .lightTheme
                                    .colorScheme
                                    .onSurfaceVariant,
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
                child: Text(
                  'Got it',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.lightTheme.colorScheme.secondary,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildContactItem(
    BuildContext context,
    String label,
    String value,
    String iconName,
    VoidCallback? onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 16.sp,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              CustomIconWidget(
                iconName: 'content_copy',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 16.sp,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpItem(
    BuildContext context,
    String title,
    String description,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6.sp,
            height: 6.sp,
            margin: EdgeInsets.only(top: 0.8.h, right: 2.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.secondary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  description,
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
    );
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: AppTheme.lightTheme.colorScheme.onInverseSurface,
              size: 16.sp,
            ),
            SizedBox(width: 2.w),
            Text(
              '$label copied to clipboard',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(4.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.w)),
      ),
    );
  }
}
