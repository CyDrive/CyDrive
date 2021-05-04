import 'package:cydrive/models/file.dart';
import 'package:flutter/material.dart';
import 'views/folder_view.dart';
import 'views/channel_view.dart';
import 'views/me_view.dart';
import 'globals.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
    client.login('test', 'testCyDrive');
  }

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  Future<List<FileInfo>> fileInfoList = Future.value([]);

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
      fileInfoList = client.list(widget.title);
    });
  }

  void debugButton() {
    client.login('test', 'testCyDrive');
  }

  @override
  void initState() {
    super.initState();

    fileInfoList = client.list(widget.title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
          child: IndexedStack(
        index: _selectedIndex,
        children: [
          FolderView(fileInfoList, widget.title, (FileInfo fileInfo) {
            if (fileInfo.isDir) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MyHomePage(
                            key: widget.key,
                            title: fileInfo.filePath,
                          )));
            }
          }),
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
          BottomNavigationBarItem(icon: Icon(Icons.person_sharp), label: "Me"),
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
  }
}
