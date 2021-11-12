import 'dart:async';
import 'dart:io';

import 'package:cydrive/globals.dart';
import 'package:cydrive/utils.dart';
import 'package:cydrive_sdk/models/data_task.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
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
    double progress = task.downBytes.toDouble() / task.fileInfo.size.toDouble();

    var taskPopMenuItems = <PopupMenuEntry>[
      PopupMenuItem(
        child: Text('Open'),
        value: 'Open',
      ),
      PopupMenuItem(
        child: Text('Re-download'),
        value: 'Download',
      ),
      PopupMenuItem(
        child: Text('Share'),
        value: 'Share',
      ),
      PopupMenuItem(
        child: Text('Delete'),
        value: 'Delete',
      ),
    ];

    return ListTile(
      leading: SizedBox(
          height: 50,
          width: 50,
          child: Stack(
            children: [
              Center(
                  child: Container(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator(
                        value: progress,
                      ))),
              Center(child: Text('${(progress * 100).toStringAsFixed(1)}%')),
            ],
          )),
      title: Text(task.fileInfo.filePath),
      subtitle: buildSizeText(task.fileInfo),
      trailing: PopupMenuButton(
        itemBuilder: (BuildContext context) => taskPopMenuItems,
        onSelected: (item) {
          switch (item) {
            case 'Open':
              if (!file.existsSync()) {
                client
                    .download(task.fileInfo.filePath,
                        filesDirPath + task.fileInfo.filePath,
                        shouldTruncate: true)
                    .then((value) => ftm.addTask(value));
              } else {
                OpenFile.open(file.path,
                    type: lookupMimeType(task.fileInfo.filePath));
              }
              break;

            case 'Download':
              client
                  .download(task.fileInfo.filePath,
                      filesDirPath + task.fileInfo.filePath,
                      shouldTruncate: true)
                  .then((value) {
                ftm.addTask(value);
              });
              break;

            case 'Share':
              client.share(task.fileInfo.filePath).then((value) {
                Clipboard.setData(ClipboardData(text: value)).whenComplete(() =>
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('has copied the share-link: $value'))));
              });

              break;

            case 'Delete':
              if (file.existsSync()) {
                file.deleteSync();
              }
              showDeleteDialog(context).then((value) {
                if (value) {
                  client.delete(task.fileInfo.filePath);
                }
              });
              break;
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _reloadTimer.cancel();

    super.dispose();
  }
}
