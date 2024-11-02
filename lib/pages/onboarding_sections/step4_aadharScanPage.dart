import 'package:flutter/material.dart';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:easy_scoot/services/camera_overlay.dart';
import 'package:easy_scoot/services/model.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:easy_scoot/widgets/customAccentButton.dart';

class AadharScanPage extends StatefulWidget {
  final VoidCallback onContinue;

  AadharScanPage({required this.onContinue});

  @override
  _AadharScanPageState createState() => _AadharScanPageState();
}

class _AadharScanPageState extends State<AadharScanPage> {
  String? _capturedImagePath;
  String? _extractedText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildMainContent(),
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Aadhar Scan',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'We will scan your Aadhar card to validate.',
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              ),
            ],
          ),
          Spacer(),
          if (_capturedImagePath != null)
            Image.file(
              File(_capturedImagePath!),
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            )
          else
            Image.asset('assets/images/card.png', height: 200),
          SizedBox(height: 20),
          if (_extractedText != null)
            Expanded(
              child: SingleChildScrollView(
                child: Text(_extractedText!),
              ),
            )
          else
            Text(
              "We will scan your Aadhar card to validate.",
              style: TextStyle(
                fontSize: 15,
              ),
            ),
          Spacer(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_extractedText != null)
                Text('is ID clearly visible? and data correct?'),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomAccentButton(
                    btnText:
                        (_capturedImagePath == null ? "Scan Aadhar" : "Retry"),
                    onClick: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (context) => AadharScannerPage(
                            onCapture:
                                (String imagePath, String extractedText) {
                              setState(() {
                                _capturedImagePath = imagePath;
                                _extractedText = extractedText;
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  if (_capturedImagePath != null)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomAccentButton(
                            btnText: 'Continue', onClick: widget.onContinue)
                      ],
                    )
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}

class AadharScannerPage extends StatelessWidget {
  final Function(String, String) onCapture;

  AadharScannerPage({required this.onCapture});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Icon(Icons.close, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<CameraDescription>?>(
        future: availableCameras(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data == null) {
              return const Align(
                alignment: Alignment.center,
                child: Text(
                  'No camera found',
                  style: TextStyle(color: Colors.black),
                ),
              );
            }
            return CameraOverlay(
              snapshot.data!.first,
              CardOverlay.byFormat(OverlayFormat.aadharCard),
              (XFile file) async {
                String extractedText = await recognizeText(file.path);
                onCapture(file.path, extractedText);
                Navigator.of(context).pop();
              },
              info:
                  'Position your ID card within the rectangle and ensure the image is perfectly readable.',
              label: 'Scan ID Card',
            );
          } else {
            return const Align(
              alignment: Alignment.center,
              child: Text(
                'Fetching cameras',
                style: TextStyle(color: Colors.black),
              ),
            );
          }
        },
      ),
    );
  }

  Future<String> recognizeText(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final textRecognizer = TextRecognizer();
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);
    return recognizedText.text;
  }
}
