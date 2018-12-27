import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import "package:path_provider/path_provider.dart";

import 'Pensieve.dart';

class BackupPage extends StatefulWidget {
  final Pensieve pensieve;
  BackupPage({Key key, this.pensieve}) : super(key : key);

  @override
  _BackupPageState createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  GoogleSignIn _googleSignIn = GoogleSignIn();
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String userId;
  bool signedIn = false;

  Future<bool> _signInWithGoogle() async {
    // sign into Google
    GoogleSignInAccount currUser = _googleSignIn.currentUser;

    if (currUser == null) {
      currUser = await _googleSignIn.signInSilently();
    }

    if (currUser == null) {
      currUser = await _googleSignIn.signIn();
    }

    print(currUser.toString());

    // sign into Firebase using Google sign in
    GoogleSignInAuthentication auth = await currUser.authentication;
    FirebaseUser fireUser = await _firebaseAuth.signInWithGoogle(
        idToken: auth.idToken,
        accessToken: auth.accessToken
    );

    userId = fireUser.uid;

    print(fireUser.toString());

    return _googleSignIn.isSignedIn();
  }

  Future<bool> _signOutWithGoogle() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
    return _googleSignIn.isSignedIn();
  }

  void _backup() async {
    // get file from pensieve later
    final dir = await getApplicationDocumentsDirectory();
    final file = await widget.pensieve.fileManager.localFile;
    final cloudPath = 'users/' + userId + "/" + 'messages.json';

    final StorageReference ref = FirebaseStorage.instance.ref().child(cloudPath);
    final StorageUploadTask task = ref.putFile(file);
  }

  void _fetch() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/messages.json");
    final cloudPath = 'users/' + userId + "/" + 'messages.json';

    final StorageReference ref = FirebaseStorage.instance.ref().child(cloudPath);
    final StorageFileDownloadTask task = ref.writeToFile(file);

    // wait for download to complete and then reload
    final snapshot = await task.future;
    widget.pensieve.loadFile();
  }

  void _reset() async {
    await widget.pensieve.fileManager.reset();
    widget.pensieve.loadFile();
  }

  // shorthand
  void _redraw(status) { setState(() { signedIn = status; }); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Backup'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(flex: 1, child: Container(),),
            Expanded(flex: 1, child: RaisedButton(
                onPressed: () { _signInWithGoogle().then(_redraw); },
                child: Text('SIGN IN WITH GOOGLE')),
            ),
            Expanded(flex: 1, child: Container(),),
            Expanded(flex: 1, child: RaisedButton(
                onPressed: () { _signOutWithGoogle().then(_redraw); },
                child: Text('SIGN OUT WITH GOOGLE')),
            ),
            Expanded(flex: 1, child: Container(),),
            Expanded(flex: 1, child: Row(
              children: <Widget>[
                RaisedButton(
                    onPressed: () { _googleSignIn.isSignedIn().then(_redraw); },
                    child: Text('LOGIN STATUS')
                ),
                Text(signedIn ? '  Signed In  ' : '  Not Signed In  '),
              ],
            ),),
            Expanded(flex: 1, child: Container(),),
            Expanded(flex: 1, child: Row(
              children: <Widget>[
                RaisedButton(
                    onPressed: signedIn ? _fetch : null,
                    child: Text('DOWNLOAD CLOUD COPY')
                ),
                Text('  last_backup_time and size  '),
              ],
            ),),
            Expanded(flex: 1, child: Container(),),
            Expanded(flex: 1, child: Row(
              children: <Widget>[
                RaisedButton(
                    onPressed: signedIn ? _backup : null,
                    child: Text('UPLOAD LOCAL COPY')
                ),
                Text('  last_time and size  '),
              ],
            ),),
            Expanded(flex: 1, child: Container(),),
            Expanded(flex: 1, child: Row(
              children: <Widget>[
                RaisedButton(
                    onPressed: _reset,
                    child: Text('RESET LOCAL COPY')
                ),
                Text('  last_time and size  '),
              ],
            ),),
            Expanded(flex: 10, child: Container(),),
          ],
        ),)
    );
  }
}
