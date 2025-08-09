import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProfilePhotoSection extends StatefulWidget {
  final String? currentPhotoUrl;
  final Function(String?) onPhotoChanged;

  const ProfilePhotoSection({
    super.key,
    this.currentPhotoUrl,
    required this.onPhotoChanged,
  });

  @override
  State<ProfilePhotoSection> createState() => _ProfilePhotoSectionState();
}

class _ProfilePhotoSectionState extends State<ProfilePhotoSection> {
  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;
  XFile? _capturedImage;
  bool _isCameraInitialized = false;
  bool _showCameraPreview = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;
    return (await Permission.camera.request()).isGranted;
  }

  Future<void> _initializeCamera() async {
    try {
      if (!await _requestCameraPermission()) return;

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
      await _applySettings();

      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  Future<void> _applySettings() async {
    if (_cameraController == null) return;

    try {
      await _cameraController!.setFocusMode(FocusMode.auto);
    } catch (e) {
      debugPrint('Focus mode error: $e');
    }

    if (!kIsWeb) {
      try {
        await _cameraController!.setFlashMode(FlashMode.auto);
      } catch (e) {
        debugPrint('Flash mode error: $e');
      }
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;

    try {
      final XFile photo = await _cameraController!.takePicture();
      setState(() {
        _capturedImage = photo;
        _showCameraPreview = false;
      });
      widget.onPhotoChanged(photo.path);
    } catch (e) {
      debugPrint('Photo capture error: $e');
    }
  }

  Future<void> _selectFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _capturedImage = image;
        });
        widget.onPhotoChanged(image.path);
      }
    } catch (e) {
      debugPrint('Gallery selection error: $e');
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Update Profile Photo',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 16),
                      ListTile(
                        leading: CustomIconWidget(
                          iconName: 'camera_alt',
                          color: Theme.of(context).colorScheme.primary,
                          size: 24,
                        ),
                        title: Text('Take Photo'),
                        onTap: () {
                          Navigator.pop(context);
                          if (_isCameraInitialized) {
                            setState(() {
                              _showCameraPreview = true;
                            });
                          }
                        },
                      ),
                      ListTile(
                        leading: CustomIconWidget(
                          iconName: 'photo_library',
                          color: Theme.of(context).colorScheme.primary,
                          size: 24,
                        ),
                        title: Text('Choose from Gallery'),
                        onTap: () {
                          Navigator.pop(context);
                          _selectFromGallery();
                        },
                      ),
                      if (widget.currentPhotoUrl != null ||
                          _capturedImage != null)
                        ListTile(
                          leading: CustomIconWidget(
                            iconName: 'delete',
                            color: Theme.of(context).colorScheme.error,
                            size: 24,
                          ),
                          title: Text('Remove Photo'),
                          onTap: () {
                            Navigator.pop(context);
                            setState(() {
                              _capturedImage = null;
                            });
                            widget.onPhotoChanged(null);
                          },
                        ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
    );
  }

  Widget _buildCameraPreview() {
    if (!_isCameraInitialized || _cameraController == null) {
      return Container(
        height: 70.h,
        color: Colors.black,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      height: 70.h,
      child: Stack(
        children: [
          CameraPreview(_cameraController!),
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              onPressed: () {
                setState(() {
                  _showCameraPreview = false;
                });
              },
              icon: CustomIconWidget(
                iconName: 'close',
                color: Colors.white,
                size: 24,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.5),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _capturePhoto,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 4,
                    ),
                  ),
                  child: CustomIconWidget(
                    iconName: 'camera_alt',
                    color: Theme.of(context).colorScheme.primary,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showCameraPreview) {
      return _buildCameraPreview();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          GestureDetector(
            onTap: _showPhotoOptions,
            child: Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child:
                        _capturedImage != null
                            ? kIsWeb
                                ? Image.network(
                                  _capturedImage!.path,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                )
                                : CustomImageWidget(
                                  imageUrl: _capturedImage!.path,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                )
                            : widget.currentPhotoUrl != null
                            ? CustomImageWidget(
                              imageUrl: widget.currentPhotoUrl!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            )
                            : CustomIconWidget(
                              iconName: 'person',
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                              size: 60,
                            ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.surface,
                        width: 2,
                      ),
                    ),
                    child: CustomIconWidget(
                      iconName: 'camera_alt',
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Tap to update profile photo',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
