import 'package:flutter/material.dart';
import '../presentation/timetable_management/timetable_management.dart';
import '../presentation/teacher_dashboard/teacher_dashboard.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/resource_library/resource_library.dart';
import '../presentation/user_profile_management/user_profile_management.dart';
import '../presentation/student_dashboard/student_dashboard.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String timetableManagement = '/timetable-management';
  static const String teacherDashboard = '/teacher-dashboard';
  static const String login = '/login-screen';
  static const String resourceLibrary = '/resource-library';
  static const String userProfileManagement = '/user-profile-management';
  static const String studentDashboard = '/student-dashboard';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const LoginScreen(),
    timetableManagement: (context) => const TimetableManagement(),
    teacherDashboard: (context) => const TeacherDashboard(),
    login: (context) => const LoginScreen(),
    resourceLibrary: (context) => const ResourceLibrary(),
    userProfileManagement: (context) => const UserProfileManagement(),
    studentDashboard: (context) => const StudentDashboard(),
    // TODO: Add your other routes here
  };
}
