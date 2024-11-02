import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_scoot/appwrite/auth.dart';
import 'home.dart';
import 'package:easy_scoot/widgets/Astartup_loading.dart';
import 'package:appwrite/appwrite.dart';
import 'package:easy_scoot/pages/onboarding_sections/step0_onboardingPage.dart';

/*
After logging in user is sent to this page,
on this page user's onboarding status is checked by looking for a flag in his appwrite auth prefs
if user has onboarding = true it means user is already onboarded and is send directly to homepage
else user is not onboard then the onboarding page is rendered and user has to complete it.
*/

// onboarding page
class Onboarding extends StatefulWidget {
  const Onboarding({Key? key}) : super(key: key);

  @override
  _OnboardingState createState() => _OnboardingState();
}

// stateful widget
class _OnboardingState extends State<Onboarding> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

// checking for onboarding
  Future<void> _checkOnboarding() async {
    // function to render onboarding page
    void _renderOnboardingPage() {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnboardingPage()),
      );
    }

    // function to render homepage
    void _renderHomePage() {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    }

    // function to check onboarding
    try {
      final auth = Provider.of<AuthAPI>(context, listen: false);
      // get user prefs
      var prefs = await auth.getUserPreferences();
      // if onboarding flag is present
      if (prefs.data['onboarded'] == 'true') {
        print('User is already onboarded.');
        print('Rendering home page');

        // render homepage
        _renderHomePage();
        setState(() {
          _isLoading = false;
        });
      }
      // else render onboarding page
      else {
        print('User needs to complete onboarding.');
        print('Rendering Onboarding page');
        _renderOnboardingPage();
        setState(() {
          _isLoading = false;
        });
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
    return Scaffold(body: _isLoading ? StartupLoader() : OnboardingPage());
  }
}
