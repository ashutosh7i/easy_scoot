import 'package:flutter/material.dart';

class CustomAccentButton extends StatelessWidget {
  final String btnText;
  final VoidCallback onClick;

  const CustomAccentButton({
    Key? key,
    required this.btnText,
    required this.onClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onClick,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFF7F8C0),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: BorderSide(color: Colors.black)),
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0),
      ),
      child: Text(
        btnText,
        style: TextStyle(
          color: Colors.black,
          fontSize: 16.0,
          //fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
