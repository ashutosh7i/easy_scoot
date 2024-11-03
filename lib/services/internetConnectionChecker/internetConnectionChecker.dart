import 'dart:async';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class InternetCheckWrapper extends StatefulWidget {
  final Widget child;

  const InternetCheckWrapper({Key? key, required this.child}) : super(key: key);

  @override
  _InternetCheckWrapperState createState() => _InternetCheckWrapperState();
}

class _InternetCheckWrapperState extends State<InternetCheckWrapper> {
  late StreamSubscription<InternetStatus> _listener;
  bool _showOverlay = false;

  @override
  void initState() {
    super.initState();
    _checkInitialConnection();
    _startListening();
  }

  void _checkInitialConnection() async {
    bool result = await InternetConnection().hasInternetAccess;
    setState(() {
      _showOverlay = !result;
    });
  }

  void _startListening() {
    _listener =
        InternetConnection().onStatusChange.listen((InternetStatus status) {
      setState(() {
        _showOverlay = status == InternetStatus.disconnected;
      });
    });
  }

  @override
  void dispose() {
    _listener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          children: [
            widget.child,
            if (_showOverlay)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('No Internet Connection',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        Image.asset('assets/images/nointernet.png',
                            height: 150),
                        Text('No internet Access',
                            style: TextStyle(fontSize: 15)),
                        Text('Turn on Internet to use this application',
                            style: TextStyle(
                              fontSize: 14,
                            )),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            _checkInitialConnection();
                          },
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ));
  }
}
