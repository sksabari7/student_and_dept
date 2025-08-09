import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuickAccessBottomSheet extends StatelessWidget {
  final Function(String) onActionTap;

  const QuickAccessBottomSheet({super.key, required this.onActionTap});

  @override
  Widget build(BuildContext context) {
    final quickActions = [
      {
        'title': 'View Timetable',
        'subtitle': 'Check today\'s schedule',
        'icon': 'schedule',
        'action': 'timetable',
        'color': AppTheme.lightTheme.colorScheme.primary,
      },
      {
        'title': 'Download Resources',
        'subtitle': 'Access study materials',
        'icon': 'download',
        'action': 'resources',
        'color': AppTheme.lightTheme.colorScheme.secondary,
      },
      {
        'title': 'Check Attendance',
        'subtitle': 'View attendance records',
        'icon': 'fact_check',
        'action': 'attendance',
        'color': AppTheme.lightTheme.colorScheme.tertiary,
      },
      {
        'title': 'View Announcements',
        'subtitle': 'Latest updates',
        'icon': 'campaign',
        'action': 'announcements',
        'color': Colors.purple,
      },
      {
        'title': 'Access Library',
        'subtitle': 'Digital textbooks',
        'icon': 'library_books',
        'action': 'library',
        'color': Colors.green,
      },
      {
        'title': 'Profile Settings',
        'subtitle': 'Manage your account',
        'icon': 'person',
        'action': 'profile',
        'color': Colors.orange,
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.symmetric(vertical: 2.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quick Access',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: CustomIconWidget(
                    iconName: 'close',
                    size: 24,
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              itemCount: quickActions.length,
              separatorBuilder: (context, index) => SizedBox(height: 1.h),
              itemBuilder: (context, index) {
                final action = quickActions[index];
                return _buildActionTile(context, action);
              },
            ),
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, Map<String, dynamic> action) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onActionTap(action['action'] as String);
      },
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: (action['color'] as Color).withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (action['color'] as Color).withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: action['color'] as Color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: CustomIconWidget(
                iconName: action['icon'] as String,
                size: 24,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action['title'] as String,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    action['subtitle'] as String,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'arrow_forward_ios',
              size: 16,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
