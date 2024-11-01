import 'package:flutter/material.dart';
import 'package:easy_scoot/appwrite/auth.dart';
import 'package:provider/provider.dart';
import 'package:easy_scoot/pages/otpLogin.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<Home> {
  late String? email;
  late String? username;
  TextEditingController bioTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final AuthAPI appwrite = context.read<AuthAPI>();
    email = appwrite.email;
    username = appwrite.username;
    appwrite.getUserPreferences().then((value) {
      if (value.data.isNotEmpty) {
        setState(() {
          bioTextController.text = value.data['bio'];
        });
      }
    });
  }

  // savePreferences() {
  //   final AuthAPI appwrite = context.read<AuthAPI>();
  //   appwrite.updatePreferences(bio: bioTextController.text);
  //   const snackbar = SnackBar(content: Text('Preferences updated!'));
  //   ScaffoldMessenger.of(context).showSnackBar(snackbar);
  // }

  Logout() {
    final AuthAPI appwrite = context.read<AuthAPI>();
    appwrite.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => OTPVerificationPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('My Account'),
          actions: [
            Text(
              "Logout",
              style: TextStyle(color: Colors.red),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              color: Colors.red,
              onPressed: () {
                Logout();
              },
            ),
          ],
        ),
        body: Center(
          child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Welcome back $username!',
                      style: Theme.of(context).textTheme.headlineSmall),
                  Text('$email'),
                  const SizedBox(height: 40),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(children: [
                        TextField(
                          controller: bioTextController,
                          decoration: const InputDecoration(
                            labelText: 'Your Bio',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => {},
                          child: const Text('Save Preferences'),
                        ),
                      ]),
                    ),
                  )
                ],
              )),
        ));
  }
}
