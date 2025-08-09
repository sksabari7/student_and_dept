import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RecentUploadsSection extends StatelessWidget {
  final List<Map<String, dynamic>> recentUploads;
  final Function(Map<String, dynamic>) onUploadTap;

  const RecentUploadsSection({
    super.key,
    required this.recentUploads,
    required this.onUploadTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Uploads',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/resource-library');
                },
                child: Text(
                  'View All',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          recentUploads.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentUploads.length > 5 ? 5 : recentUploads.length,
                separatorBuilder: (context, index) => SizedBox(height: 1.h),
                itemBuilder: (context, index) {
                  return _buildUploadItem(recentUploads[index]);
                },
              ),
        ],
      ),
    );
  }

  Widget _buildUploadItem(Map<String, dynamic> upload) {
    return GestureDetector(
      onTap: () => onUploadTap(upload),
      child: Container(
        padding: EdgeInsets.all(4.w),
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
        child: Row(
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: _getFileTypeColor(
                  upload['type'] as String,
                ).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: _getFileTypeIcon(upload['type'] as String),
                  color: _getFileTypeColor(upload['type'] as String),
                  size: 24,
                ),
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    upload['title'] as String,
                    style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    upload['subject'] as String,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'download',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 14,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        '${upload['downloads']} downloads',
                        style: AppTheme.lightTheme.textTheme.bodySmall
                            ?.copyWith(
                              color:
                                  AppTheme
                                      .lightTheme
                                      .colorScheme
                                      .onSurfaceVariant,
                            ),
                      ),
                      SizedBox(width: 3.w),
                      CustomIconWidget(
                        iconName: 'star',
                        color: AppTheme.lightTheme.colorScheme.tertiary,
                        size: 14,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        '${upload['rating']}',
                        style: AppTheme.lightTheme.textTheme.bodySmall
                            ?.copyWith(
                              color:
                                  AppTheme
                                      .lightTheme
                                      .colorScheme
                                      .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  upload['uploadDate'] as String,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 1.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      upload['status'] as String,
                    ).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    upload['status'] as String,
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: _getStatusColor(upload['status'] as String),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'cloud_upload',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 48,
          ),
          SizedBox(height: 2.h),
          Text(
            'No Recent Uploads',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Start sharing resources with your students',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getFileTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return 'picture_as_pdf';
      case 'doc':
      case 'docx':
        return 'description';
      case 'ppt':
      case 'pptx':
        return 'slideshow';
      case 'video':
        return 'play_circle';
      case 'image':
        return 'image';
      case 'lab_guide':
        return 'science';
      case 'question_paper':
        return 'quiz';
      default:
        return 'insert_drive_file';
    }
  }

  Color _getFileTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return const Color(0xFFE53E3E);
      case 'doc':
      case 'docx':
        return const Color(0xFF2B6CB0);
      case 'ppt':
      case 'pptx':
        return const Color(0xFFD69E2E);
      case 'video':
        return const Color(0xFF9F7AEA);
      case 'image':
        return const Color(0xFF38A169);
      case 'lab_guide':
        return const Color(0xFF00B5D8);
      case 'question_paper':
        return const Color(0xFFED8936);
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFF38A169);
      case 'pending':
        return const Color(0xFFD69E2E);
      case 'draft':
        return const Color(0xFF718096);
      case 'archived':
        return const Color(0xFFA0AEC0);
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }
}
