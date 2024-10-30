import 'package:flutter/material.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter/services.dart';

class OtpLogin extends StatefulWidget {
  const OtpLogin({Key? key}) : super(key: key);

  @override
  _OtpLoginState createState() => _OtpLoginState();
}

class _OtpLoginState extends State<OtpLogin> {
  bool _isPhoneNumberView = true; // Track which view to show

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Image.asset('navlogo.png')),
        body: Column(
          children: [
            // Conditional rendering of views
            if (_isPhoneNumberView) ...[
              _buildPhoneNumberView(),
            ] else ...[
              _buildOtpView(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneNumberView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Hi, Welcome to easyScoot',
          style: TextStyle(fontSize: 20),
          textAlign: TextAlign.left,
        ),
        Image.asset('registerImage.png'),
        Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(child: Text('Enter your Phone Number')),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CountryCodePicker(
                    onChanged: print,
                    initialSelection: 'IN',
                    showCountryOnly: false,
                    showOnlyCountryWhenClosed: false,
                    alignLeft: false,
                  ),
                  Expanded(
                    child: Container(
                      height: 50,
                      child: TextField(
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          hintText: 'Enter phone number',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
        SizedBox(height: 20),
        Text('Your privacy is our priority'),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _isPhoneNumberView = false; // Switch to OTP view
            });
          },
          child: Text('Continue'),
        ),
      ],
    );
  }

  String phoneNo = '+91 9993234069';

  Widget _buildOtpView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Verify Phone'),
        Text('Code has been sent to ${phoneNo} '),
        SizedBox(height: 20),
        OtpTextField(
          numberOfFields: 6,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly, // Allows only digits
          ],
          keyboardType: TextInputType.number,
          borderColor: Color(0xFF512DA8),
          //set to true to show as box or false to show as dash
          showFieldAsBox: true,
          //runs when a code is typed in
          onCodeChanged: (String code) {
            //handle validation or checks here
            print(code);
          },
          //runs when every textfield is filled
          onSubmit: (String verificationCode) {
            print(verificationCode);
          }, // end onSubmit
        ),
        SizedBox(height: 20),
        Text("Didn't get OTP code?"),
        SizedBox(height: 5),
        GestureDetector(
          onTap: () {
            // Action when text is tapped
            print('Text clicked!');
            // You can also navigate or show a dialog here
          },
          child: Text(
            'Resend Code',
            style: TextStyle(
              color: Colors.red,
            ),
          ),
        ),
        SizedBox(height: 20),
        Text(
            'by entering your phone number, you are agreeing to T&C and Privacy Policy'),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            // Handle OTP verification
          },
          child: Text('Verify OTP'),
        ),
      ],
    );
  }
}

void main() {
  runApp(const OtpLogin());
}
