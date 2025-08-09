import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/add_class_modal.dart';
import './widgets/class_details_sheet.dart';
import './widgets/edit_class_modal.dart';
import './widgets/timetable_grid_widget.dart';
import './widgets/week_selector_widget.dart';

class TimetableManagement extends StatefulWidget {
  const TimetableManagement({super.key});

  @override
  State<TimetableManagement> createState() => _TimetableManagementState();
}

class _TimetableManagementState extends State<TimetableManagement> {
  DateTime selectedWeek = DateTime.now();
  String userRole =
      'Admin'; // Mock user role - in real app, get from auth service
  bool isLoading = false;
  bool isOffline = false;

  // Mock timetable data
  List<Map<String, dynamic>> timetableData = [
    {
      'id': '1',
      'subject': 'Mathematics',
      'teacher': 'Dr. Sarah Johnson',
      'day': 'Monday',
      'time': '9:00 AM',
      'room': 'Room 101',
      'duration': '1 hour',
      'description': 'Advanced Calculus - Integration techniques',
      'createdAt': '2025-08-09T10:00:00.000Z',
    },
    {
      'id': '2',
      'subject': 'Physics',
      'teacher': 'Prof. Michael Chen',
      'day': 'Monday',
      'time': '11:00 AM',
      'room': 'Lab A',
      'duration': '2 hours',
      'description': 'Quantum Mechanics Laboratory',
      'createdAt': '2025-08-09T10:00:00.000Z',
    },
    {
      'id': '3',
      'subject': 'Chemistry',
      'teacher': 'Dr. Emily Rodriguez',
      'day': 'Tuesday',
      'time': '10:00 AM',
      'room': 'Lab B',
      'duration': '1.5 hours',
      'description': 'Organic Chemistry Synthesis',
      'createdAt': '2025-08-09T10:00:00.000Z',
    },
    {
      'id': '4',
      'subject': 'Biology',
      'teacher': 'Prof. David Wilson',
      'day': 'Tuesday',
      'time': '2:00 PM',
      'room': 'Room 201',
      'duration': '1 hour',
      'description': 'Cell Biology and Genetics',
      'createdAt': '2025-08-09T10:00:00.000Z',
    },
    {
      'id': '5',
      'subject': 'English',
      'teacher': 'Dr. Lisa Anderson',
      'day': 'Wednesday',
      'time': '9:00 AM',
      'room': 'Room 102',
      'duration': '1 hour',
      'description': 'Modern Literature Analysis',
      'createdAt': '2025-08-09T10:00:00.000Z',
    },
    {
      'id': '6',
      'subject': 'Computer Science',
      'teacher': 'Prof. James Thompson',
      'day': 'Wednesday',
      'time': '1:00 PM',
      'room': 'Lab A',
      'duration': '2 hours',
      'description': 'Data Structures and Algorithms',
      'createdAt': '2025-08-09T10:00:00.000Z',
    },
    {
      'id': '7',
      'subject': 'History',
      'teacher': 'Dr. Maria Garcia',
      'day': 'Thursday',
      'time': '10:00 AM',
      'room': 'Room 201',
      'duration': '1 hour',
      'description': 'World War II Historical Analysis',
      'createdAt': '2025-08-09T10:00:00.000Z',
    },
    {
      'id': '8',
      'subject': 'Economics',
      'teacher': 'Prof. Robert Taylor',
      'day': 'Thursday',
      'time': '3:00 PM',
      'room': 'Room 102',
      'duration': '1 hour',
      'description': 'Macroeconomic Theory',
      'createdAt': '2025-08-09T10:00:00.000Z',
    },
    {
      'id': '9',
      'subject': 'Psychology',
      'teacher': 'Dr. Jennifer Lee',
      'day': 'Friday',
      'time': '11:00 AM',
      'room': 'Room 201',
      'duration': '1 hour',
      'description': 'Cognitive Psychology Research',
      'createdAt': '2025-08-09T10:00:00.000Z',
    },
    {
      'id': '10',
      'subject': 'Geography',
      'teacher': 'Prof. Christopher Brown',
      'day': 'Friday',
      'time': '2:00 PM',
      'room': 'Room 102',
      'duration': '1 hour',
      'description': 'Climate Change and Environmental Impact',
      'createdAt': '2025-08-09T10:00:00.000Z',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadTimetableData();
  }

  Future<void> _loadTimetableData() async {
    setState(() => isLoading = true);

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 800));

    // In real app, load data from API or local database
    // Check network connectivity and handle offline mode

