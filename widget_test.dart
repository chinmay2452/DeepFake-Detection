import 'package:deepfake_detection/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:camera/camera.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Face Detection App Tests', () {
    // Mock cameras for testing
    final List<CameraDescription> mockCameras = [
      CameraDescription(
        name: 'front',
        lensDirection: CameraLensDirection.front,
        sensorOrientation: 0,
      ),
      CameraDescription(
        name: 'back',
        lensDirection: CameraLensDirection.back,
        sensorOrientation: 0,
      ),
    ];

    testWidgets('App renders correctly with mock cameras', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(MyApp(cameras: mockCameras));

      // Verify that the app title is displayed
      expect(find.text('Real-Time Face Detection'), findsOneWidget);

      // Verify that the camera switch button is present
      expect(find.byIcon(Icons.camera_rear), findsOneWidget);
    });

    testWidgets('Loading indicator shows while camera initializes', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp(cameras: mockCameras));

      // Verify that a CircularProgressIndicator is shown while the camera initializes
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Camera switch button is present and tappable', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp(cameras: mockCameras));

      // Find the camera switch button
      final switchCameraButton = find.byIcon(Icons.camera_rear);
      expect(switchCameraButton, findsOneWidget);

      // Attempt to tap the button (Note: actual camera switching won't work in tests)
      await tester.tap(switchCameraButton);
      await tester.pumpAndSettle();
    });
  });
}