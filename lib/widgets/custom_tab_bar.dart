import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom TabBar widget implementing Contemporary Academic Minimalism
/// Provides consistent tab navigation optimized for educational mobile applications
/// with clean visual hierarchy and purposeful interactions
class CustomTabBar extends StatefulWidget implements PreferredSizeWidget {
  /// List of tab labels
  final List<String> tabs;

  /// Current selected tab index
  final int currentIndex;

  /// Callback when tab is selected
  final ValueChanged<int> onTap;

  /// Tab bar variant for different contexts
  final TabBarVariant variant;

  /// Whether tabs are scrollable (defaults to false)
  final bool isScrollable;

  /// Custom indicator color override
  final Color? indicatorColor;

  /// Custom selected label color override
  final Color? selectedLabelColor;

  /// Custom unselected label color override
  final Color? unselectedLabelColor;

  /// Custom background color override
  final Color? backgroundColor;

  /// Indicator weight (thickness)
  final double indicatorWeight;

  /// Tab controller for external control
  final TabController? controller;

  const CustomTabBar({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
    this.variant = TabBarVariant.standard,
    this.isScrollable = false,
    this.indicatorColor,
    this.selectedLabelColor,
    this.unselectedLabelColor,
    this.backgroundColor,
    this.indicatorWeight = 2.0,
    this.controller,
  });

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();

  @override
  Size get preferredSize => const Size.fromHeight(48.0);
}

class _CustomTabBarState extends State<CustomTabBar>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isControllerInternal = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _tabController = widget.controller!;
    } else {
      _tabController = TabController(
        length: widget.tabs.length,
        vsync: this,
        initialIndex: widget.currentIndex,
      );
      _isControllerInternal = true;
    }

    _tabController.addListener(_handleTabChange);
  }

  @override
  void didUpdateWidget(CustomTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      if (_isControllerInternal) {
        _tabController.removeListener(_handleTabChange);
        _tabController.dispose();
      }

      if (widget.controller != null) {
        _tabController = widget.controller!;
        _isControllerInternal = false;
      } else {
        _tabController = TabController(
          length: widget.tabs.length,
          vsync: this,
          initialIndex: widget.currentIndex,
        );
        _isControllerInternal = true;
      }

      _tabController.addListener(_handleTabChange);
    }

    if (widget.currentIndex != oldWidget.currentIndex &&
        _tabController.index != widget.currentIndex) {
      _tabController.animateTo(widget.currentIndex);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    if (_isControllerInternal) {
      _tabController.dispose();
    }
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      widget.onTap(_tabController.index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine colors based on variant
    Color? effectiveIndicatorColor;
    Color? effectiveSelectedLabelColor;
    Color? effectiveUnselectedLabelColor;
    Color? effectiveBackgroundColor;

    switch (widget.variant) {
      case TabBarVariant.standard:
        effectiveIndicatorColor = widget.indicatorColor ?? colorScheme.primary;
        effectiveSelectedLabelColor =
            widget.selectedLabelColor ?? colorScheme.primary;
        effectiveUnselectedLabelColor =
            widget.unselectedLabelColor ?? colorScheme.onSurfaceVariant;
        effectiveBackgroundColor =
            widget.backgroundColor ?? colorScheme.surface;
        break;
      case TabBarVariant.primary:
        effectiveIndicatorColor =
            widget.indicatorColor ?? colorScheme.onPrimary;
        effectiveSelectedLabelColor =
            widget.selectedLabelColor ?? colorScheme.onPrimary;
        effectiveUnselectedLabelColor =
            widget.unselectedLabelColor ?? colorScheme.onPrimary.withAlpha(179);
        effectiveBackgroundColor =
            widget.backgroundColor ?? colorScheme.primary;
        break;
      case TabBarVariant.surface:
        effectiveIndicatorColor = widget.indicatorColor ?? colorScheme.primary;
        effectiveSelectedLabelColor =
            widget.selectedLabelColor ?? colorScheme.onSurface;
        effectiveUnselectedLabelColor =
            widget.unselectedLabelColor ?? colorScheme.onSurfaceVariant;
        effectiveBackgroundColor =
            widget.backgroundColor ?? colorScheme.surfaceContainerHighest;
        break;
      case TabBarVariant.transparent:
        effectiveIndicatorColor = widget.indicatorColor ?? colorScheme.primary;
        effectiveSelectedLabelColor =
            widget.selectedLabelColor ?? colorScheme.primary;
        effectiveUnselectedLabelColor =
            widget.unselectedLabelColor ?? colorScheme.onSurfaceVariant;
        effectiveBackgroundColor = widget.backgroundColor ?? Colors.transparent;
        break;
    }

    return Container(
      color: effectiveBackgroundColor,
      child: TabBar(
        controller: _tabController,
        tabs: widget.tabs.map((tab) => Tab(text: tab)).toList(),
        isScrollable: widget.isScrollable,
        indicatorColor: effectiveIndicatorColor,
        indicatorWeight: widget.indicatorWeight,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: effectiveSelectedLabelColor,
        unselectedLabelColor: effectiveUnselectedLabelColor,
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.1,
        ),
        labelPadding:
            widget.isScrollable
                ? const EdgeInsets.symmetric(horizontal: 16)
                : null,
        tabAlignment:
            widget.isScrollable ? TabAlignment.start : TabAlignment.fill,
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
      ),
    );
  }
}

