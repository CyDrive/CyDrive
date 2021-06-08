import 'dart:async';
import 'dart:io';

import 'package:cydrive/globals.dart';
import 'package:cydrive/models/task.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class TaskView extends StatefulWidget {
  final TaskType type;

  TaskView({this.type = TaskType.All});

  @override
  _TaskViewState createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  List<Task> tasks;
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
    tasks = client.taskMap.entries
        .where((element) => element.value.type == widget.type)
        .map((e) => e.value)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemBuilder: _buildTaskItem, itemCount: tasks.length);
  }

  Widget _buildTaskItem(BuildContext context, int index) {
    final file = File(join(filesDirPath, tasks[index].fileInfo.filePath));
    double progressPercent = 0;
    if (file.existsSync()) {
      var fileSize = file.statSync().size;
      progressPercent = fileSize / tasks[index].fileInfo.size;
    }
    return ListTile(
      title: Text(tasks[index].fileInfo.filename),
      trailing: CircularProgressIndicator(
        value: progressPercent,
      ),
    );
  }

  @override
  void dispose() {
    _reloadTimer.cancel();

    super.dispose();
  }
}
