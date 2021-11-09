import 'dart:async';

import 'package:cydrive/consts.dart';
import 'package:cydrive/views/dir_picker.dart';
import 'package:cydrive/views/file_transfer_page.dart';
import 'package:cydrive_sdk/models/account.pb.dart';
import 'package:cydrive_sdk/models/file_info.pb.dart';
import 'package:cydrive_sdk/utils.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'views/folder_view.dart';
import 'views/channel_view.dart';
import 'views/me_view.dart';
import 'globals.dart';
import 'dart:io';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // mimeTypeResolver.addExtension('md', 'text/plain');

    return MaterialApp(
      title: 'CyDrive',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.deepPurple,
      ),
      home: MyHomePage(key: Key('home'), title: ''),
    );
  }
}

class MyHomePage extends StatefulWidget {
  // title is the current dir path
  // empty title => root path
  // and in the case display CyDrive
  MyHomePage({Key key, this.title}) : super(key: key) {
    getApplicationSupportDirectory().then((value) {
      filesDirPath = value.path;
    });
  }

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  StreamSubscription _intentDataStreamSubscription;
  Future<bool> _isLogin = Future.value(false);

  @override
  void initState() {
    super.initState();
    Account account = Account(
      email: 'test@cydrive.io',
      password: passwordHash('hello_world'),
    );
    _isLogin = client.login(account: account);

    ReceiveSharingIntent.getMediaStream().listen(recvSharedFileHandle);
    ReceiveSharingIntent.getInitialMedia().then(recvSharedFileHandle);
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String title = 'CyDrive';
    if (widget.title.isNotEmpty) {
      title = widget.title;
    }

    return FutureBuilder<bool>(
        future: _isLogin,
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "failed to login: " + snapshot.error.toString(),
                    textScaleFactor: 1.5,
                  ),
                  ElevatedButton(
                      child: Text('retry'),
                      onPressed: () {
                        _isLogin = client.login();
                      })
                ],
              ),
            );
          } else if (snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                // Here we take the value from the MyHomePage object that was created by
                // the App.build method, and use it to set our appbar title.
                title: Text(title),
                actions: [
                  _appBarPopMenuButton(),
                ],
              ),
              body: Center(
                  child: IndexedStack(
                index: _selectedIndex,
                children: [
                  FolderView(widget.title, onListItemTapped()),
                  ChannelView(),
                  MeView(),
                ],
              )),
              bottomNavigationBar: BottomNavigationBar(
                items: [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.folder_sharp), label: 'Files'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.message_sharp), label: "Channel"),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.person_sharp), label: "Me"),
                ],
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: debugButton,
                tooltip: 'debug',
                child: Icon(Icons.add),
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  void debugButton() {
    Account account = Account(
      email: 'test@cydrive.io',
      password: passwordHash('hello_world'),
    );
    client.login(account: account).then((value) {
      if (value) {
        setState(() {});
      }
    });
  }

  Function(FileInfo fileInfo) onListItemTapped(
      {ListFilter filter = ListFilter.All, bool chooseFolder = false}) {
    if (chooseFolder) {
      return (FileInfo fileInfo) {};
    } else {
      return (FileInfo fileInfo) {
        if (fileInfo.isDir) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MyHomePage(
                        key: widget.key,
                        title: fileInfo.filePath,
                      )));
        } else {
          if (!File(filesDirPath + fileInfo.filePath).existsSync()) {
            client
                .download(fileInfo.filePath, filesDirPath + fileInfo.filePath)
                .then((task) {
              ftm.addTask(task);
              OpenFile.open(filesDirPath + fileInfo.filePath,
                  type: lookupMimeType(fileInfo.filePath));
            });
          } else {
            OpenFile.open(filesDirPath + fileInfo.filePath,
                type: lookupMimeType(fileInfo.filePath));
          }
        }
      };
    }
  }

  void recvSharedFileHandle(List<SharedMediaFile> sharedFiles) {
    if (sharedFiles.isEmpty) {
      return;
    }
    stderr.writeln(sharedFiles.map((e) => e.path).join("\n"));
    Navigator.push(context,
            MaterialPageRoute(builder: (context) => DirPickerPage("/")))
        .then((value) {
      for (var mediaFile in sharedFiles) {
        // client.upload(mediaFile.path, value);
      }
    });
  }

  Widget _appBarPopMenuButton() {
    return PopupMenuButton(
      itemBuilder: (BuildContext context) => [
        PopupMenuItem(
          child: Text('New Folder'),
          value: 0,
        ),
        PopupMenuItem(
          child: Text('Tasks'),
          value: 1,
        )
      ],
      onSelected: (index) {
        switch (index) {
          case 1:
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => FileTransferPage()));
            break;
        }
      },
    );
  }
}
