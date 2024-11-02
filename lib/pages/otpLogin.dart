import 'package:flutter/material.dart';
import 'dart:async';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:easy_scoot/appwrite/auth.dart';
import 'package:easy_scoot/widgets/help_page.dart';
import 'package:flutter/services.dart';
import 'package:easy_scoot/pages/onboarding.dart';
import 'package:appwrite/appwrite.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

class OTPVerificationPage extends StatefulWidget {
  @override
  _OTPVerificationPageState createState() => _OTPVerificationPageState();
}

String userId = '';

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  bool isFirstView = true;
  String phoneNumber = '';
  String countryCode = '+91';
  String otp = '';
  int timerSeconds = 30;
  Timer? _timer;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isFirstView
            ? Row(
                children: [
                  Image.asset('assets/images/navlogo.png', height: 45),
                  Spacer()
                ],
              )
            : Text('Verify OTP'),
        leading: isFirstView
            ? null
            : IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    isFirstView = true;
                  });
                },
              ),
        actions: [
          HelpButton(),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: isFirstView ? _buildFirstView() : _buildSecondView(),
      ),
    );
  }

  Widget _buildFirstView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Hi, Welcome to easyScoot',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Center(
            child: Image.asset(
                'assets/images/registerimage.png')), // Center the image
        SizedBox(height: 24),
        Text(
          'Enter your Phone Number',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            CountryCodePicker(
              onChanged: (CountryCode code) {
                setState(() {
                  countryCode = code.dialCode!;
                });
              },
              initialSelection: 'IN',
              favorite: ['+91', 'IN'],
              countryFilter: ['IN'],
              showCountryOnly: false,
              showOnlyCountryWhenClosed: false,
              alignLeft: false,
            ),
            SizedBox(width: 8),
            Expanded(
              // Use Expanded for responsiveness
              child: TextField(
                // controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  hintText: 'Enter phone number',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    phoneNumber = value;
                  });
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 24),
        Center(
          // Center the privacy text
          child: Text(
            'Your privacy is our priority',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        //spacer here
        SizedBox(height: 24),
        //stick towards bottom
        SizedBox(
          width: double.infinity, // Make button full width
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding:
                  EdgeInsets.symmetric(vertical: 16), // Increase button height
              backgroundColor:
                  Theme.of(context).primaryColor, // Use primary color
            ),
            onPressed: phoneNumber.isNotEmpty
                ? () {
                    setState(() {
                      isFirstView = false;
                      _startTimer();
                      _verifyOTP();
                    });
                  }
                : null,
            child: Text('Continue',
                style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildSecondView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Verify Phone',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('Code has been sent to $countryCode $phoneNumber',
            style: TextStyle(color: Colors.grey)),
        SizedBox(height: 24),
        OtpTextField(
          numberOfFields: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          keyboardType: TextInputType.number,
          borderColor: Color(0xFF512DA8),
          showFieldAsBox: true,
          // onCodeChanged: (String value) {
          //   print(value);
          //   setState(() {
          //     otp = value;
          //   });
          // },
          onSubmit: (String verificationCode) {
            setState(() {
              otp = verificationCode;
            });
            print(verificationCode);
            _verifyOTP();
          },
        ),
        SizedBox(height: 16),
        Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Time remaining: $timerSeconds seconds'),
            GestureDetector(
              onTap: () {
                timerSeconds == 0 ? _startTimer : null;
                print('resend clicked');
              },
              child: Text(
                'Resend Code',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
          ],
        )
            // Center the resend code text

            ),
        SizedBox(height: 24),
        Center(
          child: Text(
            'by entering your phone number, you are agreeing to T&C and Privacy Policy',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
        // add spacer
        SizedBox(height: 24),
        // stick towards bottom
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).primaryColor,
            ),
            onPressed: () {
              _verifyOTP;
            },
            child: Text('Verify OTP',
                style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  void _startTimer() {
    setState(() {
      timerSeconds = 30;
    });
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (timerSeconds > 0) {
          timerSeconds--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  void _verifyOTP() async {
    final authAPI = AuthAPI();

    try {
      if (userId.isEmpty) {
        // First step: Create phone token
        print("Creating phone token for phone: $countryCode$phoneNumber");
        final token =
            await authAPI.createPhoneToken(phoneNo: '$countryCode$phoneNumber');
        userId = token.userId;
        print("Token created, user ID: $userId");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('SMS sent. Please enter the code.')),
        );
      } else {
        // Second step: Verify OTP and create session
        print("Verifying OTP: $otp for user ID: $userId");
        try {
          final session =
              await authAPI.createPhoneSession(userId: userId, otp: otp);
          print("OTP verified successfully, session created");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Onboarding()),
          );
        } on AppwriteException catch (e) {
          print("Error verifying OTP: ${e.message}");
          if (e.code == 401 || e.type == 'user_invalid_token') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${e.message}')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${e.message}')),
            );
          }
        }
      }
    } catch (e) {
      print("An error occurred: ${e.toString()}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
