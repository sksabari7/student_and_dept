import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class UploadModalWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onFileUploaded;
  final VoidCallback onClose;

  const UploadModalWidget({
    super.key,
    required this.onFileUploaded,
    required this.onClose,
  });

  @override
  State<UploadModalWidget> createState() => _UploadModalWidgetState();
}

class _UploadModalWidgetState extends State<UploadModalWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isUploading = false;
  String? _selectedFilePath;
  String? _capturedImagePath;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedCategory = 'Question Papers';
  String _selectedSubject = 'Mathematics';

  final List<String> _categories = [
    'Question Papers',
    'Lab Guides',
    'Textbooks',
    'Announcements',
  ];

  final List<String> _subjects = [
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'English',
    'Computer Science',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeCamera();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cameraController?.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      if (!kIsWeb) {
        final hasPermission = await _requestCameraPermission();
        if (!hasPermission) return;
      }

      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      final camera =
          kIsWeb
              ? _cameras.firstWhere(
                (c) => c.lensDirection == CameraLensDirection.front,
                orElse: () => _cameras.first,
              )
              : _cameras.firstWhere(
                (c) => c.lensDirection == CameraLensDirection.back,
                orElse: () => _cameras.first,
              );

      _cameraController = CameraController(
        camera,
        kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
      );

      await _cameraController!.initialize();

      if (!kIsWeb) {
        try {
          await _cameraController!.setFocusMode(FocusMode.auto);
          await _cameraController!.setFlashMode(FlashMode.auto);
        } catch (e) {
          // Ignore unsupported features
        }
      }

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      // Camera initialization failed, continue without camera
    }
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;

    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile photo = await _cameraController!.takePicture();
      setState(() {
        _capturedImagePath = photo.path;
      });
    } catch (e) {
      _showErrorSnackBar('Failed to capture photo');
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'txt'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFilePath =
              result.files.first.path ?? result.files.first.name;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick file');
    }
  }

  Future<void> _uploadFile() async {
    if (_titleController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter a title');
      return;
    }

    if (_selectedFilePath == null && _capturedImagePath == null) {
      _showErrorSnackBar('Please select a file or capture a photo');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Simulate upload process
      await Future.delayed(const Duration(seconds: 2));

      final uploadedFile = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'subject': _selectedSubject,
        'fileType': _getFileType(),
        'uploadDate': _formatDate(DateTime.now()),
        'size': '2.5 MB',
        'isDownloaded': false,
        'isDownloading': false,
        'downloadProgress': 0.0,
        'filePath': _selectedFilePath ?? _capturedImagePath,
      };

      widget.onFileUploaded(uploadedFile);
      widget.onClose();
    } catch (e) {
      _showErrorSnackBar('Upload failed. Please try again.');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  String _getFileType() {
    if (_capturedImagePath != null) return 'pdf';
    if (_selectedFilePath != null) {
      final extension = _selectedFilePath!.split('.').last.toLowerCase();
      return extension;
    }
    return 'pdf';
  }

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90.h,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildFileUploadTab(), _buildCameraScanTab()],
            ),
          ),
          _buildUploadButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          Text(
            'Upload Resource',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: widget.onClose,
            icon: CustomIconWidget(
              iconName: 'close',
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      tabs: const [Tab(text: 'File Upload'), Tab(text: 'Camera Scan')],
      labelColor: Theme.of(context).colorScheme.primary,
      unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
      indicatorColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildFileUploadTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFileSelector(),
          SizedBox(height: 3.h),
          _buildFormFields(),
        ],
      ),
    );
  }

  Widget _buildCameraScanTab() {
    return Column(
      children: [
        Expanded(
          child:
              _isCameraInitialized && _cameraController != null
                  ? _buildCameraPreview()
                  : _buildCameraPlaceholder(),
        ),
        if (_capturedImagePath != null) _buildCapturedImagePreview(),
        _buildCameraControls(),
      ],
    );
  }

  Widget _buildFileSelector() {
    return GestureDetector(
      onTap: _pickFile,
      child: Container(
        width: double.infinity,
        height: 20.h,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName:
                  _selectedFilePath != null
                      ? 'insert_drive_file'
                      : 'cloud_upload',
              color: Theme.of(context).colorScheme.primary,
              size: 48,
            ),
            SizedBox(height: 2.h),
            Text(
              _selectedFilePath != null
                  ? _selectedFilePath!.split('/').last
                  : 'Tap to select file',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight:
                    _selectedFilePath != null
                        ? FontWeight.w500
                        : FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            if (_selectedFilePath == null) ...[
              SizedBox(height: 1.h),
              Text(
                'Supported: PDF, DOC, PPT, TXT',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    return Container(
      margin: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        overflow: Overflow.clip,
      ),
      child: AspectRatio(
        aspectRatio: _cameraController!.value.aspectRatio,
        child: CameraPreview(_cameraController!),
      ),
    );
  }

  Widget _buildCameraPlaceholder() {
    return Container(
      margin: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'camera_alt',
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 48,
            ),
            SizedBox(height: 2.h),
            Text(
              'Camera not available',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCapturedImagePreview() {
    return Container(
      height: 10.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'photo',
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              'Photo captured successfully',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _capturedImagePath = null;
              });
            },
            icon: CustomIconWidget(
              iconName: 'delete',
              color: Theme.of(context).colorScheme.error,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraControls() {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            onPressed: _isCameraInitialized ? _capturePhoto : null,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: CustomIconWidget(
              iconName: 'camera_alt',
              color: Theme.of(context).colorScheme.onPrimary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resource Details',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 2.h),
        TextField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: 'Title *',
            hintText: 'Enter resource title',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        SizedBox(height: 2.h),
        TextField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Description',
            hintText: 'Enter resource description (optional)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items:
                    _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedSubject,
                decoration: InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items:
                    _subjects.map((subject) {
                      return DropdownMenuItem(
                        value: subject,
                        child: Text(subject),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSubject = value!;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUploadButton() {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: SizedBox(
        width: double.infinity,
        height: 6.h,
        child: ElevatedButton(
          onPressed: _isUploading ? null : _uploadFile,
          child:
              _isUploading
                  ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Text('Uploading...'),
                    ],
                  )
                  : Text('Upload Resource'),
        ),
      ),
    );
  }
}
