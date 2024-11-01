import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_scoot/appwrite/auth.dart'; // Ensure this is correctly imported
import 'home.dart'; // Ensure this is correctly imported
import 'package:easy_scoot/widgets/Astartup_loading.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:intl/intl.dart';
import 'package:livelyness_detection/livelyness_detection.dart';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:easy_scoot/services/camera_overlay.dart';
import 'package:easy_scoot/services/model.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:appwrite/appwrite.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class Onboarding extends StatefulWidget {
  const Onboarding({Key? key}) : super(key: key);

  @override
  _OnboardingState createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    void _renderOnboardingPage() {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnboardingPage()),
      );
    }

    void _renderHomePage() {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    }

    try {
      final auth = Provider.of<AuthAPI>(context, listen: false);
      var prefs = await auth.getUserPreferences();
      if (prefs.data['onboarded'] == 'true') {
        print('User is already onboarded.');
        _renderHomePage();
        setState(() {
          _isLoading = false;
        });
      } else {
        print('User needs to complete onboarding.');
        setState(() {
          _isLoading = false;
        });
        _renderOnboardingPage();
      }
    } on AppwriteException catch (e) {
      print('AppwriteException: ${e.message}, Code: ${e.code}');
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('An unexpected error occurred: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading ? StartupLoader() : OnboardingPage(),
    );
  }
}
///////

class OnboardingPage extends StatefulWidget {
  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int currentStep = 3;

  void _goToNextStep() {
    if (currentStep < 4) {
      setState(() {
        currentStep++;
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AuthenticationSuccessfulPage()),
      );
    }
  }

  double getProgress() {
    if (currentStep == 1) return 0.3;
    if (currentStep == 2) return 0.6;
    if (currentStep == 3) return 0.9;
    if (currentStep == 4) return 1.0;
    return 0.0;
  }

  Widget _buildCurrentStep() {
    switch (currentStep) {
      case 0:
        return WelcomePage(onStart: _goToNextStep);
      case 1:
        return PersonalDetailsPage(onContinue: _goToNextStep);
      case 2:
        return TakeSelfiePage(onContinue: _goToNextStep);
      case 3:
        return AadharScanPage(onContinue: _goToNextStep);
      case 4:
        return AuthenticationSuccessfulPage();
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image(
          image: AssetImage('assets/images/navlogo.png'),
          height: 30,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (currentStep != 0) // Show progress bar only after welcome screen
            Padding(
                padding: EdgeInsets.all(15.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment
                        .center, // Align the progress bar to the center
                    children: [
                      Text('Step ${currentStep} of 4'),
                      LinearPercentIndicator(
                        width: MediaQuery.of(context).size.width * 0.8,
                        lineHeight: 14.0,
                        percent: getProgress(),
                        center: Text(
                          "${(getProgress() * 100).toStringAsFixed(0)}%",
                          style: TextStyle(fontSize: 12.0),
                        ),
                        linearStrokeCap: LinearStrokeCap.roundAll,
                        backgroundColor: Colors.grey,
                        progressColor: Colors.blue,
                      ),
                    ])),
          Expanded(child: _buildCurrentStep()),
        ],
      ),
    );
  }
}

class WelcomePage extends StatelessWidget {
  final VoidCallback onStart;

  WelcomePage({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Welcome Card
          Container(
            width: 300,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Text(
                  'Welcome new user,\n\n'
                  'we need some info before you can start using easyscoot\n\n'
                  'sit in a well-lit condition and keep your Aadhar card ready.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    onStart();
                  },
                  child: Text(
                    'Start >',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PersonalDetailsPage extends StatefulWidget {
  final VoidCallback onContinue;

  PersonalDetailsPage({required this.onContinue});

  @override
  _PersonalDetailsPageState createState() => _PersonalDetailsPageState();
}

class _PersonalDetailsPageState extends State<PersonalDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  DateTime? selectedDate;
  String? dateValidationError;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _firstNameController,
              decoration: InputDecoration(
                labelText: "First Name",
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter your first name' : null,
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _lastNameController,
              decoration: InputDecoration(
                labelText: "Last Name",
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter your last name' : null,
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: TextEditingController(
                  text: selectedDate == null
                      ? ''
                      : DateFormat('yyyy-MM-dd').format(selectedDate!)),
              decoration: InputDecoration(
                labelText: 'Date of Birth',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null && picked != selectedDate) {
                      setState(() {
                        selectedDate = picked;
                        dateValidationError = null;
                        print(
                            'Selected Date of Birth: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}'); // Print selected date
                      });
                    }
                  },
                ),
              ),
              readOnly: true,
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Email Address",
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(r"^[a-zA-Z0-9]+@[a-zA-Z]+\.[a-zA-Z]+")
                    .hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Print all data
                  print('First Name: ${_firstNameController.text}');
                  print('Last Name: ${_lastNameController.text}');
                  print('Email: ${_emailController.text}');
                  if (selectedDate != null) {
                    print(
                        'Date of Birth: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}');
                  } else {
                    print('Date of Birth: Not selected');
                  }
                  widget.onContinue();
                }
              },
              child: Text("Continue"),
            ),
          ],
        ),
      ),
    );
  }
}

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
      appBar: AppBar(
        title: Text("Take Selfie"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_capturedImagePath != null)
              Expanded(
                child: Image.file(
                  File(_capturedImagePath!),
                  fit: BoxFit.contain,
                ),
              ),
            if (_capturedImagePath == null)
              Text(
                "No selfie captured yet.",
                style: TextStyle(fontSize: 16),
              ),
            SizedBox(height: 20),
            if (_capturedImagePath != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: capturePhoto,
                    child: Text("Retake"),
                  ),
                  ElevatedButton(
                    onPressed: widget.onContinue,
                    child: Text("Continue"),
                  ),
                ],
              )
            else
              ElevatedButton(
                onPressed: capturePhoto,
                child: Text("Capture Photo"),
              ),
          ],
        ),
      ),
    );
  }
}

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
      appBar: AppBar(
        title: Text("Aadhar Scan"),
      ),
      body: _buildMainContent(),
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (context) => AadharScannerPage(
                        onCapture: (String imagePath, String extractedText) {
                          setState(() {
                            _capturedImagePath = imagePath;
                            _extractedText = extractedText;
                          });
                        },
                      ),
                    ),
                  );
                },
                child:
                    Text(_capturedImagePath == null ? "Scan Aadhar" : "Retry"),
              ),
              if (_capturedImagePath != null)
                ElevatedButton(
                  onPressed: widget.onContinue,
                  child: Text("Continue"),
                ),
            ],
          ),
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

class AuthenticationSuccessfulPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    void _completeOnboarding() async {
      final auth = Provider.of<AuthAPI>(context, listen: false);
      try {
        await auth.onboardUser();
      } catch (e) {
        print('Error during user onboarding: $e');
        // You might want to handle this error, perhaps show a dialog to the user
      }

      try {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
      } catch (e) {
        print('Error during navigation to Home page: $e');
        // You might want to handle this error as well
      }
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Authentication Successful",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Image.asset('assets/images/success.png',
              height: 200), // Mock success image
          SizedBox(height: 20),
          Text(
            "Thank you for going through verification process. Click the button below to continue.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15),
          ),
          ElevatedButton(
            onPressed: () {
              // call validator function that takes all and validates, if true sets the onboarded to true and navigates to home
              _completeOnboarding();
              // Navigator.pushReplacement(
              //   context,
              //   MaterialPageRoute(builder: (context) => Home()),
              // );
            },
            child: Text("Let's Go"),
          ),
        ],
      ),
    );
  }
}
