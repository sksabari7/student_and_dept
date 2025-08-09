import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuickAccessGridWidget extends StatelessWidget {
  final Function(String) onTileTap;

  const QuickAccessGridWidget({super.key, required this.onTileTap});

  @override
  Widget build(BuildContext context) {
    final quickAccessItems = [
      {
        'title': 'Download Resources',
        'icon': 'download',
        'badge': 3,
        'color': AppTheme.lightTheme.colorScheme.primary,
        'action': 'resources',
      },
      {
        'title': 'View Announcements',
        'icon': 'campaign',
        'badge': 2,
        'color': AppTheme.lightTheme.colorScheme.secondary,
        'action': 'announcements',
      },
      {
        'title': 'Check Attendance',
        'icon': 'fact_check',
        'badge': 0,
        'color': AppTheme.lightTheme.colorScheme.tertiary,
        'action': 'attendance',
      },
      {
        'title': 'Access Library',
        'icon': 'library_books',
        'badge': 5,
        'color': Colors.purple,
        'action': 'library',
      },
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Access',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 3.h),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 3.w,
                mainAxisSpacing: 2.h,
                childAspectRatio: 1.2,
              ),
              itemCount: quickAccessItems.length,
              itemBuilder: (context, index) {
                final item = quickAccessItems[index];
                return _buildQuickAccessTile(context, item);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessTile(
    BuildContext context,
    Map<String, dynamic> item,
  ) {
    return GestureDetector(
      onTap: () => onTileTap(item['action'] as String),
      child: Container(
        decoration: BoxDecoration(
          color: (item['color'] as Color).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (item['color'] as Color).withValues(alpha: 0.2),
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(3.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: item['color'] as Color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomIconWidget(
                      iconName: item['icon'] as String,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    item['title'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if ((item['badge'] as int) > 0)
              Positioned(
                top: 2.w,
                right: 2.w,
                child: Container(
                  padding: EdgeInsets.all(1.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.error,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: BoxConstraints(minWidth: 5.w, minHeight: 5.w),
                  child: Text(
                    '${item['badge']}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
