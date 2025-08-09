import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_tab_bar.dart';
import './widgets/academic_progress_widget.dart';
import './widgets/quick_access_bottom_sheet.dart';
import './widgets/quick_access_grid_widget.dart';
import './widgets/recent_downloads_widget.dart';
import './widgets/today_classes_widget.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  // Mock data for student dashboard
  final List<Map<String, dynamic>> _todayClasses = [
    {
      "id": 1,
      "subject": "Data Structures & Algorithms",
      "faculty": "Dr. Sarah Johnson",
      "time": "09:00 - 10:30 AM",
      "room": "CS-201",
      "building": "Computer Science",
      "floor": "2nd Floor",
      "email": "sarah.johnson@college.edu",
      "office": "CS-Faculty-15",
      "officeHours": "2:00 - 4:00 PM",
      "startTime": "2025-08-09T09:00:00.000Z",
      "type": "Lecture",
    },
    {
      "id": 2,
      "subject": "Database Management Systems",
      "faculty": "Prof. Michael Chen",
      "time": "11:00 - 12:30 PM",
      "room": "CS-105",
      "building": "Computer Science",
      "floor": "1st Floor",
      "email": "michael.chen@college.edu",
      "office": "CS-Faculty-08",
      "officeHours": "10:00 AM - 12:00 PM",
      "startTime": "2025-08-09T11:00:00.000Z",
      "type": "Lab",
    },
    {
      "id": 3,
      "subject": "Software Engineering",
      "faculty": "Dr. Emily Rodriguez",
      "time": "02:00 - 03:30 PM",
      "room": "CS-301",
      "building": "Computer Science",
      "floor": "3rd Floor",
      "email": "emily.rodriguez@college.edu",
      "office": "CS-Faculty-22",
      "officeHours": "1:00 - 3:00 PM",
      "startTime": "2025-08-09T14:00:00.000Z",
      "type": "Lecture",
    },
  ];

  final List<Map<String, dynamic>> _recentDownloads = [
    {
      "id": 1,
      "name": "DSA_Chapter_5_Trees.pdf",
      "subject": "Data Structures",
      "type": "PDF",
      "size": "2.4 MB",
      "downloadDate": "Today",
      "isOffline": true,
      "url": "https://example.com/dsa_chapter5.pdf",
    },
    {
      "id": 2,
      "name": "DBMS_Lab_Guide_Week_8.pdf",
      "subject": "Database Systems",
      "type": "Lab_Guide",
      "size": "1.8 MB",
      "downloadDate": "Yesterday",
      "isOffline": true,
      "url": "https://example.com/dbms_lab_guide.pdf",
    },
    {
      "id": 3,
      "name": "SE_Project_Requirements.docx",
      "subject": "Software Engineering",
      "type": "DOC",
      "size": "856 KB",
      "downloadDate": "2 days ago",
      "isOffline": false,
      "url": "https://example.com/se_project_req.docx",
    },
    {
      "id": 4,
      "name": "Computer_Networks_Textbook.pdf",
      "subject": "Computer Networks",
      "type": "Textbook",
      "size": "15.2 MB",
      "downloadDate": "3 days ago",
      "isOffline": true,
      "url": "https://example.com/cn_textbook.pdf",
    },
  ];

  final List<Map<String, dynamic>> _announcements = [
    {
      "id": 1,
      "title": "Mid-term Examination Schedule Released",
      "content":
          "The mid-term examination schedule for all subjects has been released. Please check your timetable for exam dates and venues.",
      "date": "2025-08-09",
      "priority": "high",
      "department": "Computer Science",
      "isRead": false,
    },
    {
      "id": 2,
      "title": "Library Hours Extended During Exam Week",
      "content":
          "The college library will remain open 24/7 during the examination week to support student preparation.",
      "date": "2025-08-08",
      "priority": "medium",
      "department": "General",
      "isRead": true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this, initialIndex: 0);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            CustomTabBar(
              tabs: const [
                'Dashboard',
                'Timetable',
                'Resources',
                'Announcements',
                'Profile',
              ],
              currentIndex: _currentTabIndex,
              onTap: (index) {
                _tabController.animateTo(index);
              },
              controller: _tabController,
              variant: TabBarVariant.standard,
            ),
            Expanded(
              child: CustomTabBarView(
                controller: _tabController,
                children: [
                  _buildDashboardTab(),
                  _buildTimetableTab(),
                  _buildResourcesTab(),
                  _buildAnnouncementsTab(),
                  _buildProfileTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          _currentTabIndex == 0 ? _buildFloatingActionButton() : null,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, Alex!',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Computer Science Engineering',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap:
                () => Navigator.pushNamed(context, '/user-profile-management'),
            child: CircleAvatar(
              radius: 6.w,
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
              child: CustomImageWidget(
                imageUrl:
                    "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
                width: 12.w,
                height: 12.w,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AcademicProgressWidget(
              gpa: 3.75,
              semester: 'Semester 6 - Spring 2025',
              progressPercentage: 75.0,
            ),
            SizedBox(height: 3.h),
            TodayClassesWidget(
              todayClasses: _todayClasses,
              onViewFullTimetable:
                  () => Navigator.pushNamed(context, '/timetable-management'),
            ),
            SizedBox(height: 3.h),
            QuickAccessGridWidget(onTileTap: _handleQuickAccessTap),
            SizedBox(height: 3.h),
            RecentDownloadsWidget(
              recentDownloads: _recentDownloads,
              onDownloadTap: _handleDownloadTap,
            ),
            SizedBox(height: 10.h), // Extra space for FAB
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
            size: 64,
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
          SizedBox(height: 2.h),
          Text(
            'Timetable View',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Navigate to full timetable management',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 3.h),
          ElevatedButton(
            onPressed:
                () => Navigator.pushNamed(context, '/timetable-management'),
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
            size: 64,
            color: AppTheme.lightTheme.colorScheme.secondary,
          ),
          SizedBox(height: 2.h),
          Text(
            'Resource Library',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Access study materials and resources',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 3.h),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/resource-library'),
            child: const Text('Open Library'),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementsTab() {
    return ListView.separated(
      padding: EdgeInsets.all(4.w),
      itemCount: _announcements.length,
      separatorBuilder: (context, index) => SizedBox(height: 2.h),
      itemBuilder: (context, index) {
        final announcement = _announcements[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        announcement['title'] as String,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (!(announcement['isRead'] as bool))
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 1.h),
                Text(
                  announcement['content'] as String,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 1.h),
                Row(
                  children: [
                    Text(
                      announcement['department'] as String,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      announcement['date'] as String,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 15.w,
            backgroundColor: AppTheme.lightTheme.colorScheme.primary,
            child: CustomImageWidget(
              imageUrl:
                  "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
              width: 30.w,
              height: 30.w,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'Alex Johnson',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Computer Science Engineering',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 3.h),
          ElevatedButton(
            onPressed:
                () => Navigator.pushNamed(context, '/user-profile-management'),
            child: const Text('Manage Profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _showQuickAccessBottomSheet,
      icon: CustomIconWidget(
        iconName: 'dashboard',
        size: 24,
        color: Colors.white,
      ),
      label: const Text('Quick Access'),
      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      foregroundColor: Colors.white,
    );
  }

  void _showQuickAccessBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) =>
              QuickAccessBottomSheet(onActionTap: _handleQuickAccessTap),
    );
  }

  void _handleQuickAccessTap(String action) {
    switch (action) {
      case 'resources':
        Navigator.pushNamed(context, '/resource-library');
        break;
      case 'announcements':
        _tabController.animateTo(3);
        break;
      case 'attendance':
        _showAttendanceDialog();
        break;
      case 'library':
        Navigator.pushNamed(context, '/resource-library');
        break;
      case 'timetable':
        Navigator.pushNamed(context, '/timetable-management');
        break;
      case 'profile':
        Navigator.pushNamed(context, '/user-profile-management');
        break;
    }
  }

  void _handleDownloadTap(Map<String, dynamic> download) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(download['name'] as String),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Subject: ${download['subject']}'),
                SizedBox(height: 1.h),
                Text('Size: ${download['size']}'),
                SizedBox(height: 1.h),
                Text('Downloaded: ${download['downloadDate']}'),
                SizedBox(height: 1.h),
                Row(
                  children: [
                    CustomIconWidget(
                      iconName:
                          download['isOffline'] as bool
                              ? 'offline_pin'
                              : 'cloud_download',
                      size: 16,
                      color:
                          download['isOffline'] as bool
                              ? AppTheme.lightTheme.colorScheme.secondary
                              : AppTheme.lightTheme.colorScheme.outline,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      download['isOffline'] as bool
                          ? 'Available Offline'
                          : 'Online Only',
                      style: TextStyle(
                        color:
                            download['isOffline'] as bool
                                ? AppTheme.lightTheme.colorScheme.secondary
                                : AppTheme.lightTheme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _openDownload(download);
                },
                child: const Text('Open'),
              ),
            ],
          ),
    );
  }

  void _openDownload(Map<String, dynamic> download) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${download['name']}...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAttendanceDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Attendance Summary'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAttendanceRow('Data Structures', '92%', Colors.green),
                _buildAttendanceRow('Database Systems', '88%', Colors.green),
                _buildAttendanceRow(
                  'Software Engineering',
                  '76%',
                  Colors.orange,
                ),
                _buildAttendanceRow('Computer Networks', '68%', Colors.red),
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

  Widget _buildAttendanceRow(String subject, String percentage, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              subject,
              style: TextStyle(fontSize: 12.sp),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              percentage,
              style: TextStyle(
                fontSize: 12.sp,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dashboard refreshed successfully'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
