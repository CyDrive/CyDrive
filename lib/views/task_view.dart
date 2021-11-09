import 'dart:async';
import 'dart:io';

import 'package:cydrive/globals.dart';
import 'package:cydrive_sdk/models/data_task.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class TaskView extends StatefulWidget {
  final DataTaskType type;

  TaskView(this.type);

  @override
  _TaskViewState createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  List<DataTask> tasks;
  Timer _reloadTimer;

  @override
  void initState() {
    super.initState();

    _reloadTasks();
    _reloadTimer = Timer.periodic(Duration(milliseconds: 10), (timer) {
      setState(() {
        _reloadTasks();
      });
    });
  }

  void _reloadTasks() {
    tasks = ftm.getTasks(widget.type);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemBuilder: _buildTaskItem, itemCount: tasks.length);
  }

  Widget _buildTaskItem(BuildContext context, int index) {
    final file = File(tasks[index].localPath);
    final task = tasks[index];
    return ListTile(
      title: Text(tasks[index].fileInfo.filePath),
      trailing: CircularProgressIndicator(
        value: task.downBytes.toDouble() / task.fileInfo.size.toDouble(),
      ),
    );
  }

  @override
  void dispose() {
    _reloadTimer.cancel();

    super.dispose();
  }
}
