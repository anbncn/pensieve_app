import 'package:flutter/material.dart';

import 'HomePage.dart';

void main() {
  final theme = ThemeData();

  // better to use MaterialApp as it brings in some top level Widgets like
  // Navigator etc, and is recommended if we use Material Design
  runApp(
    MaterialApp(
      title: "PensieveApp",
      theme: theme,
      home: HomePage(),
    ),
  );
}
