import 'package:flutter/material.dart';
import 'package:livelyness_detection/livelyness_detection.dart';
import 'dart:io';
import 'package:easy_scoot/widgets/customAccentButton.dart';

// STEP 3: Take Selfie Page
class TakeSelfiePage extends StatefulWidget {
  final VoidCallback onContinue;

  TakeSelfiePage({required this.onContinue});

  @override
  _TakeSelfiePageState createState() => _TakeSelfiePageState();
}

class _TakeSelfiePageState extends State<TakeSelfiePage> {
  String? _capturedImagePath;

  Future<void> capturePhoto() async {
    try {
      final CapturedImage? response =
          await LivelynessDetection.instance.detectLivelyness(
        context,
        config: DetectionConfig(
          allowAfterMaxSec: true,
          captureButtonColor: Colors.red,
          maxSecToDetect: 60,
          steps: [
            LivelynessStepItem(
              step: LivelynessStep.blink,
              title: "Blink",
              isCompleted: false,
            ),
            LivelynessStepItem(
              step: LivelynessStep.turnLeft,
              title: "Turn Left",
              isCompleted: false,
            ),
            LivelynessStepItem(
              step: LivelynessStep.turnRight,
              title: "Turn Right",
              isCompleted: false,
            ),
            LivelynessStepItem(
              step: LivelynessStep.smile,
              title: "Smile",
              isCompleted: false,
            ),
          ],
          startWithInfoScreen: true,
        ),
      );

      if (response != null) {
        showErrorDialog("Image capture successful");
        setState(() {
          _capturedImagePath = response.imgPath;
        });
      } else {
        showErrorDialog("No response was received from the detection.");
      }
    } catch (e) {
      showErrorDialog("An error occurred during detection: $e");
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Take Selfie',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'We use your selfie to compare with your Aadhar photo.',
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
            Spacer(),
            if (_capturedImagePath != null)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 300,
                    child: Center(
                      child: Image.file(
                        File(_capturedImagePath!),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text('is your face clearly visible?'),
                ],
              ),
            if (_capturedImagePath == null)
              Text(
                "Click capture button to continue.",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            Spacer(),
            if (_capturedImagePath != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(),
                  CustomAccentButton(btnText: 'Retake', onClick: capturePhoto),
                  SizedBox(width: 16),
                  CustomAccentButton(
                      btnText: 'Yes, Visible', onClick: widget.onContinue),
                  Spacer()
                ],
              )
            else
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomAccentButton(
                      btnText: 'Capture Photo', onClick: capturePhoto)
                ],
              )
          ],
        ),
      ),
    );
  }
}
