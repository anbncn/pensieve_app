import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'Pensieve.dart';

class BackupPage extends StatefulWidget {
  final Pensieve pensieve;
  BackupPage({Key key, this.pensieve}) : super(key: key);

  @override
  _BackupPageState createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  GoogleSignIn _googleSignIn = GoogleSignIn();
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  String email;
  String userId;
  bool signedIn = false;
  bool godmode = false;
  StorageMetadata metadata;

  Future<void> _signInWithGoogle() async {
    // sign into Google
    GoogleSignInAccount currUser = _googleSignIn.currentUser;

    if (currUser == null) {
      currUser = await _googleSignIn.signInSilently();
    }

    if (currUser == null) {
      currUser = await _googleSignIn.signIn();
    }

    if (currUser == null) {
      print("Google Signin failed!");
      return false;
    }
    print(currUser.toString());

    // sign into Firebase using Google sign in
    GoogleSignInAuthentication auth = await currUser.authentication;
    FirebaseUser fireUser = await _firebaseAuth.signInWithGoogle(
        idToken: auth.idToken, accessToken: auth.accessToken);

    if (fireUser == null || fireUser.uid.isEmpty) {
      print("Firebase Signin failed!");
      return false;
    }
    print(fireUser.toString());

    // keep track of session to make future operations
    email = currUser.email;
    userId = fireUser.uid;
    metadata = await _metadata();
    _googleSignIn.isSignedIn().then((status) {
      signedIn = status;
    });

    //redraw
    _redraw();
  }

  Future<void> _signOutWithGoogle() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
    _googleSignIn.isSignedIn().then((status) {
      signedIn = status;
    });

    //redraw
    _redraw();
  }

  Future<StorageReference> _ref() async {
    final cloudPath = 'users/' + userId + "/" + 'messages.json';
    return FirebaseStorage.instance.ref().child(cloudPath);
  }

  Future<StorageMetadata> _metadata() async {
    try {
      final md =
          (await _ref()).getMetadata().catchError((e) => print(e.toString()));
      return md;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<void> _backup() async {
    final file = await widget.pensieve.fileManager.localFile;
    final localMetadata = StorageMetadata(customMetadata: {
      "numMessages": "${widget.pensieve.numMessages}",
      "lastModified": "${widget.pensieve.lastModified}"
    });
    final StorageUploadTask task = (await _ref()).putFile(file, localMetadata);

    // update the metadata using remote value
    final snapshot = await task.onComplete;
    metadata = await _metadata();

    //redraw
    _redraw();
  }

  Future<void> _fetch() async {
    final file = await widget.pensieve.fileManager.localFile;
    final StorageFileDownloadTask task = (await _ref()).writeToFile(file);

    // wait for download to complete and then reload into pensieve
    final snapshot = await task.future;
    widget.pensieve.loadFile();

    //redraw
    _redraw();
  }

  Future<void> _resetLocal() async {
    await widget.pensieve.fileManager.reset();
    widget.pensieve.loadFile();

    //redraw
    _redraw();
  }

  Future<void> _resetCloud() async {
    // returns Future<void>
    (await _ref()).delete().catchError((e) => print(e.toString()));
  }

  // shorthand
  void _redraw() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // non-blocking
    final localNumMessages = widget.pensieve.numMessages;
    DateTime localLastModified = widget.pensieve.lastModified;
    final formatter = DateFormat.yMMMd().add_jm();
    final localLastModifiedFormatted =
        localLastModified == null ? "NA" : formatter.format(localLastModified);
    final int localFileSizeKB = (widget.pensieve.fileManager.fileSize).round();

    // non-blocking
    final remoteNumMessages =
        metadata != null && metadata.customMetadata.isNotEmpty
            ? metadata.customMetadata["numMessages"]
            : 0;
    final remoteLastModified =
        metadata != null && metadata.customMetadata.isNotEmpty
            ? DateTime.tryParse(metadata.customMetadata["lastModified"])
            : null;
    final remoteLastModifiedFormatted = remoteLastModified == null
        ? "NA"
        : formatter.format(remoteLastModified);
    final int remoteFileSizeKB =
        metadata != null ? (metadata.sizeBytes).round() : 0;

    Widget _localMetadata() {
      return Text(localLastModifiedFormatted +
          " / $localNumMessages / ${localFileSizeKB}B");
    }

    Widget _remoteMetadata() {
      return Text(remoteLastModifiedFormatted +
          " / $remoteNumMessages / ${remoteFileSizeKB}B");
    }

    Widget _signInStatus() {
      final text = signedIn ? "Signed in as $email" : "";
      return Text(
        text,
        overflow: TextOverflow.ellipsis,
      );
    }

    Widget _signInButton() {
      return RaisedButton(
        onPressed: signedIn ? null : _signInWithGoogle,
        child: Text('SIGN IN WITH GOOGLE'),
      );
    }

    Widget _signOutButton() {
      return RaisedButton(
        onPressed: !signedIn ? null : _signOutWithGoogle,
        child: Text('SIGN OUT WITH GOOGLE'),
      );
    }

    Widget _uploadButton() {
      return RaisedButton(
          onPressed: signedIn ? _backup : null, child: Text('UPLOAD'));
    }

    Widget _downloadButton() {
      return RaisedButton(
          onPressed: signedIn ? _fetch : null, child: Text('DOWNLOAD'));
    }

    Widget _resetLocalButton(BuildContext context) {
      return RaisedButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Are you sure?'),
                    actions: [
                      FlatButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('No')),
                      FlatButton(
                          onPressed: () {
                            _resetLocal();
                            Navigator.of(context).pop();
                          },
                          child: Text('Yes')),
                    ],
                  );
                });
          },
          child: Text('RESET LOCAL'));
    }

    Widget _resetCloudButton(BuildContext context) {
      return RaisedButton(
          onPressed: godmode ? _resetCloud : null,
          textColor: Colors.red,
          child: Text('RESET CLOUD'));
    }

    return Scaffold(
        appBar: AppBar(
          title: Text('Backup'),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(flex: 1, child: Container()),
              Expanded(flex: 1, child: _signInButton()),
              Expanded(flex: 1, child: Container()),
              Expanded(flex: 1, child: _signOutButton()),
              Expanded(flex: 1, child: _signInStatus()),
              Expanded(flex: 1, child: _uploadButton()),
              Expanded(flex: 1, child: _localMetadata()),
              Expanded(flex: 1, child: _downloadButton()),
              Expanded(flex: 1, child: _remoteMetadata()),
              Expanded(flex: 9, child: Container()),
              Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _resetLocalButton(context),
                      _resetCloudButton(context)
                    ],
                  )),
              Expanded(flex: 1, child: Container()),
            ],
          ),
        ));
  }
}
