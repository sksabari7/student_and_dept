import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom BottomNavigationBar widget implementing Contemporary Academic Minimalism
/// Provides consistent navigation structure optimized for educational mobile applications
/// with adaptive behavior and clean visual hierarchy
class CustomBottomBar extends StatefulWidget {
  /// Current selected index
  final int currentIndex;

  /// Callback when navigation item is tapped
  final ValueChanged<int> onTap;

  /// Bottom bar variant for different contexts
  final BottomBarVariant variant;

  /// Whether to show labels (defaults to true)
  final bool showLabels;

  /// Custom background color override
  final Color? backgroundColor;

  /// Custom selected item color override
  final Color? selectedItemColor;

  /// Custom unselected item color override
  final Color? unselectedItemColor;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.variant = BottomBarVariant.standard,
    this.showLabels = true,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
  });

  @override
  State<CustomBottomBar> createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar> {
  /// Navigation items for educational application
  List<BottomNavigationBarItem> get _navigationItems => [
    BottomNavigationBarItem(
      icon: const Icon(Icons.dashboard_outlined),
      activeIcon: const Icon(Icons.dashboard),
      label: 'Dashboard',
      tooltip: 'Go to Dashboard',
    ),
    BottomNavigationBarItem(
      icon: const Icon(Icons.schedule_outlined),
      activeIcon: const Icon(Icons.schedule),
      label: 'Timetable',
      tooltip: 'View Timetable',
    ),
    BottomNavigationBarItem(
      icon: const Icon(Icons.library_books_outlined),
      activeIcon: const Icon(Icons.library_books),
      label: 'Resources',
      tooltip: 'Access Resources',
    ),
    BottomNavigationBarItem(
      icon: const Icon(Icons.person_outline),
      activeIcon: const Icon(Icons.person),
      label: 'Profile',
      tooltip: 'View Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine colors based on variant
    Color? effectiveBackgroundColor;
    Color? effectiveSelectedColor;
    Color? effectiveUnselectedColor;

    switch (widget.variant) {
      case BottomBarVariant.standard:
        effectiveBackgroundColor =
            widget.backgroundColor ??
            theme.bottomNavigationBarTheme.backgroundColor;
        effectiveSelectedColor =
            widget.selectedItemColor ?? colorScheme.primary;
        effectiveUnselectedColor =
            widget.unselectedItemColor ?? colorScheme.onSurfaceVariant;
        break;
      case BottomBarVariant.elevated:
        effectiveBackgroundColor =
            widget.backgroundColor ?? colorScheme.surface;
        effectiveSelectedColor =
            widget.selectedItemColor ?? colorScheme.primary;
        effectiveUnselectedColor =
            widget.unselectedItemColor ?? colorScheme.onSurfaceVariant;
        break;
      case BottomBarVariant.transparent:
        effectiveBackgroundColor = widget.backgroundColor ?? Colors.transparent;
        effectiveSelectedColor =
            widget.selectedItemColor ?? colorScheme.primary;
        effectiveUnselectedColor =
            widget.unselectedItemColor ?? colorScheme.onSurfaceVariant;
        break;
    }

    return Container(
      decoration:
          widget.variant == BottomBarVariant.elevated
              ? BoxDecoration(
                color: effectiveBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withAlpha(26),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              )
              : null,
      child: BottomNavigationBar(
        currentIndex: widget.currentIndex,
        onTap: _handleNavigation,
        type: BottomNavigationBarType.fixed,
        backgroundColor:
            widget.variant != BottomBarVariant.elevated
                ? effectiveBackgroundColor
                : Colors.transparent,
        selectedItemColor: effectiveSelectedColor,
        unselectedItemColor: effectiveUnselectedColor,
        showSelectedLabels: widget.showLabels,
        showUnselectedLabels: widget.showLabels,
        elevation: widget.variant == BottomBarVariant.elevated ? 0 : 8,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
        ),
        selectedIconTheme: IconThemeData(
          size: 24,
          color: effectiveSelectedColor,
        ),
        unselectedIconTheme: IconThemeData(
          size: 24,
          color: effectiveUnselectedColor,
        ),
        items: _navigationItems,
      ),
    );
  }

  /// Handles navigation based on selected index
  void _handleNavigation(int index) {
    if (index == widget.currentIndex) {
      // If same tab is tapped, scroll to top or refresh
      _handleSameTabTap(index);
      return;
    }

    // Update current index
    widget.onTap(index);

    // Navigate to appropriate route
    switch (index) {
      case 0:
        _navigateToDashboard();
        break;
      case 1:
        Navigator.pushNamed(context, '/timetable-management');
        break;
      case 2:
        Navigator.pushNamed(context, '/resource-library');
        break;
      case 3:
        Navigator.pushNamed(context, '/user-profile-management');
        break;
    }
  }

  /// Handles same tab tap for scroll to top or refresh functionality
  void _handleSameTabTap(int index) {
    switch (index) {
      case 0:
        // Scroll to top of dashboard or refresh
        _showRefreshSnackBar('Dashboard refreshed');
        break;
      case 1:
        // Scroll to top of timetable or refresh
        _showRefreshSnackBar('Timetable refreshed');
        break;
      case 2:
        // Scroll to top of resources or refresh
        _showRefreshSnackBar('Resources refreshed');
        break;
      case 3:
        // Scroll to top of profile or refresh
        _showRefreshSnackBar('Profile refreshed');
        break;
    }
  }

  /// Navigates to appropriate dashboard based on user role
  void _navigateToDashboard() {
    // In a real app, you would determine user role from authentication state
    // For now, we'll default to student dashboard
    // You can implement role-based navigation here

    // Example role-based navigation:
    // final userRole = AuthService.getCurrentUserRole();
    // switch (userRole) {
    //   case UserRole.teacher:
    //     Navigator.pushNamed(context, '/teacher-dashboard');
    //     break;
    //   case UserRole.student:
    //   default:
    //     Navigator.pushNamed(context, '/student-dashboard');
    //     break;
    // }

    Navigator.pushNamed(context, '/student-dashboard');
  }

  /// Shows refresh snack bar for same tab taps
  void _showRefreshSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.refresh,
              color: Theme.of(context).colorScheme.onInverseSurface,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

/// Enum defining different bottom bar variants for various contexts
enum BottomBarVariant {
  /// Standard bottom bar with theme colors
  standard,

  /// Elevated bottom bar with shadow
  elevated,

  /// Transparent bottom bar for overlay contexts
  transparent,
}

/// Extension to provide adaptive bottom navigation
extension AdaptiveBottomBar on CustomBottomBar {
  /// Creates an adaptive bottom bar that switches to navigation rail on tablets
  static Widget adaptive({
    required BuildContext context,
    required int currentIndex,
    required ValueChanged<int> onTap,
    BottomBarVariant variant = BottomBarVariant.standard,
    bool showLabels = true,
    Color? backgroundColor,
    Color? selectedItemColor,
    Color? unselectedItemColor,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    if (isTablet) {
      return _AdaptiveNavigationRail(
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: backgroundColor,
        selectedItemColor: selectedItemColor,
        unselectedItemColor: unselectedItemColor,
      );
    }

    return CustomBottomBar(
      currentIndex: currentIndex,
      onTap: onTap,
      variant: variant,
      showLabels: showLabels,
      backgroundColor: backgroundColor,
      selectedItemColor: selectedItemColor,
      unselectedItemColor: unselectedItemColor,
    );
  }
}

/// Adaptive navigation rail for tablet layouts
class _AdaptiveNavigationRail extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;

  const _AdaptiveNavigationRail({
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return NavigationRail(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      backgroundColor:
          backgroundColor ?? theme.navigationRailTheme.backgroundColor,
      selectedIconTheme: IconThemeData(
        color: selectedItemColor ?? colorScheme.primary,
        size: 24,
      ),
      unselectedIconTheme: IconThemeData(
        color: unselectedItemColor ?? colorScheme.onSurfaceVariant,
        size: 24,
      ),
      selectedLabelTextStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: selectedItemColor ?? colorScheme.primary,
      ),
      unselectedLabelTextStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: unselectedItemColor ?? colorScheme.onSurfaceVariant,
      ),
      labelType: NavigationRailLabelType.all,
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: Text('Dashboard'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.schedule_outlined),
          selectedIcon: Icon(Icons.schedule),
          label: Text('Timetable'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.library_books_outlined),
          selectedIcon: Icon(Icons.library_books),
          label: Text('Resources'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: Text('Profile'),
        ),
      ],
    );
  }
}
