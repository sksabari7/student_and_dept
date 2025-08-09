import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TimetableGridWidget extends StatelessWidget {
  final List<Map<String, dynamic>> timetableData;
  final String userRole;
  final Function(Map<String, dynamic>) onSlotTap;
  final Function(Map<String, dynamic>) onSlotLongPress;

  const TimetableGridWidget({
    super.key,
    required this.timetableData,
    required this.userRole,
    required this.onSlotTap,
    required this.onSlotLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final timeSlots = _generateTimeSlots();
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildHeader(timeSlots),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children:
                    days.map((day) => _buildDayRow(day, timeSlots)).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(List<String> timeSlots) {
    return Container(
      height: 8.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Container(
            width: 20.w,
            alignment: Alignment.center,
            child: Text(
              'Day',
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    timeSlots
                        .map(
                          (time) => Container(
                            width: 25.w,
                            alignment: Alignment.center,
                            child: Text(
                              time,
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color:
                                        AppTheme.lightTheme.colorScheme.primary,
                                  ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayRow(String day, List<String> timeSlots) {
    return Container(
      height: 12.h,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.lightTheme.colorScheme.outline.withValues(
              alpha: 0.2,
            ),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 20.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
              border: Border(
                right: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.outline.withValues(
                    alpha: 0.2,
                  ),
                  width: 1,
                ),
              ),
            ),
            child: Text(
              day.substring(0, 3),
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    timeSlots.map((time) => _buildTimeSlot(day, time)).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlot(String day, String time) {
    final classData = _getClassForSlot(day, time);
    final hasClass = classData != null;

    return GestureDetector(
      onTap: () => hasClass ? onSlotTap(classData) : null,
      onLongPress:
          () =>
              (userRole == 'Admin' || userRole == 'Teacher') && hasClass
                  ? onSlotLongPress(classData)
                  : null,
      child: Container(
        width: 25.w,
        height: 12.h,
        margin: EdgeInsets.all(0.5.w),
        decoration: BoxDecoration(
          color:
              hasClass
                  ? _getSubjectColor(classData['subject'] as String? ?? '')
                  : AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                hasClass
                    ? _getSubjectColor(
                      classData['subject'] as String? ?? '',
                    ).withValues(alpha: 0.3)
                    : AppTheme.lightTheme.colorScheme.outline.withValues(
                      alpha: 0.2,
                    ),
            width: 1,
          ),
        ),
        child: hasClass ? _buildClassCard(classData) : _buildEmptySlot(),
      ),
    );
  }

  Widget _buildClassCard(Map<String, dynamic> classData) {
    return Padding(
      padding: EdgeInsets.all(1.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            (classData['subject'] as String? ?? '').length > 10
                ? '${(classData['subject'] as String).substring(0, 10)}...'
                : (classData['subject'] as String? ?? ''),
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 0.5.h),
          Text(
            (classData['teacher'] as String? ?? '').length > 12
                ? '${(classData['teacher'] as String).substring(0, 12)}...'
                : (classData['teacher'] as String? ?? ''),
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 0.5.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'location_on',
                color: Colors.white.withValues(alpha: 0.8),
                size: 10,
              ),
              SizedBox(width: 1.w),
              Expanded(
                child: Text(
                  classData['room'] as String? ?? '',
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 9,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySlot() {
    return Center(
      child: CustomIconWidget(
        iconName: 'add',
        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant.withValues(
          alpha: 0.3,
        ),
        size: 16,
      ),
    );
  }

  List<String> _generateTimeSlots() {
    return [
      '9:00 AM',
      '10:00 AM',
      '11:00 AM',
      '12:00 PM',
      '1:00 PM',
      '2:00 PM',
      '3:00 PM',
      '4:00 PM',
      '5:00 PM',
    ];
  }

  Map<String, dynamic>? _getClassForSlot(String day, String time) {
    try {
      return timetableData.firstWhere(
        (classItem) =>
            (classItem['day'] as String? ?? '') == day &&
            (classItem['time'] as String? ?? '') == time,
      );
    } catch (e) {
      return null;
    }
  }

  Color _getSubjectColor(String subject) {
    final colors = {
      'Mathematics': const Color(0xFF2196F3),
      'Physics': const Color(0xFF4CAF50),
      'Chemistry': const Color(0xFFFF9800),
      'Biology': const Color(0xFF9C27B0),
      'English': const Color(0xFFF44336),
      'History': const Color(0xFF795548),
      'Geography': const Color(0xFF607D8B),
      'Computer Science': const Color(0xFF3F51B5),
      'Economics': const Color(0xFFE91E63),
      'Psychology': const Color(0xFF009688),
    };

    return colors[subject] ?? AppTheme.lightTheme.colorScheme.primary;
  }
}
