import 'dart:io';
import 'package:flutter/material.dart';
import 'package:screen_recorder/screen_recorder.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ScreenRecorderService {
  late ScreenRecorderController _recorderController;
  final _storage = FirebaseStorage.instance;
  bool _isRecording = false;
  String? _recordingPath;

  // Initialize the recorder controller
  Future<void> initialize() async {
    _recorderController = ScreenRecorderController();
    print('Recorder service ready.');
  }

  // Wrap child widget with recorder
  Widget wrapWithRecorder(Widget child, double height, double width) {
    return ScreenRecorder(
      controller: _recorderController,
      height: height,
      width: width,
      child: SizedBox(
        height: height,
        width: width,
        child: child,
      ),
    );
  }

  // Start recording
  Future<void> startRecording() async {
    if (_isRecording) return;

    try {
      // Ensure the controller is initialized
      final directoryPath = Directory.systemTemp.path; // Use a temp directory
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _recordingPath = '$directoryPath/screen_recording_$timestamp.mp4';

      // Ensure the directory exists
      final directory = Directory(directoryPath);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Start recording (corrected line)
      await _recorderController.start
        (path: _recordingPath!);

      _isRecording = true;
      print('Recording started: $_recordingPath');
    } catch (e) {
      print('Error starting recording: $e');
      rethrow;
    }
  }

  // Stop recording and upload
  Future<String?> stopRecordingAndUpload() async {
    if (!_isRecording) return null;

    try {
      // Stop recording
      await _recorderController.stop();
      _isRecording = false;

      if (_recordingPath == null) {
        throw Exception('Recording failed or file path is null.');
      }

      // Upload the recorded file to Firebase
      return await _uploadToFirebase(File(_recordingPath!));
    } catch (e) {
      print('Error stopping recording: $e');
      rethrow;
    }
  }

  // Upload to Firebase
  Future<String> _uploadToFirebase(File videoFile) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'screen_recording_$timestamp.mp4';
      final ref = _storage.ref().child('recordings/$fileName');

      final uploadTask = ref.putFile(videoFile);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      await videoFile.delete(); // Clean up local file after upload
      print('Video uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error uploading to Firebase: $e');
      rethrow;
    }
  }

  bool get isRecording => _isRecording;
}