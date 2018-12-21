import 'package:flutter/material.dart';

import 'Pensieve.dart';
import 'AboutPage.dart';
import 'AddPage.dart';
import 'BackupPage.dart';
import 'FeedbackPage.dart';
import 'SearchPage.dart';
import 'SettingsPage.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  String state = "Home";
  Pensieve pensieve = Pensieve();

  Widget _buildAppBar() {
    final text = (state == "Home") ? "Pensieve" : state;
    return AppBar(
      title: Text(text),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final options = ["Home", "About", "Feedback", "Settings", "Backup"];

    // auto (i.e. var) does not work as dart is unable to identify the type as
    // List<Widget> later on
    List<Widget> drawerTiles = [];
    for (final opt in options) {
      drawerTiles.add(
        ListTile(
          // TODO: change color of the text depending on state
            title: Text(opt),
            onTap: () {
              _onSelection(opt);
              Navigator.pop(context);
            }),
      );
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            // TODO: put a logo here maybe
            child: Text('Pensieve'),
            decoration: BoxDecoration(color: Colors.blue),
          ),
          Column(children: drawerTiles),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    if (state == "Home") {
      return FloatingActionButton(
          child: Icon(Icons.add), tooltip: 'Add', onPressed: _onAdd);
    }
    return null;
  }

  Widget _buildBody() {
    switch (state) {
      case "About":
        return AboutPage();
        break;
      case "Feedback":
        return FeedbackPage();
        break;
      case "Settings":
        return SettingsPage();
        break;
      case "Backup":
        return BackupPage();
        break;
      case "Add":
        return AddPage(pensieve: pensieve,);
        break;
      case "Search":
        return SearchPage(pensieve: pensieve,);
        break;
    }

    // default
    return SearchPage(pensieve: pensieve,);
  }

  void _onAdd() {
    _onSelection("Add");
  }

  void _onSearch() {
    _onSelection("Search");
  }

  void _onSelection(String option) {
    // causes to rerun the build
    setState(() {
      state = option;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: _buildDrawer(context),
      floatingActionButton: _buildAddButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _buildBody(),
    );
  }
}