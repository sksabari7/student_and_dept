import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/floating_action_menu.dart';
import './widgets/quick_actions_grid.dart';
import './widgets/recent_uploads_section.dart';
import './widgets/today_schedule_card.dart';
import './widgets/weather_header.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentDayIndex = 0;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  // Mock data for teacher dashboard
  final List<Map<String, dynamic>> _weekSchedule = [
    {
      "date": "Monday, August 9, 2025",
      "classes": [
        {
          "time": "09:00",
          "subject": "Mathematics",
          "room": "Room 101",
          "students": 32,
          "duration": "1 hour",
        },
        {
          "time": "11:00",
          "subject": "Physics",
          "room": "Lab 201",
          "students": 28,
          "duration": "2 hours",
        },
        {
          "time": "14:00",
          "subject": "Computer Science",
          "room": "Computer Lab",
          "students": 25,
          "duration": "1.5 hours",
        },
      ],
    },
    {
      "date": "Tuesday, August 10, 2025",
      "classes": [
        {
          "time": "10:00",
          "subject": "Chemistry",
          "room": "Lab 301",
          "students": 30,
          "duration": "2 hours",
        },
        {
          "time": "13:00",
          "subject": "Mathematics",
          "room": "Room 102",
          "students": 35,
          "duration": "1 hour",
        },
      ],
    },
    {"date": "Wednesday, August 11, 2025", "classes": []},
    {
      "date": "Thursday, August 12, 2025",
      "classes": [
        {
          "time": "09:30",
          "subject": "Physics",
          "room": "Room 201",
          "students": 28,
          "duration": "1 hour",
        },
        {
          "time": "11:30",
          "subject": "Computer Science",
          "room": "Computer Lab",
          "students": 22,
          "duration": "2 hours",
        },
      ],
    },
    {
      "date": "Friday, August 13, 2025",
      "classes": [
        {
          "time": "08:00",
          "subject": "Mathematics",
          "room": "Room 101",
          "students": 32,
          "duration": "1 hour",
        },
        {
          "time": "10:00",
          "subject": "Chemistry",
          "room": "Lab 301",
          "students": 29,
          "duration": "1.5 hours",
        },
        {
          "time": "15:00",
          "subject": "Physics",
          "room": "Lab 201",
          "students": 26,
          "duration": "2 hours",
        },
      ],
    },
  ];

  final List<Map<String, dynamic>> _recentUploads = [
    {
      "title": "Calculus Question Paper - Mid Term",
      "subject": "Mathematics",
      "type": "question_paper",
      "downloads": 45,
      "rating": 4.8,
      "uploadDate": "Aug 8",
      "status": "Active",
    },
    {
      "title": "Physics Lab Manual - Optics",
      "subject": "Physics",
      "type": "lab_guide",
      "downloads": 32,
      "rating": 4.6,
      "uploadDate": "Aug 7",
      "status": "Active",
    },
    {
      "title": "Programming Assignment Guidelines",
      "subject": "Computer Science",
      "type": "doc",
      "downloads": 28,
      "rating": 4.9,
      "uploadDate": "Aug 6",
      "status": "Active",
    },
    {
      "title": "Chemistry Practical Notes",
      "subject": "Chemistry",
      "type": "pdf",
      "downloads": 21,
      "rating": 4.5,
      "uploadDate": "Aug 5",
      "status": "Pending",
    },
    {
      "title": "Mathematics Video Lecture Series",
      "subject": "Mathematics",
      "type": "video",
      "downloads": 67,
      "rating": 4.7,
      "uploadDate": "Aug 4",
      "status": "Active",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _currentDayIndex = DateTime.now().weekday - 1;
    if (_currentDayIndex >= _weekSchedule.length) {
      _currentDayIndex = 0;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDashboardTab(),
                  _buildTimetableTab(),
                  _buildResourcesTab(),
                  _buildStudentsTab(),
                  _buildProfileTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionMenu(
        onActionSelected: _handleFloatingAction,
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppTheme.lightTheme.colorScheme.surface,
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Dashboard'),
          Tab(text: 'Timetable'),
          Tab(text: 'Resources'),
          Tab(text: 'Students'),
          Tab(text: 'Profile'),
        ],
        isScrollable: false,
        indicatorColor: AppTheme.lightTheme.colorScheme.primary,
        labelColor: AppTheme.lightTheme.colorScheme.primary,
        unselectedLabelColor: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        labelStyle: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: AppTheme.lightTheme.textTheme.labelMedium
            ?.copyWith(fontWeight: FontWeight.w400),
      ),
    );
  }

  Widget _buildDashboardTab() {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WeatherHeader(
              currentDate: "August 9, 2025",
              currentDay: "Monday",
              weatherInfo: "Sunny",
              temperature: "24°C",
            ),
            TodayScheduleCard(
              scheduleData: _weekSchedule,
              onDayChanged: (index) {
                setState(() {
                  _currentDayIndex = index;
                });
              },
              currentDayIndex: _currentDayIndex,
            ),
            QuickActionsGrid(onActionTap: _handleQuickAction),
            RecentUploadsSection(
              recentUploads: _recentUploads,
              onUploadTap: _handleUploadTap,
            ),
            SizedBox(height: 10.h), // Space for floating action button
          ],
        ),
      ),
    );
  }

  Widget _buildTimetableTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'schedule',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 64,
          ),
          SizedBox(height: 2.h),
          Text(
            'Timetable Management',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Manage your class schedules and timetables',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/timetable-management');
            },
            child: const Text('Open Timetable'),
          ),
        ],
      ),
    );
  }

  Widget _buildResourcesTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'library_books',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 64,
          ),
          SizedBox(height: 2.h),
          Text(
            'Resource Library',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Access and manage your teaching resources',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/resource-library');
            },
            child: const Text('Open Library'),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'group',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 64,
          ),
          SizedBox(height: 2.h),
          Text(
            'Student Management',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'View and manage student information',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/student-dashboard');
            },
            child: const Text('View Students'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'person',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 64,
          ),
          SizedBox(height: 2.h),
          Text(
            'Profile Management',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Manage your profile and account settings',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/user-profile-management');
            },
            child: const Text('Open Profile'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 2));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'refresh',
              color: AppTheme.lightTheme.colorScheme.onInverseSurface,
              size: 16,
            ),
            SizedBox(width: 2.w),
            const Text('Dashboard refreshed'),
          ],
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(4.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _handleQuickAction(String actionId) {
    switch (actionId) {
      case 'upload_question':
        _showUploadQuestionDialog();
        break;
      case 'share_lab_guide':
        _showShareLabGuideDialog();
        break;
      case 'create_announcement':
        _showCreateAnnouncementDialog();
        break;
      case 'view_attendance':
        _showAttendanceBottomSheet();
        break;
    }
  }

  void _handleFloatingAction(String actionId) {
    switch (actionId) {
      case 'mark_attendance':
        _showMarkAttendanceDialog();
        break;
      case 'share_resource':
        _showShareResourceDialog();
        break;
      case 'send_message':
        _showSendMessageDialog();
        break;
    }
  }

  void _handleUploadTap(Map<String, dynamic> upload) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
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
                        upload['title'] as String,
                        style: AppTheme.lightTheme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        '${upload['subject']} • ${upload['downloads']} downloads • ${upload['rating']} rating',
                        style: AppTheme.lightTheme.textTheme.bodySmall
                            ?.copyWith(
                              color:
                                  AppTheme
                                      .lightTheme
                                      .colorScheme
                                      .onSurfaceVariant,
                            ),
                      ),
                      SizedBox(height: 3.h),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('View Details'),
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pushNamed(
                                  context,
                                  '/resource-library',
                                );
                              },
                              child: const Text('Edit Resource'),
                            ),
                          ),
                        ],
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

  void _showUploadQuestionDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Upload Question Paper'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select a question paper to upload for your students.',
                ),
                SizedBox(height: 2.h),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/resource-library');
                  },
                  icon: CustomIconWidget(
                    iconName: 'upload_file',
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                    size: 20,
                  ),
                  label: const Text('Choose File'),
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

  void _showShareLabGuideDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Share Lab Guide'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Share lab guides and practical manuals with students.',
                ),
                SizedBox(height: 2.h),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/resource-library');
                  },
                  icon: CustomIconWidget(
                    iconName: 'science',
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                    size: 20,
                  ),
                  label: const Text('Select Guide'),
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

  void _showCreateAnnouncementDialog() {
    final TextEditingController announcementController =
        TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Create Announcement'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Send an announcement to your students.'),
                SizedBox(height: 2.h),
                TextField(
                  controller: announcementController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Type your announcement here...',
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
                    const SnackBar(
                      content: Text('Announcement sent to students'),
                    ),
                  );
                },
                child: const Text('Send'),
              ),
            ],
          ),
    );
  }

  void _showAttendanceBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => Container(
            height: 60.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Column(
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
                  child: Row(
                    children: [
                      Text(
                        'Attendance Overview',
                        style: AppTheme.lightTheme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.all(4.w),
                    children: [
                      _buildAttendanceCard(
                        'Mathematics',
                        '32/35 Present',
                        '91%',
                      ),
                      _buildAttendanceCard('Physics', '28/30 Present', '93%'),
                      _buildAttendanceCard(
                        'Computer Science',
                        '25/25 Present',
                        '100%',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildAttendanceCard(
    String subject,
    String attendance,
    String percentage,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  attendance,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.secondary.withValues(
                alpha: 0.2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              percentage,
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMarkAttendanceDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Mark Attendance'),
            content: const Text('Select a class to mark attendance for today.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Attendance marked successfully'),
                    ),
                  );
                },
                child: const Text('Mark Attendance'),
              ),
            ],
          ),
    );
  }

  void _showShareResourceDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Share Resource'),
            content: const Text(
              'Choose a resource to share with your students.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/resource-library');
                },
                child: const Text('Select Resource'),
              ),
            ],
          ),
    );
  }

  void _showSendMessageDialog() {
    final TextEditingController messageController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Send Message'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Send a message to your students.'),
                SizedBox(height: 2.h),
                TextField(
                  controller: messageController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Type your message here...',
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
                    const SnackBar(content: Text('Message sent to students')),
                  );
                },
                child: const Text('Send'),
              ),
            ],
          ),
    );
  }
}
