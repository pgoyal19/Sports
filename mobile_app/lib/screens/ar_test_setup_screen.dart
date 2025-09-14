import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../providers/athlete_provider.dart';

class ARTestSetupScreen extends StatefulWidget {
  const ARTestSetupScreen({super.key});

  @override
  State<ARTestSetupScreen> createState() => _ARTestSetupScreenState();
}

class _ARTestSetupScreenState extends State<ARTestSetupScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  String _selectedTest = 'Vertical Jump';
  int _currentStep = 0;
  bool _isARMode = false;
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;

  final List<TestType> _testTypes = [
    TestType(
      name: 'Vertical Jump',
      description: 'Measure your vertical leap ability',
      setupSteps: [
        'Find a flat, open area with good lighting',
        'Stand 2 meters away from the camera',
        'Ensure your full body is visible in the frame',
        'The camera will overlay measurement markers',
      ],
      distance: 2.0,
    ),
    TestType(
      name: 'Shuttle Run',
      description: 'Test your agility and speed',
      setupSteps: [
        'Find a 10-meter straight path',
        'Place markers at 0m and 10m points',
        'Stand at the starting line',
        'The camera will show the running path',
      ],
      distance: 10.0,
    ),
    TestType(
      name: 'Sit-ups',
      description: 'Measure your core strength',
      setupSteps: [
        'Lie down on a flat surface',
        'Position camera 3 meters away',
        'Ensure your full body is visible',
        'The camera will count your repetitions',
      ],
      distance: 3.0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final status = await Permission.camera.request();
      if (status != PermissionStatus.granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission is required')),
        );
        return;
      }

      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
        );

        await _cameraController!.initialize();
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera initialization failed: $e')),
      );
    }
  }

  Future<void> _speak(String text) async {
    try {
      await _tts.setLanguage('en-IN');
      await _tts.setSpeechRate(0.9);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      _isSpeaking = true;
      await _tts.speak(text);
      _isSpeaking = false;
    } catch (_) {}
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR Test Setup'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Test Selection
          Container(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Test Type',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedTest,
                      decoration: const InputDecoration(
                        labelText: 'Test Type',
                        prefixIcon: Icon(Icons.sports),
                      ),
                      items: _testTypes.map((TestType test) {
                        return DropdownMenuItem<String>(
                          value: test.name,
                          child: Text(test.name),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedTest = newValue!;
                          _currentStep = 0;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Camera Preview or Setup Instructions
          Expanded(
            child: _isARMode ? _buildARView() : _buildSetupInstructions(),
          ),

          // Action Buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _nextStep,
                    child: Text(_currentStep == _getCurrentTest().setupSteps.length - 1
                        ? 'Start AR Setup'
                        : 'Next'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetupInstructions() {
    final test = _getCurrentTest();
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Setup Instructions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              
              // Progress indicator
              LinearProgressIndicator(
                value: (_currentStep + 1) / test.setupSteps.length,
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              
              // Current step
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        '${_currentStep + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        test.setupSteps[_currentStep],
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Test info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test Details',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Test: ${test.name}'),
                    Text('Description: ${test.description}'),
                    Text('Required Distance: ${test.distance}m from camera'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildARView() {
    if (!_isCameraInitialized || _cameraController == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Stack(
      children: [
        // Camera preview
        Positioned.fill(
          child: CameraPreview(_cameraController!),
        ),
        
        // AR Overlays
        Positioned.fill(
          child: CustomPaint(
            painter: AROverlayPainter(
              testType: _getCurrentTest(),
            ),
          ),
        ),
        
        // AR Controls
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.view_in_ar,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'AR Mode: ${_getCurrentTest().name}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isARMode = false;
                    });
                  },
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
        ),

        // Lighting and framing hint
        Positioned(
          top: 70,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.55),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.light_mode, color: Colors.white, size: 16),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Ensure good lighting and keep your full body inside the frame.',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Start Test Button
        Positioned(
          bottom: 32,
          left: 32,
          right: 32,
          child: ElevatedButton.icon(
            onPressed: _startTest,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Test'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        // Test hints panel
        Positioned(
          left: 16,
          right: 16,
          bottom: 96,
          child: _buildTestHints(),
        ),
      ],
    );
  }

  Widget _buildTestHints() {
    final test = _getCurrentTest();
    final List<String> hints;
    if (test.name == 'Vertical Jump') {
      hints = [
        'Stand on the center line',
        'Bend knees and jump straight up',
        'Land on the same spot',
      ];
    } else if (test.name == 'Shuttle Run') {
      hints = [
        'Run from start to end line',
        'Touch the line and return',
        'Maintain consistent speed',
      ];
    } else {
      hints = [
        'Lie within the box outline',
        'Keep feet anchored',
        'Raise torso to complete a rep',
      ];
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.straighten, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                'Distance: ${test.distance.toStringAsFixed(1)} m',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...hints.map((h) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.greenAccent, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        h,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  TestType _getCurrentTest() {
    return _testTypes.firstWhere((test) => test.name == _selectedTest);
  }

  void _nextStep() {
    final test = _getCurrentTest();
    if (_currentStep < test.setupSteps.length - 1) {
      setState(() {
        _currentStep++;
      });
      _speak(test.setupSteps[_currentStep]);
    } else {
      setState(() {
        _isARMode = true;
      });
      _speak('AR mode started. Align yourself with the markers.');
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _startTest() {
    _countdownThenStart();
  }

  Future<void> _countdownThenStart() async {
    for (int i = 3; i >= 1; i--) {
      _speak('$i');
      await Future.delayed(const Duration(milliseconds: 800));
    }
    _speak('Go');
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/record');
  }
}

class TestType {
  final String name;
  final String description;
  final List<String> setupSteps;
  final double distance;

  TestType({
    required this.name,
    required this.description,
    required this.setupSteps,
    required this.distance,
  });
}

class AROverlayPainter extends CustomPainter {
  final TestType testType;

  AROverlayPainter({required this.testType});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Draw measurement markers based on test type
    if (testType.name == 'Vertical Jump') {
      _drawVerticalJumpMarkers(canvas, size, paint, textPainter);
    } else if (testType.name == 'Shuttle Run') {
      _drawShuttleRunMarkers(canvas, size, paint, textPainter);
    } else if (testType.name == 'Sit-ups') {
      _drawSitupsMarkers(canvas, size, paint, textPainter);
    }
    _drawCalibrationGrid(canvas, size);
  }

  void _drawVerticalJumpMarkers(Canvas canvas, Size size, Paint paint, TextPainter textPainter) {
    // Draw center line
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.2),
      Offset(size.width * 0.5, size.height * 0.8),
      paint,
    );

    // Draw measurement markers
    for (int i = 0; i < 5; i++) {
      final y = size.height * 0.2 + (i * size.height * 0.15);
      canvas.drawLine(
        Offset(size.width * 0.4, y),
        Offset(size.width * 0.6, y),
        paint,
      );
    }

    // Draw instruction text
    textPainter.text = TextSpan(
      text: 'Stand here and jump straight up',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        size.height * 0.9,
      ),
    );
  }

  void _drawShuttleRunMarkers(Canvas canvas, Size size, Paint paint, TextPainter textPainter) {
    // Draw start line
    canvas.drawLine(
      Offset(size.width * 0.1, size.height * 0.5),
      Offset(size.width * 0.1, size.height * 0.6),
      paint,
    );

    // Draw end line
    canvas.drawLine(
      Offset(size.width * 0.9, size.height * 0.5),
      Offset(size.width * 0.9, size.height * 0.6),
      paint,
    );

    // Draw running path
    canvas.drawLine(
      Offset(size.width * 0.1, size.height * 0.55),
      Offset(size.width * 0.9, size.height * 0.55),
      paint,
    );

    // Draw instruction text
    textPainter.text = TextSpan(
      text: 'Run from start to end line (10m)',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        size.height * 0.9,
      ),
    );
  }

  void _drawSitupsMarkers(Canvas canvas, Size size, Paint paint, TextPainter textPainter) {
    // Draw body outline
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.6),
        width: size.width * 0.6,
        height: size.height * 0.3,
      ),
      const Radius.circular(20),
    );
    canvas.drawRRect(rect, paint);

    // Draw instruction text
    textPainter.text = TextSpan(
      text: 'Lie down here and do sit-ups',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        size.height * 0.9,
      ),
    );
  }

  void _drawCalibrationGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1;
    // 3x3 grid
    for (int i = 1; i < 3; i++) {
      final dy = size.height * (i / 3);
      final dx = size.width * (i / 3);
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), gridPaint);
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), gridPaint);
    }
    // Center circle
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.6), 20, gridPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