/// Enum defining different tab bar variants for various contexts
enum TabBarVariant {
  /// Standard tab bar with theme colors
  standard,

  /// Primary colored tab bar for emphasis
  primary,

  /// Surface variant tab bar for subtle differentiation
  surface,

  /// Transparent tab bar for overlay contexts
  transparent,
}

/// Custom TabBarView wrapper for consistent behavior
class CustomTabBarView extends StatelessWidget {
  /// List of widgets to display in each tab
  final List<Widget> children;

  /// Tab controller for synchronization
  final TabController? controller;

  /// Physics for tab view scrolling
  final ScrollPhysics? physics;

  /// Whether to drag to switch tabs
  final bool dragStartBehavior;

  const CustomTabBarView({
    super.key,
    required this.children,
    this.controller,
    this.physics,
    this.dragStartBehavior = true,
  });

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: controller,
      physics:
          dragStartBehavior
              ? (physics ?? const ClampingScrollPhysics())
              : const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
}

/// Educational-specific tab configurations
class EducationalTabs {
  /// Common tab configurations for educational contexts

  /// Dashboard tabs for different views
  static const List<String> dashboardTabs = [
    'Overview',
    'Recent',
    'Upcoming',
    'Completed',
  ];

  /// Timetable tabs for different periods
  static const List<String> timetableTabs = ['Today', 'Week', 'Month'];

  /// Resource tabs for different categories
  static const List<String> resourceTabs = [
    'All',
    'Documents',
    'Videos',
    'Links',
  ];

  /// Profile tabs for different sections
  static const List<String> profileTabs = ['Info', 'Academic', 'Settings'];

  /// Assignment tabs for different states
  static const List<String> assignmentTabs = ['Pending', 'Submitted', 'Graded'];

  /// Grade tabs for different subjects
  static const List<String> gradeTabs = [
    'All Subjects',
    'Mathematics',
    'Science',
    'English',
  ];
}

/// Helper widget for creating common educational tab layouts
class EducationalTabLayout extends StatefulWidget {
  /// Type of educational tab layout
  final EducationalTabType tabType;

  /// Current selected index
  final int currentIndex;

  /// Callback when tab changes
  final ValueChanged<int> onTabChanged;

  /// List of widgets for each tab content
  final List<Widget> tabContent;

  /// Tab bar variant
  final TabBarVariant variant;

  /// Whether tabs are scrollable
  final bool isScrollable;

  const EducationalTabLayout({
    super.key,
    required this.tabType,
    required this.currentIndex,
    required this.onTabChanged,
    required this.tabContent,
    this.variant = TabBarVariant.standard,
    this.isScrollable = false,
  });

  @override
  State<EducationalTabLayout> createState() => _EducationalTabLayoutState();
}

class _EducationalTabLayoutState extends State<EducationalTabLayout>
    with TickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(
      length: _getTabsForType(widget.tabType).length,
      vsync: this,
      initialIndex: widget.currentIndex,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<String> _getTabsForType(EducationalTabType type) {
    switch (type) {
      case EducationalTabType.dashboard:
        return EducationalTabs.dashboardTabs;
      case EducationalTabType.timetable:
        return EducationalTabs.timetableTabs;
      case EducationalTabType.resources:
        return EducationalTabs.resourceTabs;
      case EducationalTabType.profile:
        return EducationalTabs.profileTabs;
      case EducationalTabType.assignments:
        return EducationalTabs.assignmentTabs;
      case EducationalTabType.grades:
        return EducationalTabs.gradeTabs;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _getTabsForType(widget.tabType);

    return Column(
      children: [
        CustomTabBar(
          tabs: tabs,
          currentIndex: widget.currentIndex,
          onTap: widget.onTabChanged,
          variant: widget.variant,
          isScrollable: widget.isScrollable,
          controller: _controller,
        ),
        Expanded(
          child: CustomTabBarView(
            controller: _controller,
            children: widget.tabContent,
          ),
        ),
      ],
    );
  }
}

/// Enum for educational tab types
enum EducationalTabType {
  dashboard,
  timetable,
  resources,
  profile,
  assignments,
  grades,
}
