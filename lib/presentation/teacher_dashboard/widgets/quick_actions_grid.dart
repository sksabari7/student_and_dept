import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuickActionsGrid extends StatelessWidget {
  final Function(String) onActionTap;

  const QuickActionsGrid({super.key, required this.onActionTap});

  @override
  Widget build(BuildContext context) {
    final actions = [
      {
        'id': 'upload_question',
        'title': 'Upload Question Paper',
        'icon': 'quiz',
        'color': const Color(0xFF2196F3),
        'description': 'Upload exam papers',
      },
      {
        'id': 'share_lab_guide',
        'title': 'Share Lab Guide',
        'icon': 'science',
        'color': const Color(0xFF4CAF50),
        'description': 'Share lab manuals',
      },
      {
        'id': 'create_announcement',
        'title': 'Create Announcement',
        'icon': 'campaign',
        'color': const Color(0xFFFF9800),
        'description': 'Notify students',
      },
      {
        'id': 'view_attendance',
        'title': 'View Attendance',
        'icon': 'how_to_reg',
        'color': const Color(0xFF9C27B0),
        'description': 'Check attendance',
      },
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
            child: Text(
              'Quick Actions',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
          ),
          SizedBox(height: 1.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 3.w,
              mainAxisSpacing: 2.h,
              childAspectRatio: 1.2,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              return _buildActionCard(actions[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(Map<String, dynamic> action) {
    return GestureDetector(
      onTap: () => onActionTap(action['id'] as String),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.lightTheme.colorScheme.shadow.withValues(
                alpha: 0.1,
              ),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 15.w,
              height: 15.w,
              decoration: BoxDecoration(
                color: (action['color'] as Color).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: action['icon'] as String,
                  color: action['color'] as Color,
                  size: 28,
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: Text(
                action['title'] as String,
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 0.5.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: Text(
                action['description'] as String,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
