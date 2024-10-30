import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_scoot/appwrite/auth.dart'; // Ensure this is correctly imported
import 'home.dart'; // Ensure this is correctly imported
import 'package:easy_scoot/widgets/Astartup_loading.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:intl/intl.dart';

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

  void _checkOnboarding() async {
    final auth = Provider.of<AuthAPI>(context, listen: false);
    bool isOnboarded = await auth.isuserOnboarded();
    if (isOnboarded) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _completeOnboarding() async {
    final auth = Provider.of<AuthAPI>(context, listen: false);
    await auth.onboardUser();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Home()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? StartupLoader() // Show the loading indicator while checking
          : OnboardingPage(),
    );
  }
}

///////

class OnboardingPage extends StatefulWidget {
  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int currentStep = 0;

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
          image: AssetImage('images/navlogo.png'),
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

class TakeSelfiePage extends StatelessWidget {
  final VoidCallback onContinue;

  TakeSelfiePage({required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Take Selfie",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            "Fill your details and click continue",
            style: TextStyle(fontSize: 15, color: Colors.grey),
          ),
          SizedBox(height: 20),
          Image.asset('images/selfie.png', height: 300), // Mock selfie image
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: onContinue,
            child: Text("Capture Photo"),
          ),
        ],
      ),
    );
  }
}

class AadharScanPage extends StatelessWidget {
  final VoidCallback onContinue;

  AadharScanPage({required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Aadhar Scan",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            "We will scan your Aadhar card to validate.",
            style: TextStyle(fontSize: 15, color: Colors.grey),
          ),
          SizedBox(height: 20),
          Image.asset('images/card.png', height: 200), // Mock Aadhar image
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: onContinue,
            child: Text("Scan Aadhar"),
          ),
        ],
      ),
    );
  }
}

class AuthenticationSuccessfulPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Authentication Successful",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Image.asset('images/success.png', height: 200), // Mock success image
          SizedBox(height: 20),
          Text(
            "Thank you for going through verification process. Click the button below to continue.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15),
          ),
          ElevatedButton(
            onPressed: () {
              // call validator function that takes all and validates, if true sets the onboarded to true and navigates to home

              Navigator.pop(context);
            },
            child: Text("Let's Go"),
          ),
        ],
      ),
    );
  }
}
