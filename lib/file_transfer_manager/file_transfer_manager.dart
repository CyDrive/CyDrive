import 'package:cydrive_sdk/models/data_task.dart';

class FileTransferManager {
  Map<int, DataTask> _tasks = Map();

  List<DataTask> getTasks(DataTaskType type) {
    return _tasks.values.where((element) => element.type == type).toList();
  }

  void addTask(DataTask task) {
    _tasks[task.id] = task;
  }
}
