import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EditClassModal extends StatefulWidget {
  final Map<String, dynamic> classData;
  final Function(Map<String, dynamic>) onClassUpdated;

  const EditClassModal({
    super.key,
    required this.classData,
    required this.onClassUpdated,
  });

  @override
  State<EditClassModal> createState() => _EditClassModalState();
}

class _EditClassModalState extends State<EditClassModal> {
  final _formKey = GlobalKey<FormState>();
  String? selectedSubject;
  String? selectedTeacher;
  String? selectedRoom;
  String? selectedDay;
  String? selectedTime;
  String? selectedDuration;
  final TextEditingController _descriptionController = TextEditingController();

  final List<String> subjects = [
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'English',
    'History',
    'Geography',
    'Computer Science',
    'Economics',
    'Psychology',
  ];

  final List<String> teachers = [
    'Dr. Sarah Johnson',
    'Prof. Michael Chen',
    'Dr. Emily Rodriguez',
    'Prof. David Wilson',
    'Dr. Lisa Anderson',
    'Prof. James Thompson',
    'Dr. Maria Garcia',
    'Prof. Robert Taylor',
    'Dr. Jennifer Lee',
    'Prof. Christopher Brown',
  ];

  final List<String> rooms = [
    'Room 101',
    'Room 102',
    'Room 201',
    'Room 202',
    'Lab A',
    'Lab B',
    'Auditorium',
    'Library Hall',
    'Conference Room',
    'Seminar Hall',
  ];

  final List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  final List<String> timeSlots = [
    '9:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '1:00 PM',
    '2:00 PM',
    '3:00 PM',
    '4:00 PM',
    '5:00 PM',
  ];

  final List<String> durations = [
    '1 hour',
    '1.5 hours',
    '2 hours',
    '2.5 hours',
    '3 hours',
  ];

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    selectedSubject = widget.classData['subject'] as String?;
    selectedTeacher = widget.classData['teacher'] as String?;
    selectedRoom = widget.classData['room'] as String?;
    selectedDay = widget.classData['day'] as String?;
    selectedTime = widget.classData['time'] as String?;
    selectedDuration = widget.classData['duration'] as String? ?? '1 hour';
    _descriptionController.text =
        widget.classData['description'] as String? ?? '';
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85.h,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomIconWidget(
                  iconName: 'edit',
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: 4.w),
              Text(
                'Edit Class',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildDropdownField(
                      label: 'Subject',
                      value: selectedSubject,
                      items: subjects,
                      onChanged:
                          (value) => setState(() => selectedSubject = value),
                      icon: 'book',
                    ),
                    SizedBox(height: 3.h),
                    _buildDropdownField(
                      label: 'Teacher',
                      value: selectedTeacher,
                      items: teachers,
                      onChanged:
                          (value) => setState(() => selectedTeacher = value),
                      icon: 'person',
                    ),
                    SizedBox(height: 3.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdownField(
                            label: 'Day',
                            value: selectedDay,
                            items: days,
                            onChanged:
                                (value) => setState(() => selectedDay = value),
                            icon: 'calendar_today',
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: _buildDropdownField(
                            label: 'Time',
                            value: selectedTime,
                            items: timeSlots,
                            onChanged:
                                (value) => setState(() => selectedTime = value),
                            icon: 'schedule',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdownField(
                            label: 'Room',
                            value: selectedRoom,
                            items: rooms,
                            onChanged:
                                (value) => setState(() => selectedRoom = value),
                            icon: 'location_on',
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: _buildDropdownField(
                            label: 'Duration',
                            value: selectedDuration,
                            items: durations,
                            onChanged:
                                (value) =>
                                    setState(() => selectedDuration = value),
                            icon: 'timer',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3.h),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description (Optional)',
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(3.w),
                          child: CustomIconWidget(
                            iconName: 'description',
                            color:
                                AppTheme
                                    .lightTheme
                                    .colorScheme
                                    .onSurfaceVariant,
                            size: 20,
                          ),
                        ),
                      ),
                      maxLines: 3,
                      textInputAction: TextInputAction.done,
                    ),
                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: _handleUpdateClass,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                  ),
                  child: const Text('Update Class'),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required String icon,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Padding(
          padding: EdgeInsets.all(3.w),
          child: CustomIconWidget(
            iconName: icon,
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
        ),
      ),
      items:
          items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Please select $label' : null,
    );
  }

  void _handleUpdateClass() {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedClass = Map<String, dynamic>.from(widget.classData);
      updatedClass.addAll({
        'subject': selectedSubject!,
        'teacher': selectedTeacher!,
        'day': selectedDay!,
        'time': selectedTime!,
        'room': selectedRoom!,
        'duration': selectedDuration!,
        'description': _descriptionController.text.trim(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      widget.onClassUpdated(updatedClass);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              CustomIconWidget(
                iconName: 'check_circle',
                color: Colors.white,
                size: 16,
              ),
              SizedBox(width: 2.w),
              const Text('Class updated successfully'),
            ],
          ),
          backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }
}
