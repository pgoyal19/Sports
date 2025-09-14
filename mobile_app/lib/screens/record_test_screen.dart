import 'package:flutter/material.dart';
import '../widgets/video_recorder.dart';
import '../services/api_service.dart';

class RecordTestScreen extends StatefulWidget {
  const RecordTestScreen({super.key});
  @override
  State<RecordTestScreen> createState() => _RecordTestScreenState(); // Fixed state exposure
}

class _RecordTestScreenState extends State<RecordTestScreen> {
  String feedback = "";

  void uploadVideo(String path) async {
    var result = await ApiService.uploadVideo(path);
    setState(() {
      feedback =
          "Score: ${result['score']}, Cheat Detected: ${result['cheat_detected']}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Record Test')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Instructions',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      const Text('Place your camera so your full body is visible. Ensure good lighting.'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      VideoRecorder(onVideoRecorded: uploadVideo),
                      const SizedBox(height: 12),
                      Text(
                        feedback.isEmpty ? 'No result yet' : feedback,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/results'),
                child: const Text('View Results'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
