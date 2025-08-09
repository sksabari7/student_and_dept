import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ResourceSectionWidget extends StatefulWidget {
  final String title;
  final int itemCount;
  final String lastUpdated;
  final List<Map<String, dynamic>> resources;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Function(Map<String, dynamic>) onResourceTap;
  final Function(Map<String, dynamic>) onResourceLongPress;

  const ResourceSectionWidget({
    super.key,
    required this.title,
    required this.itemCount,
    required this.lastUpdated,
    required this.resources,
    required this.isExpanded,
    required this.onToggle,
    required this.onResourceTap,
    required this.onResourceLongPress,
  });

  @override
  State<ResourceSectionWidget> createState() => _ResourceSectionWidgetState();
}

class _ResourceSectionWidgetState extends State<ResourceSectionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    if (widget.isExpanded) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(ResourceSectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildSectionHeader(),
          AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) {
              return ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: _expandAnimation.value,
                  child: child,
                ),
              );
            },
            child: _buildResourceList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return InkWell(
      onTap: widget.onToggle,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.title,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 0.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${widget.itemCount}',
                          style: Theme.of(
                            context,
                          ).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    'Last updated: ${widget.lastUpdated}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedRotation(
              turns: widget.isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 300),
              child: CustomIconWidget(
                iconName: 'keyboard_arrow_down',
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceList() {
    if (widget.resources.isEmpty) {
      return Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: 'folder_open',
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              size: 48,
            ),
            SizedBox(height: 2.h),
            Text(
              'No resources available',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      itemCount: widget.resources.length,
      separatorBuilder:
          (context, index) => Divider(
            height: 1,
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
      itemBuilder: (context, index) {
        final resource = widget.resources[index];
        return _buildResourceItem(resource);
      },
    );
  }

  Widget _buildResourceItem(Map<String, dynamic> resource) {
    final isDownloaded = resource['isDownloaded'] as bool? ?? false;
    final isDownloading = resource['isDownloading'] as bool? ?? false;
    final downloadProgress = resource['downloadProgress'] as double? ?? 0.0;

    return InkWell(
      onTap: () => widget.onResourceTap(resource),
      onLongPress: () => widget.onResourceLongPress(resource),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        child: Row(
          children: [
            _buildFileTypeIcon(resource['fileType'] as String? ?? 'pdf'),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resource['title'] as String? ?? 'Untitled',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      Text(
                        resource['uploadDate'] as String? ?? 'Unknown date',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (resource['size'] != null) ...[
                        Text(
                          ' • ${resource['size']}',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (isDownloading) ...[
                    SizedBox(height: 1.h),
                    LinearProgressIndicator(
                      value: downloadProgress,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 2.w),
            _buildDownloadStatus(isDownloaded, isDownloading),
          ],
        ),
      ),
    );
  }

  Widget _buildFileTypeIcon(String fileType) {
    String iconName;
    Color iconColor;

    switch (fileType.toLowerCase()) {
      case 'pdf':
        iconName = 'picture_as_pdf';
        iconColor = Colors.red;
        break;
      case 'doc':
      case 'docx':
        iconName = 'description';
        iconColor = Colors.blue;
        break;
      case 'ppt':
      case 'pptx':
        iconName = 'slideshow';
        iconColor = Colors.orange;
        break;
      case 'xls':
      case 'xlsx':
        iconName = 'table_chart';
        iconColor = Colors.green;
        break;
      case 'txt':
        iconName = 'text_snippet';
        iconColor = Theme.of(context).colorScheme.onSurfaceVariant;
        break;
      case 'video':
      case 'mp4':
        iconName = 'play_circle_outline';
        iconColor = Colors.purple;
        break;
      default:
        iconName = 'insert_drive_file';
        iconColor = Theme.of(context).colorScheme.onSurfaceVariant;
    }

    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomIconWidget(iconName: iconName, color: iconColor, size: 24),
    );
  }

  Widget _buildDownloadStatus(bool isDownloaded, bool isDownloading) {
    if (isDownloading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    if (isDownloaded) {
      return Container(
        padding: EdgeInsets.all(1.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: CustomIconWidget(
          iconName: 'offline_pin',
          color: Theme.of(context).colorScheme.secondary,
          size: 16,
        ),
      );
    }

    return CustomIconWidget(
      iconName: 'cloud_download',
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      size: 20,
    );
  }
}
