import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ClassDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> classData;
  final String userRole;
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;

  const ClassDetailsSheet({
    super.key,
    required this.classData,
    required this.userRole,
    this.onEdit,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: _getSubjectColor(
                    classData['subject'] as String? ?? '',
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomIconWidget(
                  iconName: 'book',
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      classData['subject'] as String? ?? '',
                      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      '${classData['day']} • ${classData['time']}',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          _buildDetailRow(
            icon: 'person',
            title: 'Teacher',
            value: classData['teacher'] as String? ?? '',
          ),
          SizedBox(height: 2.h),
          _buildDetailRow(
            icon: 'location_on',
            title: 'Room',
            value: classData['room'] as String? ?? '',
          ),
          SizedBox(height: 2.h),
          _buildDetailRow(
            icon: 'schedule',
            title: 'Duration',
            value: classData['duration'] as String? ?? '1 hour',
          ),
          if (classData['description'] != null &&
              (classData['description'] as String).isNotEmpty) ...[
            SizedBox(height: 2.h),
            _buildDetailRow(
              icon: 'description',
              title: 'Description',
              value: classData['description'] as String,
            ),
          ],
          SizedBox(height: 4.h),
          if (userRole == 'Admin' || userRole == 'Teacher') ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCancel,
                    icon: CustomIconWidget(
                      iconName: 'cancel',
                      color: AppTheme.lightTheme.colorScheme.error,
                      size: 18,
                    ),
                    label: const Text('Cancel Class'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.lightTheme.colorScheme.error,
                      side: BorderSide(
                        color: AppTheme.lightTheme.colorScheme.error,
                      ),
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onEdit,
                    icon: CustomIconWidget(
                      iconName: 'edit',
                      color: Colors.white,
                      size: 18,
                    ),
                    label: const Text('Edit Class'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: CustomIconWidget(
                  iconName: 'check',
                  color: Colors.white,
                  size: 18,
                ),
                label: const Text('Got it'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                ),
              ),
            ),
          ],
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.primary.withValues(
              alpha: 0.1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomIconWidget(
            iconName: icon,
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 16,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                value,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
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
