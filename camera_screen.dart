import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/screen_recorder_service.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  ScreenRecorderService? _recorderService;
  bool _isCameraInitialized = false;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeScreenRecorder();
  }

  Future<void> _initializeScreenRecorder() async {
    _recorderService = ScreenRecorderService();
    await _recorderService!.initialize();
  }

  Future<void> _initializeCamera() async {
    // Request permissions
    await Permission.camera.request();
    await Permission.microphone.request();
    await Permission.storage.request();

    // Get available cameras
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    // Initialize camera controller
    _cameraController = CameraController(
      cameras[0],
      ResolutionPreset.high,
      enableAudio: true,
    );

    try {
      await _cameraController!.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
      // Start screen recording when camera initializes
      _startRecording();
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> _startRecording() async {
    if (_recorderService != null && !_isRecording) {
      await _recorderService!.startRecording();
      setState(() {
        _isRecording = true;
      });
    }
  }

  Future<void> _stopRecording() async {
    if (_recorderService != null && _isRecording) {
      final downloadUrl = await _recorderService!.stopRecordingAndUpload();
      setState(() {
        _isRecording = false;
      });
      if (downloadUrl != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Video uploaded: $downloadUrl')),
        );
      }
    }
  }

  @override
  void dispose() {
    _stopRecording();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Camera Screen Recorder')),
      body: Column(
        children: [
          Expanded(
            child: CameraPreview(_cameraController!),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _isRecording ? _stopRecording : _startRecording,
                  child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}