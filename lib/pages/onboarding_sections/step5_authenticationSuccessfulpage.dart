import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_scoot/appwrite/auth.dart';
import 'package:easy_scoot/pages/home.dart';
import 'package:easy_scoot/widgets/customAccentButton.dart';

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
                  'Authentication Successful',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Image.asset('assets/images/success.png',
              height: 250), // Mock success image
          SizedBox(height: 10),
          Spacer(),
          Text(
            "Thank you for going through verification process. Click the button below to continue.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          Spacer(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 10),
              CustomAccentButton(
                  btnText: "Let's Go", onClick: _completeOnboarding)
            ],
          )
        ],
      ),
    ));
  }
}
