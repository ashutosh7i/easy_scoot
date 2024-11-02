import 'package:flutter/material.dart';
import 'package:easy_scoot/widgets/customAccentButton.dart';

class WelcomePage extends StatelessWidget {
  final VoidCallback onStart;

  WelcomePage({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(),
          // Welcome Card
          Container(
            width: 300,
            padding: EdgeInsets.symmetric(horizontal: 35.0, vertical: 30.0),
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
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 20),
                CustomAccentButton(btnText: "Start", onClick: onStart)
              ],
            ),
          ),
          Spacer()
        ],
      ),
    );
  }
}
