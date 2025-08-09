import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/resource_section_widget.dart';
import './widgets/search_filter_widget.dart';
import './widgets/upload_modal_widget.dart';

class ResourceLibrary extends StatefulWidget {
  const ResourceLibrary({super.key});

  @override
  State<ResourceLibrary> createState() => _ResourceLibraryState();
}

class _ResourceLibraryState extends State<ResourceLibrary>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  List<String> _selectedFilters = [];
  List<String> _recentSearches = [
    'Physics Notes',
    'Chemistry Lab',
    'Math Problems',
  ];
  bool _isRefreshing = false;
  String _userRole = 'Teacher'; // Mock user role - in real app, get from auth

  // Mock data for different resource sections
  final Map<String, List<Map<String, dynamic>>> _resourceSections = {
    'Question Papers': [
      {
        'id': '1',
        'title': 'Mathematics Final Exam 2024',
        'fileType': 'pdf',
        'uploadDate': '08/05/2024',
        'size': '2.1 MB',
        'isDownloaded': true,
        'isDownloading': false,
        'downloadProgress': 1.0,
        'subject': 'Mathematics',
        'faculty': 'Dr. Smith',
      },
      {
        'id': '2',
        'title': 'Physics Midterm Questions',
        'fileType': 'pdf',
        'uploadDate': '08/01/2024',
        'size': '1.8 MB',
        'isDownloaded': false,
        'isDownloading': false,
        'downloadProgress': 0.0,
        'subject': 'Physics',
        'faculty': 'Prof. Johnson',
      },
      {
        'id': '3',
        'title': 'Chemistry Practical Exam',
        'fileType': 'pdf',
        'uploadDate': '07/28/2024',
        'size': '3.2 MB',
        'isDownloaded': false,
        'isDownloading': true,
        'downloadProgress': 0.65,
        'subject': 'Chemistry',
        'faculty': 'Dr. Wilson',
      },
    ],
    'Lab Guides': [
      {
        'id': '4',
        'title': 'Organic Chemistry Lab Manual',
        'fileType': 'pdf',
        'uploadDate': '08/03/2024',
        'size': '5.4 MB',
        'isDownloaded': true,
        'isDownloading': false,
        'downloadProgress': 1.0,
        'subject': 'Chemistry',
        'faculty': 'Dr. Wilson',
      },
      {
        'id': '5',
        'title': 'Physics Experiments Guide',
        'fileType': 'doc',
        'uploadDate': '07/30/2024',
        'size': '2.9 MB',
        'isDownloaded': false,
        'isDownloading': false,
        'downloadProgress': 0.0,
        'subject': 'Physics',
        'faculty': 'Prof. Johnson',
      },
    ],
    'Textbooks': [
      {
        'id': '6',
        'title': 'Advanced Calculus - Chapter 5',
        'fileType': 'pdf',
        'uploadDate': '08/07/2024',
        'size': '8.1 MB',
        'isDownloaded': false,
        'isDownloading': false,
        'downloadProgress': 0.0,
        'subject': 'Mathematics',
        'faculty': 'Dr. Smith',
      },
      {
        'id': '7',
        'title': 'Modern Physics Textbook',
        'fileType': 'pdf',
        'uploadDate': '08/04/2024',
        'size': '12.3 MB',
        'isDownloaded': true,
        'isDownloading': false,
        'downloadProgress': 1.0,
        'subject': 'Physics',
        'faculty': 'Prof. Johnson',
      },
    ],
    'Announcements': [
      {
        'id': '8',
        'title': 'Semester Schedule Update',
        'fileType': 'pdf',
        'uploadDate': '08/09/2024',
        'size': '0.5 MB',
        'isDownloaded': false,
        'isDownloading': false,
        'downloadProgress': 0.0,
        'subject': 'General',
        'faculty': 'Admin',
      },
      {
        'id': '9',
        'title': 'Lab Safety Guidelines',
        'fileType': 'doc',
        'uploadDate': '08/08/2024',
        'size': '1.2 MB',
        'isDownloaded': true,
        'isDownloading': false,
        'downloadProgress': 1.0,
        'subject': 'General',
        'faculty': 'Admin',
      },
    ],
  };

  // Track expanded sections
  final Map<String, bool> _expandedSections = {
    'Question Papers': true,
    'Lab Guides': false,
    'Textbooks': false,
    'Announcements': false,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredResources(String section) {
    List<Map<String, dynamic>> resources = _resourceSections[section] ?? [];

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      resources =
          resources.where((resource) {
            final title = (resource['title'] as String? ?? '').toLowerCase();
            final subject =
                (resource['subject'] as String? ?? '').toLowerCase();
            final faculty =
                (resource['faculty'] as String? ?? '').toLowerCase();
            final query = _searchQuery.toLowerCase();

            return title.contains(query) ||
                subject.contains(query) ||
                faculty.contains(query);
          }).toList();
    }

    // Apply selected filters
    if (_selectedFilters.isNotEmpty) {
      resources =
          resources.where((resource) {
            return _selectedFilters.any((filter) {
              if (filter.startsWith('subject_')) {
                final subject = filter.replaceFirst('subject_', '');
                return (resource['subject'] as String? ?? '').toLowerCase() ==
                    subject;
              }
              if (filter.startsWith('type_')) {
                final type = filter.replaceFirst('type_', '');
                return (resource['fileType'] as String? ?? '').toLowerCase() ==
                    type;
              }
              if (filter.startsWith('faculty_')) {
                final faculty = filter.replaceFirst('faculty_', '');
                return (resource['faculty'] as String? ?? '').toLowerCase() ==
                    faculty;
              }
              return false;
            });
          }).toList();
    }

    return resources;
  }

  String _getLastUpdated(String section) {
    final resources = _resourceSections[section] ?? [];
    if (resources.isEmpty) return 'No updates';

    // Get the most recent upload date
    DateTime? latestDate;
    for (final resource in resources) {
      final dateStr = resource['uploadDate'] as String? ?? '';
      try {
        final parts = dateStr.split('/');
        if (parts.length == 3) {
          final date = DateTime(
            int.parse(parts[2]),
            int.parse(parts[0]),
            int.parse(parts[1]),
          );
          if (latestDate == null || date.isAfter(latestDate)) {
            latestDate = date;
          }
        }
      } catch (e) {
        // Invalid date format, skip
      }
    }

    if (latestDate == null) return 'Unknown';

    final now = DateTime.now();
    final difference = now.difference(latestDate);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${(difference.inDays / 7).floor()} weeks ago';
    }
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate refresh delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'refresh',
              color: Theme.of(context).colorScheme.onInverseSurface,
              size: 16,
            ),
            SizedBox(width: 2.w),
            const Text('Resources updated'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleResourceTap(Map<String, dynamic> resource) {
    final isDownloaded = resource['isDownloaded'] as bool? ?? false;
    final isDownloading = resource['isDownloading'] as bool? ?? false;

    if (isDownloaded) {
      _openResource(resource);
    } else if (!isDownloading) {
      _downloadResource(resource);
    }
  }

  void _handleResourceLongPress(Map<String, dynamic> resource) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildContextMenu(resource),
    );
  }

  void _openResource(Map<String, dynamic> resource) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${resource['title']}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _downloadResource(Map<String, dynamic> resource) {
    // Find the resource in the sections and update its download status
    for (final section in _resourceSections.keys) {
      final resources = _resourceSections[section]!;
      final index = resources.indexWhere((r) => r['id'] == resource['id']);
      if (index != -1) {
        setState(() {
          resources[index]['isDownloading'] = true;
          resources[index]['downloadProgress'] = 0.0;
        });

        // Simulate download progress
        _simulateDownload(section, index);
        break;
      }
    }
  }

  void _simulateDownload(String section, int index) async {
    final resources = _resourceSections[section]!;

    for (double progress = 0.0; progress <= 1.0; progress += 0.1) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        setState(() {
          resources[index]['downloadProgress'] = progress;
        });
      }
    }

    if (mounted) {
      setState(() {
        resources[index]['isDownloading'] = false;
        resources[index]['isDownloaded'] = true;
        resources[index]['downloadProgress'] = 1.0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Downloaded ${resources[index]['title']}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showUploadModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => UploadModalWidget(
            onFileUploaded: (file) {
              // Add to appropriate section based on category
              final category = file['category'] as String;
              if (_resourceSections.containsKey(category)) {
                setState(() {
                  _resourceSections[category]!.insert(0, file);
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${file['title']} uploaded successfully'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            onClose: () => Navigator.pop(context),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resource Library'),
        elevation: 0,
        scrolledUnderElevation: 1,
        actions: [
          IconButton(
            onPressed: () {
              // Navigate to notifications
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifications feature coming soon'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: Stack(
              children: [
                CustomIconWidget(
                  iconName: 'notifications_outlined',
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 24,
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  Navigator.pushNamed(context, '/user-profile-management');
                  break;
                case 'settings':
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Settings feature coming soon'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  break;
                case 'help':
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Help feature coming soon'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  break;
              }
            },
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
        ],
      ),
      body: Column(
        children: [
          SearchFilterWidget(
            searchQuery: _searchQuery,
            onSearchChanged: (query) {
              setState(() {
                _searchQuery = query;
              });

              // Add to recent searches if not empty and not already present
              if (query.isNotEmpty && !_recentSearches.contains(query)) {
                setState(() {
                  _recentSearches.insert(0, query);
                  if (_recentSearches.length > 10) {
                    _recentSearches.removeLast();
                  }
                });
              }
            },
            selectedFilters: _selectedFilters,
            onFiltersChanged: (filters) {
              setState(() {
                _selectedFilters = filters;
              });
            },
            recentSearches: _recentSearches,
            onRecentSearchTap: (search) {
              setState(() {
                _searchQuery = search;
              });
            },
            onClearRecentSearches: () {
              setState(() {
                _recentSearches.clear();
              });
            },
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              child: ListView.builder(
                padding: EdgeInsets.only(bottom: 10.h),
                itemCount: _resourceSections.keys.length,
                itemBuilder: (context, index) {
                  final section = _resourceSections.keys.elementAt(index);
                  final filteredResources = _getFilteredResources(section);
                  final isExpanded = _expandedSections[section] ?? false;

                  return ResourceSectionWidget(
                    title: section,
                    itemCount: filteredResources.length,
                    lastUpdated: _getLastUpdated(section),
                    resources: filteredResources,
                    isExpanded: isExpanded,
                    onToggle: () {
                      setState(() {
                        _expandedSections[section] = !isExpanded;
                      });
                    },
                    onResourceTap: _handleResourceTap,
                    onResourceLongPress: _handleResourceLongPress,
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton:
          (_userRole == 'Teacher' || _userRole == 'Admin')
              ? FloatingActionButton.extended(
                onPressed: _showUploadModal,
                icon: CustomIconWidget(
                  iconName: 'add',
                  color: Theme.of(context).colorScheme.onSecondary,
                  size: 24,
                ),
                label: const Text('Upload'),
                backgroundColor: Theme.of(context).colorScheme.secondary,
              )
              : null,
    );
  }

  Widget _buildContextMenu(Map<String, dynamic> resource) {
    final isDownloaded = resource['isDownloaded'] as bool? ?? false;

    return Container(
      margin: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.symmetric(vertical: 3.w),
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
            title: const Text('Share'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Sharing ${resource['title']}'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          ListTile(
            leading: CustomIconWidget(
              iconName: 'favorite_border',
              color: Theme.of(context).colorScheme.secondary,
              size: 24,
            ),
            title: const Text('Mark Favorite'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Added ${resource['title']} to favorites'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          if (isDownloaded)
            ListTile(
              leading: CustomIconWidget(
                iconName: 'delete_outline',
                color: Theme.of(context).colorScheme.error,
                size: 24,
              ),
              title: const Text('Remove Download'),
              onTap: () {
                Navigator.pop(context);
                // Find and update the resource
                for (final section in _resourceSections.keys) {
                  final resources = _resourceSections[section]!;
                  final index = resources.indexWhere(
                    (r) => r['id'] == resource['id'],
                  );
                  if (index != -1) {
                    setState(() {
                      resources[index]['isDownloaded'] = false;
                      resources[index]['downloadProgress'] = 0.0;
                    });
                    break;
                  }
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Removed ${resource['title']} from device'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ListTile(
            leading: CustomIconWidget(
              iconName: 'report_outlined',
              color: Theme.of(context).colorScheme.error,
              size: 24,
            ),
            title: const Text('Report Issue'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Reported issue with ${resource['title']}'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}
