import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class SearchFilterWidget extends StatefulWidget {
  final String searchQuery;
  final Function(String) onSearchChanged;
  final List<String> selectedFilters;
  final Function(List<String>) onFiltersChanged;
  final List<String> recentSearches;
  final Function(String) onRecentSearchTap;
  final VoidCallback onClearRecentSearches;

  const SearchFilterWidget({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.selectedFilters,
    required this.onFiltersChanged,
    required this.recentSearches,
    required this.onRecentSearchTap,
    required this.onClearRecentSearches,
  });

  @override
  State<SearchFilterWidget> createState() => _SearchFilterWidgetState();
}

class _SearchFilterWidgetState extends State<SearchFilterWidget> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _showRecentSearches = false;

  final List<Map<String, String>> _availableFilters = [
    {'key': 'subject_math', 'label': 'Mathematics'},
    {'key': 'subject_physics', 'label': 'Physics'},
    {'key': 'subject_chemistry', 'label': 'Chemistry'},
    {'key': 'subject_biology', 'label': 'Biology'},
    {'key': 'subject_english', 'label': 'English'},
    {'key': 'type_pdf', 'label': 'PDF'},
    {'key': 'type_doc', 'label': 'Document'},
    {'key': 'type_video', 'label': 'Video'},
    {'key': 'date_today', 'label': 'Today'},
    {'key': 'date_week', 'label': 'This Week'},
    {'key': 'date_month', 'label': 'This Month'},
    {'key': 'faculty_admin', 'label': 'Admin'},
    {'key': 'faculty_teacher', 'label': 'Teacher'},
  ];

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery;
    _searchFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.removeListener(_onFocusChange);
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _showRecentSearches =
          _searchFocusNode.hasFocus &&
          _searchController.text.isEmpty &&
          widget.recentSearches.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          _buildSearchBar(),
          if (_showRecentSearches) _buildRecentSearches(),
          _buildFilterChips(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              _searchFocusNode.hasFocus
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.3),
          width: _searchFocusNode.hasFocus ? 2 : 1,
        ),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: (value) {
          widget.onSearchChanged(value);
          setState(() {
            _showRecentSearches =
                value.isEmpty &&
                _searchFocusNode.hasFocus &&
                widget.recentSearches.isNotEmpty;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search resources...',
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.all(3.w),
            child: CustomIconWidget(
              iconName: 'search',
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      widget.onSearchChanged('');
                      setState(() {
                        _showRecentSearches =
                            _searchFocusNode.hasFocus &&
                            widget.recentSearches.isNotEmpty;
                      });
                    },
                    icon: CustomIconWidget(
                      iconName: 'clear',
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        ),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildRecentSearches() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextButton(
                onPressed: widget.onClearRecentSearches,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.5.h,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Clear',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children:
                widget.recentSearches.take(5).map((search) {
                  return InkWell(
                    onTap: () {
                      widget.onRecentSearchTap(search);
                      _searchController.text = search;
                      _searchFocusNode.unfocus();
                      setState(() {
                        _showRecentSearches = false;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 1.h,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomIconWidget(
                            iconName: 'history',
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            size: 16,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            search,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 6.h,
      margin: EdgeInsets.symmetric(vertical: 1.h),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: _availableFilters.length,
        separatorBuilder: (context, index) => SizedBox(width: 2.w),
        itemBuilder: (context, index) {
          final filter = _availableFilters[index];
          final isSelected = widget.selectedFilters.contains(filter['key']);

          return FilterChip(
            label: Text(
              filter['label']!,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color:
                    isSelected
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
            selected: isSelected,
            onSelected: (selected) {
              final newFilters = List<String>.from(widget.selectedFilters);
              if (selected) {
                newFilters.add(filter['key']!);
              } else {
                newFilters.remove(filter['key']);
              }
              widget.onFiltersChanged(newFilters);
            },
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            selectedColor: Theme.of(context).colorScheme.primary,
            checkmarkColor: Theme.of(context).colorScheme.onPrimary,
            side: BorderSide(
              color:
                  isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.3),
              width: 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          );
        },
      ),
    );
  }
}
