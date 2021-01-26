import 'package:flutter/material.dart';

class ExceptionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ErrorWidget(
          Exception("An error occurred when building future"),
        ),
      ),
    );
  }
}
