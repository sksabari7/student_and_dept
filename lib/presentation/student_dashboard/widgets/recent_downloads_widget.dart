import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RecentDownloadsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> recentDownloads;
  final Function(Map<String, dynamic>) onDownloadTap;

  const RecentDownloadsWidget({
    super.key,
    required this.recentDownloads,
    required this.onDownloadTap,
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
                  'Recent Downloads',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
                TextButton(
                  onPressed:
                      () => Navigator.pushNamed(context, '/resource-library'),
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
            recentDownloads.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount:
                      recentDownloads.length > 4 ? 4 : recentDownloads.length,
                  separatorBuilder:
                      (context, index) => Divider(
                        height: 2.h,
                        color: AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.2),
                      ),
                  itemBuilder: (context, index) {
                    final download = recentDownloads[index];
                    return _buildDownloadItem(context, download);
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
            iconName: 'download',
            size: 48,
            color: AppTheme.lightTheme.colorScheme.outline,
          ),
          SizedBox(height: 2.h),
          Text(
            'No recent downloads',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadItem(
    BuildContext context,
    Map<String, dynamic> download,
  ) {
    return GestureDetector(
      onTap: () => onDownloadTap(download),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: _getFileTypeColor(
                  download['type'] as String,
                ).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: _getFileTypeIcon(download['type'] as String),
                size: 24,
                color: _getFileTypeColor(download['type'] as String),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    download['name'] as String,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      Text(
                        download['subject'] as String,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        download['size'] as String,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (download['isOffline'] as bool)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 0.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.secondary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomIconWidget(
                              iconName: 'offline_pin',
                              size: 12,
                              color: AppTheme.lightTheme.colorScheme.secondary,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              'Offline',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color:
                                    AppTheme.lightTheme.colorScheme.secondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      CustomIconWidget(
                        iconName: 'cloud_download',
                        size: 16,
                        color: AppTheme.lightTheme.colorScheme.outline,
                      ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Text(
                  download['downloadDate'] as String,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
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
        return 'play_circle_outline';
      case 'lab_guide':
        return 'science';
      case 'textbook':
        return 'menu_book';
      default:
        return 'insert_drive_file';
    }
  }

  Color _getFileTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'ppt':
      case 'pptx':
        return Colors.orange;
      case 'video':
        return Colors.purple;
      case 'lab_guide':
        return AppTheme.lightTheme.colorScheme.secondary;
      case 'textbook':
        return Colors.green;
      default:
        return AppTheme.lightTheme.colorScheme.outline;
    }
  }
}
