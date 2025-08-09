import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TodayScheduleCard extends StatefulWidget {
  final List<Map<String, dynamic>> scheduleData;
  final Function(int) onDayChanged;
  final int currentDayIndex;

  const TodayScheduleCard({
    super.key,
    required this.scheduleData,
    required this.onDayChanged,
    required this.currentDayIndex,
  });

  @override
  State<TodayScheduleCard> createState() => _TodayScheduleCardState();
}

class _TodayScheduleCardState extends State<TodayScheduleCard> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.currentDayIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(
            height: 25.h,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                widget.onDayChanged(index);
              },
              itemCount: widget.scheduleData.length,
              itemBuilder: (context, index) {
                return _buildScheduleContent(widget.scheduleData[index]);
              },
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final currentSchedule = widget.scheduleData[widget.currentDayIndex];
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'schedule',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 24,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's Schedule",
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  currentSchedule["date"] as String,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/timetable-management');
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'View All',
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleContent(Map<String, dynamic> daySchedule) {
    final classes = daySchedule["classes"] as List<Map<String, dynamic>>;

    if (classes.isEmpty) {
      return _buildEmptySchedule();
    }

    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${classes.length} Classes Today',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 2.h),
          Expanded(
            child: ListView.separated(
              itemCount: classes.length > 3 ? 3 : classes.length,
              separatorBuilder: (context, index) => SizedBox(height: 1.h),
              itemBuilder: (context, index) {
                return _buildClassItem(classes[index]);
              },
            ),
          ),
          if (classes.length > 3)
            Center(
              child: Text(
                '+${classes.length - 3} more classes',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildClassItem(Map<String, dynamic> classData) {
    return GestureDetector(
      onLongPress: () => _showClassContextMenu(classData),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest
              .withValues(
            alpha: 0.5,
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(
              width: 3,
              color: _getSubjectColor(classData["subject"] as String),
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 12.w,
              height: 6.h,
              decoration: BoxDecoration(
                color: _getSubjectColor(
                  classData["subject"] as String,
                ).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  classData["time"] as String,
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: _getSubjectColor(classData["subject"] as String),
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    classData["subject"] as String,
                    style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'location_on',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 14,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        classData["room"] as String,
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      CustomIconWidget(
                        iconName: 'group',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 14,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        '${classData["students"]} students',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'chevron_right',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySchedule() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'event_available',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 48,
          ),
          SizedBox(height: 2.h),
          Text(
            'No Classes Today',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Enjoy your free day!',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          widget.scheduleData.length,
          (index) => Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index == widget.currentDayIndex
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.outline.withValues(
                      alpha: 0.3,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getSubjectColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
      case 'math':
        return const Color(0xFF2196F3);
      case 'physics':
        return const Color(0xFF9C27B0);
      case 'chemistry':
        return const Color(0xFF4CAF50);
      case 'biology':
        return const Color(0xFF8BC34A);
      case 'computer science':
      case 'programming':
        return const Color(0xFF607D8B);
      case 'english':
        return const Color(0xFFFF9800);
      case 'history':
        return const Color(0xFF795548);
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }

  void _showClassContextMenu(Map<String, dynamic> classData) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    classData["subject"] as String,
                    style: AppTheme.lightTheme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    '${classData["time"]} • ${classData["room"]}',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  _buildContextMenuItem(
                    icon: 'cancel',
                    title: 'Cancel Class',
                    onTap: () {
                      Navigator.pop(context);
                      _showCancelClassDialog(classData);
                    },
                  ),
                  _buildContextMenuItem(
                    icon: 'schedule',
                    title: 'Reschedule',
                    onTap: () {
                      Navigator.pop(context);
                      _showRescheduleDialog(classData);
                    },
                  ),
                  _buildContextMenuItem(
                    icon: 'note_add',
                    title: 'Add Notes',
                    onTap: () {
                      Navigator.pop(context);
                      _showAddNotesDialog(classData);
                    },
                  ),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContextMenuItem({
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CustomIconWidget(
        iconName: icon,
        color: AppTheme.lightTheme.colorScheme.onSurface,
        size: 24,
      ),
      title: Text(title, style: AppTheme.lightTheme.textTheme.bodyMedium),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showCancelClassDialog(Map<String, dynamic> classData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Class'),
        content: Text(
          'Are you sure you want to cancel ${classData["subject"]} class?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${classData["subject"]} class cancelled'),
                  backgroundColor: AppTheme.lightTheme.colorScheme.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: const Text('Cancel Class'),
          ),
        ],
      ),
    );
  }

  void _showRescheduleDialog(Map<String, dynamic> classData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reschedule Class'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Reschedule ${classData["subject"]} class'),
            SizedBox(height: 2.h),
            ElevatedButton(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${classData["subject"]} class rescheduled',
                      ),
                      backgroundColor:
                          AppTheme.lightTheme.colorScheme.secondary,
                    ),
                  );
                }
              },
              child: const Text('Select New Date'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showAddNotesDialog(Map<String, dynamic> classData) {
    final TextEditingController notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Notes'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add notes for ${classData["subject"]} class'),
            SizedBox(height: 2.h),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter your notes here...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Notes added for ${classData["subject"]}'),
                  backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
                ),
              );
            },
            child: const Text('Save Notes'),
          ),
        ],
      ),
    );
  }
}
