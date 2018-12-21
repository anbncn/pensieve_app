import 'package:flutter/material.dart';

import 'HomePage.dart';

void main() {
  // better to use MaterialApp as it brings in some top level Widgets like
  // Navigator etc, and is recommended if we use Material Design
  runApp(
    MaterialApp(
      title: "PensieveApp",
      home: HomePage(),
    ),
  );
}