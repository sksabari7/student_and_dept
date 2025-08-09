import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FloatingActionMenu extends StatefulWidget {
  final Function(String) onActionSelected;

  const FloatingActionMenu({super.key, required this.onActionSelected});

  @override
  State<FloatingActionMenu> createState() => _FloatingActionMenuState();
}

class _FloatingActionMenuState extends State<FloatingActionMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        if (_isExpanded)
          GestureDetector(
            onTap: _toggleMenu,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withValues(alpha: 0.3),
            ),
          ),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ..._buildMenuItems(),
            SizedBox(height: 2.h),
            FloatingActionButton(
              onPressed: _toggleMenu,
              backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
              child: AnimatedRotation(
                turns: _isExpanded ? 0.125 : 0,
                duration: const Duration(milliseconds: 300),
                child: CustomIconWidget(
                  iconName: _isExpanded ? 'close' : 'add',
                  color: AppTheme.lightTheme.colorScheme.onSecondary,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildMenuItems() {
    final menuItems = [
      {
        'id': 'mark_attendance',
        'title': 'Mark Attendance',
        'icon': 'how_to_reg',
        'color': const Color(0xFF4CAF50),
      },
      {
        'id': 'share_resource',
        'title': 'Share Resource',
        'icon': 'share',
        'color': const Color(0xFF2196F3),
      },
      {
        'id': 'send_message',
        'title': 'Send Message',
        'icon': 'message',
        'color': const Color(0xFFFF9800),
      },
    ];

    return menuItems
        .asMap()
        .entries
        .map((entry) {
          final index = entry.key;
          final item = entry.value;

          return AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final slideAnimation = Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: _animation,
                  curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut),
                ),
              );

              final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: _animation,
                  curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut),
                ),
              );

              return SlideTransition(
                position: slideAnimation,
                child: FadeTransition(
                  opacity: fadeAnimation,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 2.h),
                    child: _buildMenuItem(item),
                  ),
                ),
              );
            },
          );
        })
        .toList()
        .reversed
        .toList();
  }

  Widget _buildMenuItem(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        _toggleMenu();
        widget.onActionSelected(item['id'] as String);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lightTheme.colorScheme.shadow.withValues(
                    alpha: 0.2,
                  ),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              item['title'] as String,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Container(
            width: 14.w,
            height: 14.w,
            decoration: BoxDecoration(
              color: item['color'] as Color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (item['color'] as Color).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: item['icon'] as String,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
