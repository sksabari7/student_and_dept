import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom AppBar widget implementing Contemporary Academic Minimalism
/// Provides consistent navigation structure for educational mobile applications
/// with adaptive behavior and clean visual hierarchy
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// The title to display in the app bar
  final String title;

  /// Whether to show the back button (defaults to true when there's a previous route)
  final bool showBackButton;

  /// Custom leading widget (overrides back button if provided)
  final Widget? leading;

  /// List of action widgets to display on the right side
  final List<Widget>? actions;

  /// Whether to center the title (defaults to false for academic minimalism)
  final bool centerTitle;

  /// Background color override (uses theme color if null)
  final Color? backgroundColor;

  /// Foreground color override (uses theme color if null)
  final Color? foregroundColor;

  /// Elevation override (uses theme elevation if null)
  final double? elevation;

  /// App bar variant for different contexts
  final AppBarVariant variant;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.leading,
    this.actions,
    this.centerTitle = false,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.variant = AppBarVariant.standard,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine colors based on variant and theme
    Color? effectiveBackgroundColor;
    Color? effectiveForegroundColor;
    double? effectiveElevation;

    switch (variant) {
      case AppBarVariant.standard:
        effectiveBackgroundColor =
            backgroundColor ?? theme.appBarTheme.backgroundColor;
        effectiveForegroundColor =
            foregroundColor ?? theme.appBarTheme.foregroundColor;
        effectiveElevation = elevation ?? 0;
        break;
      case AppBarVariant.elevated:
        effectiveBackgroundColor = backgroundColor ?? colorScheme.surface;
        effectiveForegroundColor = foregroundColor ?? colorScheme.onSurface;
        effectiveElevation = elevation ?? 3;
        break;
      case AppBarVariant.transparent:
        effectiveBackgroundColor = backgroundColor ?? Colors.transparent;
        effectiveForegroundColor = foregroundColor ?? colorScheme.onSurface;
        effectiveElevation = elevation ?? 0;
        break;
      case AppBarVariant.primary:
        effectiveBackgroundColor = backgroundColor ?? colorScheme.primary;
        effectiveForegroundColor = foregroundColor ?? colorScheme.onPrimary;
        effectiveElevation = elevation ?? 1;
        break;
    }

    return AppBar(
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: effectiveForegroundColor,
          letterSpacing: 0,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: effectiveBackgroundColor,
      foregroundColor: effectiveForegroundColor,
      elevation: effectiveElevation,
      scrolledUnderElevation:
          effectiveElevation != null ? effectiveElevation + 1 : null,
      leading: _buildLeading(context),
      actions: _buildActions(context),
      iconTheme: IconThemeData(color: effectiveForegroundColor, size: 24),
      actionsIconTheme: IconThemeData(
        color: effectiveForegroundColor,
        size: 24,
      ),
    );
  }

  /// Builds the leading widget with navigation logic
  Widget? _buildLeading(BuildContext context) {
    if (leading != null) {
      return leading;
    }

    if (showBackButton && Navigator.of(context).canPop()) {
      return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
        tooltip: 'Back',
      );
    }

    // For root screens, show menu icon for drawer access
    if (Scaffold.of(context).hasDrawer) {
      return IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () => Scaffold.of(context).openDrawer(),
        tooltip: 'Menu',
      );
    }

    return null;
  }

  /// Builds action widgets with common educational app actions
  List<Widget>? _buildActions(BuildContext context) {
    if (actions != null) {
      return actions;
    }

    // Default actions for educational context
    return [
      IconButton(
        icon: const Icon(Icons.notifications_outlined),
        onPressed: () {
          // Navigate to notifications or show notification panel
          _showNotificationPanel(context);
        },
        tooltip: 'Notifications',
      ),
      PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert),
        tooltip: 'More options',
        onSelected: (value) => _handleMenuAction(context, value),
        itemBuilder:
            (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: ListTile(
                  leading: Icon(Icons.person_outline),
                  title: Text('Profile'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings_outlined),
                  title: Text('Settings'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'help',
                child: ListTile(
                  leading: Icon(Icons.help_outline),
                  title: Text('Help'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
      ),
    ];
  }

  /// Shows notification panel as bottom sheet
  void _showNotificationPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
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
                    color: Theme.of(context).colorScheme.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        'Notifications',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
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
                    padding: const EdgeInsets.all(16),
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          child: const Icon(
                            Icons.assignment,
                            color: Colors.white,
                          ),
                        ),
                        title: const Text('New assignment posted'),
                        subtitle: const Text('Mathematics - Due tomorrow'),
                        trailing: const Text('2h ago'),
                      ),
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          child: const Icon(
                            Icons.schedule,
                            color: Colors.white,
                          ),
                        ),
                        title: const Text('Schedule updated'),
                        subtitle: const Text('Physics class moved to Room 201'),
                        trailing: const Text('4h ago'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  /// Handles menu action selection
  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'profile':
        Navigator.pushNamed(context, '/user-profile-management');
        break;
      case 'settings':
        // Navigate to settings or show settings dialog
        _showSettingsDialog(context);
        break;
      case 'help':
        // Navigate to help or show help dialog
        _showHelpDialog(context);
        break;
    }
  }

  /// Shows settings dialog
  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Settings'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Dark Mode'),
                  trailing: Switch(
                    value: Theme.of(context).brightness == Brightness.dark,
                    onChanged: (value) {
                      // Toggle theme
                      Navigator.pop(context);
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Notifications'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to notification settings
                  },
                ),
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

  /// Shows help dialog
  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Help & Support'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Need assistance? Here are some quick options:'),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.book_outlined),
                  title: const Text('User Guide'),
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to user guide
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.contact_support_outlined),
                  title: const Text('Contact Support'),
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to contact support
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.feedback_outlined),
                  title: const Text('Send Feedback'),
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to feedback form
                  },
                ),
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

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Enum defining different app bar variants for various contexts
enum AppBarVariant {
  /// Standard app bar with theme colors
  standard,

  /// Elevated app bar with shadow
  elevated,

  /// Transparent app bar for overlay contexts
  transparent,

  /// Primary colored app bar for emphasis
  primary,
}
