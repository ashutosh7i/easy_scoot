import 'package:easy_scoot/widgets/customAccentButton.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

//STEP 2: Personal Details Page
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
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Personal Details',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text('Fill your details and click continue.')
                ],
              ),
            ),
            Spacer(),
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
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () async {
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
            Spacer(
              flex: 2,
            ),
            CustomAccentButton(
              btnText: 'Continue',
              onClick: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    // final data = {
                    //   'firstName': _firstNameController.text,
                    //   'lastName': _lastNameController.text,
                    //   'email': _emailController.text,
                    //   'dateOfBirth': selectedDate != null
                    //       ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                    //       : null,
                    // };

                    // await DatabaseAPI().updateUserInfo(data);

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
                  } catch (e) {
                    print('Error updating user info: $e');
                    // Handle the error, maybe show a snackbar or dialog
                  }
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
