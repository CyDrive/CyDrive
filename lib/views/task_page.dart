import 'package:cydrive/views/task_view.dart';
import 'package:cydrive_sdk/models/data_task.dart';
import 'package:flutter/material.dart';

class FileTransferPage extends StatefulWidget {
  @override
  _FileTransferPageState createState() => _FileTransferPageState();
}

class _FileTransferPageState extends State<FileTransferPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks'),
      ),
      body: Center(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            TaskView(DataTaskType.Download),
            TaskView(DataTaskType.Upload),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.download_sharp), label: 'Download'),
          BottomNavigationBarItem(
              icon: Icon(Icons.upload_sharp), label: 'Upload'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onBottomItemTapped,
      ),
    );
  }

  void _onBottomItemTapped(int index) {
    if (index == _selectedIndex) {
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }
}
