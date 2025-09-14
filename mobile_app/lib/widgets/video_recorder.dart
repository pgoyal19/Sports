import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:camera/camera.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../theme/app_theme.dart';

class VideoRecorder extends StatefulWidget {
  final Function(String) onVideoRecorded;

  const VideoRecorder({super.key, required this.onVideoRecorded});

  @override
  State<VideoRecorder> createState() => _VideoRecorderState();
}

class _VideoRecorderState extends State<VideoRecorder> {
  CameraController? _controller;
  bool _isRecording = false;
  bool _isInitialized = false;
  bool _cameraSupported = true;
  List<CameraDescription>? _cameras;
  int _selectedCameraIndex = 0;
  bool _isSwitchingCamera = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  void _initCamera() async {
    // Camera on web (http) is unreliable; provide a graceful fallback
    if (kIsWeb) {
      setState(() {
        _cameraSupported = false;
      });
      return;
    }

    try {
      _cameras = await availableCameras();
      if (_cameras!.isEmpty) {
        setState(() {
          _cameraSupported = false;
        });
        return;
      }
      
      // Initialize with back camera by default
      _selectedCameraIndex = _cameras!.indexWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
      );
      if (_selectedCameraIndex == -1) {
        _selectedCameraIndex = 0; // Fallback to first available camera
      }
      
      await _initializeCameraController();
    } catch (e) {
      setState(() {
        _cameraSupported = false;
      });
    }
  }

  Future<void> _initializeCameraController() async {
    if (_cameras == null || _cameras!.isEmpty) return;
    
    try {
      _controller?.dispose();
      _controller = CameraController(
        _cameras![_selectedCameraIndex],
        ResolutionPreset.high,
        enableAudio: true,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      
      await _controller!.initialize();
      if (!mounted) return;
      setState(() {
        _isInitialized = true;
        _isSwitchingCamera = false;
      });
    } catch (e) {
      setState(() {
        _cameraSupported = false;
        _isSwitchingCamera = false;
      });
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length <= 1) return;
    
    setState(() {
      _isSwitchingCamera = true;
    });
    
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras!.length;
    await _initializeCameraController();
  }

  Future<void> _simulateUpload() async {
    try {
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/simulated_video.mp4';
      // Write a few bytes; not a valid video but good enough for backend to accept and return a stub
      final bytes = Uint8List.fromList(List<int>.generate(1024, (i) => i % 256));
      final file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);
      if (!mounted) return;
      widget.onVideoRecorded(file.path);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Simulation failed.')),
      );
    }
  }

  void _startStopRecording() async {
    if (_controller == null || !_isInitialized) {
      return;
    }
    if (_isRecording) {
      final XFile file = await _controller!.stopVideoRecording();
      setState(() => _isRecording = false);
      widget.onVideoRecorded(file.path);
    } else {
      await _controller!.startVideoRecording();
      setState(() => _isRecording = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Web or unsupported devices: provide a simple fallback UI
    if (!_cameraSupported) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('test.camera_not_available'.tr()),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _simulateUpload,
            child: Text('test.simulate_upload'.tr()),
          ),
        ],
      );
    }

    if (_controller == null || !_isInitialized) {
      return SizedBox(
        height: 200,
        child: Center(
          child: _isSwitchingCamera
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text('test.switching_camera'.tr()),
                  ],
                )
              : const CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Camera preview with controls overlay
        Stack(
          children: [
            AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: CameraPreview(_controller!),
            ),
            
            // Camera controls overlay
            Positioned(
              top: 16,
              right: 16,
              child: Column(
                children: [
                  // Switch camera button
                  if (_cameras != null && _cameras!.length > 1)
                    FloatingActionButton(
                      mini: true,
                      onPressed: _isSwitchingCamera ? null : _switchCamera,
                      backgroundColor: Colors.black54,
                      child: Icon(
                        _cameras![_selectedCameraIndex].lensDirection == CameraLensDirection.back
                            ? Icons.camera_front
                            : Icons.camera_rear,
                        color: Colors.white,
                      ),
                    ),
                  const SizedBox(height: 8),
                  
                  // Camera info
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _cameras![_selectedCameraIndex].lensDirection == CameraLensDirection.back
                          ? 'test.back_camera'.tr()
                          : 'test.front_camera'.tr(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Recording indicator
            if (_isRecording)
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'test.recording'.tr(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Recording controls
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Switch camera button (if multiple cameras available)
            if (_cameras != null && _cameras!.length > 1)
              ElevatedButton.icon(
                onPressed: _isSwitchingCamera ? null : _switchCamera,
                icon: Icon(
                  _cameras![_selectedCameraIndex].lensDirection == CameraLensDirection.back
                      ? Icons.camera_front
                      : Icons.camera_rear,
                ),
                label: Text(
                  _cameras![_selectedCameraIndex].lensDirection == CameraLensDirection.back
                      ? 'test.front_camera'.tr()
                      : 'test.back_camera'.tr(),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.neutral200,
                  foregroundColor: AppTheme.textPrimary,
                ),
              ),
            
            // Record/Stop button
            ElevatedButton.icon(
              onPressed: _startStopRecording,
              icon: Icon(_isRecording ? Icons.stop : Icons.videocam),
              label: Text(_isRecording ? 'test.stop_recording'.tr() : 'test.start_recording'.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isRecording ? AppTheme.error : AppTheme.primary,
                foregroundColor: AppTheme.textOnPrimary,
                minimumSize: const Size(120, 48),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
