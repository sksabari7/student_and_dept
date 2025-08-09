import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ProfileFormSection extends StatefulWidget {
  final Map<String, dynamic> profileData;
  final Function(Map<String, dynamic>) onDataChanged;
  final bool hasChanges;

  const ProfileFormSection({
    super.key,
    required this.profileData,
    required this.onDataChanged,
    required this.hasChanges,
  });

  @override
  State<ProfileFormSection> createState() => _ProfileFormSectionState();
}

class _ProfileFormSectionState extends State<ProfileFormSection> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _mobileController;
  String? _selectedDepartment;
  String? _selectedRole;

  final List<String> _departments = [
    'Computer Science',
    'Information Technology',
    'Electronics',
    'Mechanical',
    'Civil',
    'Electrical',
    'Chemical',
    'Biotechnology',
  ];

  final List<String> _roles = ['Student', 'Teacher', 'Admin'];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(
      text: widget.profileData['name'] ?? '',
    );
    _emailController = TextEditingController(
      text: widget.profileData['email'] ?? '',
    );
    _mobileController = TextEditingController(
      text: widget.profileData['mobile'] ?? '',
    );
    _selectedDepartment = widget.profileData['department'];
    _selectedRole = widget.profileData['role'];

    _nameController.addListener(_onDataChanged);
    _emailController.addListener(_onDataChanged);
    _mobileController.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  void _onDataChanged() {
    final updatedData = {
      ...widget.profileData,
      'name': _nameController.text,
      'email': _emailController.text,
      'mobile': _mobileController.text,
      'department': _selectedDepartment,
      'role': _selectedRole,
    };
    widget.onDataChanged(updatedData);
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validateMobile(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile number is required';
    }
    final mobileRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
    if (!mobileRegex.hasMatch(value.trim())) {
      return 'Please enter a valid mobile number';
    }
    return null;
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    Widget? prefixIcon,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          readOnly: readOnly,
          decoration: InputDecoration(
            prefixIcon: prefixIcon,
            hintText: 'Enter $label',
            suffixIcon:
                readOnly
                    ? CustomIconWidget(
                      iconName: 'lock',
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 20,
                    )
                    : null,
          ),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color:
                readOnly
                    ? Theme.of(context).colorScheme.onSurfaceVariant
                    : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    Widget? prefixIcon,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: readOnly ? null : onChanged,
          decoration: InputDecoration(
            prefixIcon: prefixIcon,
            hintText: 'Select $label',
            suffixIcon:
                readOnly
                    ? CustomIconWidget(
                      iconName: 'lock',
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 20,
                    )
                    : null,
          ),
          items:
              items.map((String item) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '$label is required';
            }
            return null;
          },
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color:
                readOnly
                    ? Theme.of(context).colorScheme.onSurfaceVariant
                    : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 24),
            _buildTextField(
              label: 'Full Name',
              controller: _nameController,
              validator: _validateName,
              keyboardType: TextInputType.name,
              prefixIcon: CustomIconWidget(
                iconName: 'person',
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
            SizedBox(height: 20),
            _buildTextField(
              label: 'Email Address',
              controller: _emailController,
              validator: _validateEmail,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: CustomIconWidget(
                iconName: 'email',
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
            SizedBox(height: 20),
            _buildTextField(
              label: 'Mobile Number',
              controller: _mobileController,
              validator: _validateMobile,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d\s\-\(\)\+]')),
              ],
              prefixIcon: CustomIconWidget(
                iconName: 'phone',
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
            SizedBox(height: 20),
            _buildDropdownField(
              label: 'Department',
              value: _selectedDepartment,
              items: _departments,
              onChanged: (value) {
                setState(() {
                  _selectedDepartment = value;
                });
                _onDataChanged();
              },
              prefixIcon: CustomIconWidget(
                iconName: 'business',
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
            SizedBox(height: 20),
            _buildDropdownField(
              label: 'Role',
              value: _selectedRole,
              items: _roles,
              onChanged: (value) {
                setState(() {
                  _selectedRole = value;
                });
                _onDataChanged();
              },
              prefixIcon: CustomIconWidget(
                iconName: 'badge',
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),
              readOnly: true,
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed:
                    widget.hasChanges &&
                            _formKey.currentState?.validate() == true
                        ? () {
                          HapticFeedback.lightImpact();
                          // Save profile changes
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'check_circle',
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Profile updated successfully'),
                                ],
                              ),
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                            ),
                          );
                        }
                        : null,
                child: Text(
                  'Save Changes',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color:
                        widget.hasChanges
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