    setState(() {
      isLoading = false;
      isOffline = false; // Set based on actual connectivity check
    });
  }

  Future<void> _refreshTimetable() async {
    await _loadTimetableData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              CustomIconWidget(
                iconName: 'refresh',
                color: Colors.white,
                size: 16,
              ),
              SizedBox(width: 2.w),
              const Text('Timetable refreshed'),
            ],
          ),
          backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _handleWeekChange(DateTime newWeek) {
    setState(() => selectedWeek = newWeek);
    _loadTimetableData();
  }

  void _jumpToToday() {
    setState(() => selectedWeek = DateTime.now());
    _loadTimetableData();
  }

  void _handleSlotTap(Map<String, dynamic> classData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => ClassDetailsSheet(
            classData: classData,
            userRole: userRole,
            onEdit: () {
              Navigator.pop(context);
              _showEditClassModal(classData);
            },
            onCancel: () {
              Navigator.pop(context);
              _showCancelClassDialog(classData);
            },
          ),
    );
  }

  void _handleSlotLongPress(Map<String, dynamic> classData) {
    if (userRole == 'Admin' || userRole == 'Teacher') {
      _showEditClassModal(classData);
    }
  }

  void _showAddClassModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddClassModal(onClassAdded: _handleClassAdded),
    );
  }

  void _showEditClassModal(Map<String, dynamic> classData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => EditClassModal(
            classData: classData,
            onClassUpdated: _handleClassUpdated,
          ),
    );
  }

  void _handleClassAdded(Map<String, dynamic> newClass) {
    setState(() {
      timetableData.add(newClass);
    });

    // In real app, sync with backend API
    _syncWithBackend();
  }

  void _handleClassUpdated(Map<String, dynamic> updatedClass) {
    setState(() {
      final index = timetableData.indexWhere(
        (item) => (item['id'] as String) == (updatedClass['id'] as String),
      );
      if (index != -1) {
        timetableData[index] = updatedClass;
      }
    });

    // In real app, sync with backend API
    _syncWithBackend();
  }

  void _showCancelClassDialog(Map<String, dynamic> classData) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                CustomIconWidget(
                  iconName: 'warning',
                  color: AppTheme.lightTheme.colorScheme.error,
                  size: 24,
                ),
                SizedBox(width: 2.w),
                const Text('Cancel Class'),
              ],
            ),
            content: Text(
              'Are you sure you want to cancel ${classData['subject']} class on ${classData['day']} at ${classData['time']}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Keep Class'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleClassCancelled(classData);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lightTheme.colorScheme.error,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Cancel Class'),
              ),
            ],
          ),
    );
  }

  void _handleClassCancelled(Map<String, dynamic> classData) {
    setState(() {
      timetableData.removeWhere(
        (item) => (item['id'] as String) == (classData['id'] as String),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(iconName: 'cancel', color: Colors.white, size: 16),
            SizedBox(width: 2.w),
            const Text('Class cancelled successfully'),
          ],
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );

    // In real app, sync with backend API and send notifications
    _syncWithBackend();
  }

  Future<void> _syncWithBackend() async {
    // In real app, implement actual backend synchronization
    // Send push notifications to affected users
    // Handle offline queue for changes made without internet
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable Management'),
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (isOffline)
            Container(
              margin: EdgeInsets.only(right: 2.w),
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.error.withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'wifi_off',
                    color: AppTheme.lightTheme.colorScheme.error,
                    size: 16,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    'Offline',
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          IconButton(
            icon: CustomIconWidget(
              iconName: 'refresh',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: _refreshTimetable,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshTimetable,
        child: Column(
          children: [
            WeekSelectorWidget(
              selectedWeek: selectedWeek,
              onWeekChanged: _handleWeekChange,
              onTodayPressed: _jumpToToday,
            ),
            Expanded(
              child:
                  isLoading
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: AppTheme.lightTheme.colorScheme.primary,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Loading timetable...',
                              style: AppTheme.lightTheme.textTheme.bodyMedium
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
                      )
                      : Padding(
                        padding: EdgeInsets.all(4.w),
                        child: TimetableGridWidget(
                          timetableData: timetableData,
                          userRole: userRole,
                          onSlotTap: _handleSlotTap,
                          onSlotLongPress: _handleSlotLongPress,
                        ),
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          (userRole == 'Admin' || userRole == 'Teacher')
              ? FloatingActionButton.extended(
                onPressed: _showAddClassModal,
                backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
                foregroundColor: Colors.white,
                icon: CustomIconWidget(
                  iconName: 'add',
                  color: Colors.white,
                  size: 24,
                ),
                label: const Text('Add Class'),
              )
              : null,
    );
  }
}
