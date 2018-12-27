import 'package:flutter/material.dart';

import 'Pensieve.dart';
import 'HomePage.dart';

void main() {
  // make it a global variable for now
  // maybe use BLoC later
  Pensieve pensieve = Pensieve();

  // better to use MaterialApp as it brings in some top level Widgets like
  // Navigator etc, and is recommended if we use Material Design
  runApp(
    MaterialApp(
      title: "PensieveApp",
      theme: ThemeData.light(),
      home: HomePage(pensieve: pensieve),
    ),
  );
}
