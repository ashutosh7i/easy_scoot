import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:easy_scoot/pages/onboarding_sections/step1_welcome.dart';
import 'package:easy_scoot/pages/onboarding_sections/step2_personalDetails.dart';
import 'package:easy_scoot/pages/onboarding_sections/step3_takeSelfiePage.dart';
import 'package:easy_scoot/pages/onboarding_sections/step4_aadharScanPage.dart';
import 'package:easy_scoot/pages/onboarding_sections/step5_authenticationSuccessfulpage.dart';

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
                        animation:
                            bool.fromEnvironment(getProgress().toString()),
                        alignment: MainAxisAlignment.center,
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
