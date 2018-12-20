import 'package:flutter/material.dart';

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

Widget _buildAppBar() {
  return AppBar(
    title: Text("Pensieve"),
  );
}

Widget _buildDrawer(BuildContext context) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          // TODO: put a logo maybe here
          child: Text('Pensieve'),
          decoration: BoxDecoration(color: Colors.blue),
        ),
        ListTile(
            title: Text('About'),
            onTap: () {
              Navigator.pop(context);
            }),
        ListTile(
            title: Text('Feedback'),
            onTap: () {
              Navigator.pop(context);
            }),
        ListTile(
            title: Text('Settings'),
            onTap: () {
              Navigator.pop(context);
            }),
        ListTile(
            title: Text('Backup'),
            onTap: () {
              Navigator.pop(context);
            }),
      ],
    ),
  );
}

Widget _buildAddButton() {
  return FloatingActionButton(
      child: Icon(Icons.add), tooltip: 'Add', onPressed: null);
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // using a Scaffold (which is stateful) to manage the layout
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: _buildDrawer(context),
      floatingActionButton: _buildAddButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Center(
        child: Text('Display'),
      ),
    );
  }
}
