import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/account_section.dart';
import './widgets/profile_form_section.dart';
import './widgets/profile_photo_section.dart';
import './widgets/settings_section.dart';

class UserProfileManagement extends StatefulWidget {
  const UserProfileManagement({super.key});

  @override
  State<UserProfileManagement> createState() => _UserProfileManagementState();
}

class _UserProfileManagementState extends State<UserProfileManagement>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Mock user data
  final Map<String, dynamic> _mockUserData = {
    "id": 1,
    "name": "Sarah Johnson",
    "email": "sarah.johnson@university.edu",
    "mobile": "+1 (555) 123-4567",
    "department": "Computer Science",
    "role": "Student",
    "profilePhoto":
        "https://images.unsplash.com/photo-1494790108755-2616b612b786?w=400&h=400&fit=crop&crop=face",
    "lastLogin": "2025-08-09T14:30:00Z",
    "activeSessions": 2,
  };

  Map<String, dynamic> _currentProfileData = {};
  bool _hasProfileChanges = false;

  final Map<String, bool> _mockSettingsData = {
    "darkMode": false,
    "pushNotifications": true,
    "offlineSync": true,
    "biometricLogin": false,
  };

  Map<String, bool> _currentSettingsData = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _currentProfileData = Map.from(_mockUserData);
    _currentSettingsData = Map.from(_mockSettingsData);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onProfileDataChanged(Map<String, dynamic> newData) {
    setState(() {
      _currentProfileData = newData;
      _hasProfileChanges = _hasDataChanged(_mockUserData, newData);
    });
  }

  void _onSettingsChanged(Map<String, bool> newSettings) {
    setState(() {
      _currentSettingsData = newSettings;
    });
  }

  void _onPhotoChanged(String? photoPath) {
    setState(() {
      _currentProfileData['profilePhoto'] = photoPath;
      _hasProfileChanges = true;
    });
  }

  bool _hasDataChanged(
    Map<String, dynamic> original,
    Map<String, dynamic> current,
  ) {
    return original['name'] != current['name'] ||
        original['email'] != current['email'] ||
        original['mobile'] != current['mobile'] ||
        original['department'] != current['department'] ||
        original['profilePhoto'] != current['profilePhoto'];
  }

  Widget _buildTabContent(int index) {
    switch (index) {
      case 0:
        return SingleChildScrollView(
          child: Column(
            children: [
              ProfilePhotoSection(
                currentPhotoUrl: _currentProfileData['profilePhoto'],
                onPhotoChanged: _onPhotoChanged,
              ),
              ProfileFormSection(
                profileData: _currentProfileData,
                onDataChanged: _onProfileDataChanged,
                hasChanges: _hasProfileChanges,
              ),
            ],
          ),
        );
      case 1:
        return SingleChildScrollView(
          child: SettingsSection(
            settingsData: _currentSettingsData,
            onSettingsChanged: _onSettingsChanged,
          ),
        );
      case 2:
        return SingleChildScrollView(
          child: AccountSection(parentContext: context),
        );
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(
        title: 'Profile',
        showBackButton: true,
        actions: [
          IconButton(
            onPressed: () {
              // Show profile menu
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder:
                    (context) => Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 40,
                            height: 4,
                            margin: EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.outline,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          ListTile(
                            leading: CustomIconWidget(
                              iconName: 'share',
                              color: Theme.of(context).colorScheme.primary,
                              size: 24,
                            ),
                            title: Text('Share Profile'),
                            onTap: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Profile sharing coming soon'),
                                ),
                              );
                            },
                          ),
                          ListTile(
                            leading: CustomIconWidget(
                              iconName: 'qr_code',
                              color: Theme.of(context).colorScheme.secondary,
                              size: 24,
                            ),
                            title: Text('QR Code'),
                            onTap: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'QR code generation coming soon',
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).padding.bottom,
                          ),
                        ],
                      ),
                    ),
              );
            },
            icon: CustomIconWidget(
              iconName: 'more_vert',
              color: Theme.of(context).colorScheme.onSurface,
              size: 24,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'person',
                        color:
                            _tabController.index == 0
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text('Profile'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'settings',
                        color:
                            _tabController.index == 1
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text('Settings'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'security',
                        color:
                            _tabController.index == 2
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text('Account'),
                    ],
                  ),
                ),
              ],
              indicatorColor: Theme.of(context).colorScheme.primary,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor:
                  Theme.of(context).colorScheme.onSurfaceVariant,
              onTap: (index) {
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTabContent(0),
                _buildTabContent(1),
                _buildTabContent(2),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton:
          _hasProfileChanges
              ? FloatingActionButton.extended(
                onPressed: () {
                  // Save all changes
                  setState(() {
                    _hasProfileChanges = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'cloud_done',
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text('All changes saved successfully'),
                        ],
                      ),
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                  );
                },
                icon: CustomIconWidget(
                  iconName: 'save',
                  color: Theme.of(context).colorScheme.onSecondary,
                  size: 20,
                ),
                label: Text('Save All'),
                backgroundColor: Theme.of(context).colorScheme.secondary,
              )
              : null,
    );
  }
}
