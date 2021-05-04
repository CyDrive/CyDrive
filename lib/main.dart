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
      home: MyHomePage(key: Key('home'), title: 'CyDrive'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  List<Widget> _homeViews;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      var list = client.list(client.remoteDir);
      _homeViews[0] = FolderView(list);
    });
  }

  void debugButton() {
    client.login('test', 'testCyDrive');
  }

  @override
  void initState() {
    super.initState();

    _homeViews = [FolderView(null), ChannelView(), MeView()];

    client.login('test', 'testCyDrive').whenComplete(() => {
          setState(() {
            _homeViews[0] = FolderView(client.list(client.remoteDir));
          })
        });

    client.registerCallback((String dirPath) {
      var list = client.list(dirPath);
      setState(() {
        _homeViews[0] = FolderView(list);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    String title = widget.title;
    if (client.remoteDir.isNotEmpty) {
      title = client.remoteDir;
    }
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(title),
      ),
      body: Center(
          child: IndexedStack(
        index: _selectedIndex,
        children: _homeViews,
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
