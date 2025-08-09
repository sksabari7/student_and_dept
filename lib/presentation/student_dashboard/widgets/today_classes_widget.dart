import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TodayClassesWidget extends StatelessWidget {
  final List<Map<String, dynamic>> todayClasses;
  final VoidCallback onViewFullTimetable;

  const TodayClassesWidget({
    super.key,
    required this.todayClasses,
    required this.onViewFullTimetable,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today\'s Classes',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
                TextButton(
                  onPressed: onViewFullTimetable,
                  child: Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            todayClasses.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: todayClasses.length > 3 ? 3 : todayClasses.length,
                  separatorBuilder: (context, index) => SizedBox(height: 1.h),
                  itemBuilder: (context, index) {
                    final classData = todayClasses[index];
                    return _buildClassCard(context, classData);
                  },
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'event_available',
            size: 48,
            color: AppTheme.lightTheme.colorScheme.outline,
          ),
          SizedBox(height: 2.h),
          Text(
            'No classes scheduled for today',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassCard(BuildContext context, Map<String, dynamic> classData) {
    final now = DateTime.now();
    final classTime = DateTime.parse(classData['startTime'] as String);
    final isUpcoming = classTime.isAfter(now);
    final timeDifference = classTime.difference(now);

    return GestureDetector(
      onLongPress: () => _showClassOptions(context, classData),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color:
              isUpcoming
                  ? AppTheme.lightTheme.colorScheme.primaryContainer.withValues(
                    alpha: 0.3,
                  )
                  : AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                isUpcoming
                    ? AppTheme.lightTheme.colorScheme.primary.withValues(
                      alpha: 0.3,
                    )
                    : AppTheme.lightTheme.colorScheme.outline.withValues(
                      alpha: 0.2,
                    ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 12.w,
              decoration: BoxDecoration(
                color:
                    isUpcoming
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          classData['subject'] as String,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isUpcoming && timeDifference.inHours < 2)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 0.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _formatCountdown(timeDifference),
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    'Prof. ${classData['faculty'] as String}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'access_time',
                        size: 14,
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        '${classData['time'] as String}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      CustomIconWidget(
                        iconName: 'location_on',
                        size: 14,
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        classData['room'] as String,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCountdown(Duration duration) {
    if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m';
    } else {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
  }

  void _showClassOptions(BuildContext context, Map<String, dynamic> classData) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => Container(
            padding: EdgeInsets.all(4.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  classData['subject'] as String,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3.h),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'alarm',
                    size: 24,
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                  title: const Text('Set Reminder'),
                  onTap: () {
                    Navigator.pop(context);
                    _setReminder(context, classData);
                  },
                ),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'location_on',
                    size: 24,
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                  title: const Text('View Room Location'),
                  onTap: () {
                    Navigator.pop(context);
                    _showRoomLocation(context, classData);
                  },
                ),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'contact_mail',
                    size: 24,
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                  title: const Text('Contact Teacher'),
                  onTap: () {
                    Navigator.pop(context);
                    _contactTeacher(context, classData);
                  },
                ),
                SizedBox(height: 2.h),
              ],
            ),
          ),
    );
  }

  void _setReminder(BuildContext context, Map<String, dynamic> classData) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reminder set for ${classData['subject']}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showRoomLocation(BuildContext context, Map<String, dynamic> classData) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Room ${classData['room']}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Location: ${classData['building']} Building'),
                SizedBox(height: 2.h),
                Text('Floor: ${classData['floor']}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _contactTeacher(BuildContext context, Map<String, dynamic> classData) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Contact Prof. ${classData['faculty']}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Email: ${classData['email']}'),
                SizedBox(height: 1.h),
                Text('Office: ${classData['office']}'),
                SizedBox(height: 1.h),
                Text('Office Hours: ${classData['officeHours']}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}
