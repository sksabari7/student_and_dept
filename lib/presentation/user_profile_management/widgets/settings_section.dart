import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class SettingsSection extends StatefulWidget {
  final Map<String, bool> settingsData;
  final Function(Map<String, bool>) onSettingsChanged;

  const SettingsSection({
    super.key,
    required this.settingsData,
    required this.onSettingsChanged,
  });

  @override
  State<SettingsSection> createState() => _SettingsSectionState();
}

class _SettingsSectionState extends State<SettingsSection>
    with TickerProviderStateMixin {
  late Map<String, bool> _currentSettings;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _currentSettings = Map.from(widget.settingsData);
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateSetting(String key, bool value) {
    setState(() {
      _currentSettings[key] = value;
    });
    widget.onSettingsChanged(_currentSettings);

    HapticFeedback.lightImpact();
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required String iconName,
    required String settingKey,
    Color? iconColor,
  }) {
    final isEnabled = _currentSettings[settingKey] ?? false;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_animationController.value * 0.02),
          child: Container(
            margin: EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (iconColor ?? Theme.of(context).colorScheme.primary)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: iconName,
                  color: iconColor ?? Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              title: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: Switch(
                value: isEnabled,
                onChanged: (value) => _updateSetting(settingKey, value),
                activeColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'App Settings',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 24),
          _buildSettingTile(
            title: 'Dark Mode',
            subtitle: 'Switch between light and dark themes',
            iconName: 'dark_mode',
            settingKey: 'darkMode',
          ),
          _buildSettingTile(
            title: 'Push Notifications',
            subtitle: 'Receive updates and announcements',
            iconName: 'notifications',
            settingKey: 'pushNotifications',
            iconColor: Theme.of(context).colorScheme.secondary,
          ),
          _buildSettingTile(
            title: 'Offline Sync',
            subtitle: 'Download content for offline access',
            iconName: 'sync',
            settingKey: 'offlineSync',
            iconColor: Colors.orange,
          ),
          _buildSettingTile(
            title: 'Biometric Login',
            subtitle: 'Use fingerprint or face recognition',
            iconName: 'fingerprint',
            settingKey: 'biometricLogin',
            iconColor: Colors.green,
          ),
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'info',
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Settings sync across all your devices automatically',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
