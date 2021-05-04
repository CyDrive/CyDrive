import 'package:cydrive/models/file.dart';
import 'package:cydrive/utils.dart';
import 'package:flutter/material.dart';
import 'package:cydrive/globals.dart';

class FolderView extends StatefulWidget {
  Future<List<FileInfo>> fileInfoList;

  FolderView(this.fileInfoList);

  @override
  _FolderViewState createState() => _FolderViewState();
}

class _FolderViewState extends State<FolderView> {
  List<FileInfo> fileInfoList;
  BuildContext _context;

  @override
  Widget build(BuildContext context) {
    // for (var i = 0; i < 100; i++) {
    //   widget.fileInfoList.add(FileInfo());
    //   widget.fileInfoList.last.size = Random().nextInt(1 << 30);
    //   widget.fileInfoList.last.filename = 'file_' + i.toString();
    // }
    _context = context;

    return FutureBuilder<List<FileInfo>>(
      future: widget.fileInfoList,
      builder: (BuildContext context, AsyncSnapshot<List<FileInfo>> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Stack(
              children: [
                Text(
                  "failed to connect to the server",
                  textScaleFactor: 1.5,
                ),
                ElevatedButton(
                    child: Text('retry'),
                    onPressed: () {
                      _onRefresh();
                    })
              ],
            ),
          );
        } else if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          fileInfoList = [];
          if (client.remoteDir.isNotEmpty) {
            fileInfoList.add(lastDir(client.remoteDir));
          }
          fileInfoList.addAll(snapshot.data);
          fileInfoList.sort((a, b) {
            if (a.filename == '..') return -1;
            if (a.isDir != b.isDir) {
              if (a.isDir) {
                return -1;
              } else {
                return 1;
              }
            } else {
              return a.filename.compareTo(b.filename);
            }
          });
          return RefreshIndicator(
              child: ListView.builder(
                itemBuilder: _buildFileItem,
                itemCount: fileInfoList.length,
              ),
              onRefresh: _onRefresh);
        }
      },
    );
  }

  Future<void> _onRefresh() async {
    setState(() {
      widget.fileInfoList = client.list(client.remoteDir);
    });
  }

  Widget _buildFileItem(BuildContext context, int index) {
    IconData icon = Icons.file_copy_sharp;
    if (fileInfoList[index].isDir) {
      icon = Icons.folder_open_sharp;
    }
    return ListTile(
      leading: Icon(icon),
      title: Text(fileInfoList[index].filename),
      trailing: _buildSizeText(fileInfoList[index].size),
      onTap: () {
        if (fileInfoList[index].isDir) {
          // var list = client.list(fileInfoList[index].filePath);
          // Navigator.push(_context,
          //     MaterialPageRoute(builder: (context) => FolderView(list)));
          client.remoteDir = fileInfoList[index].filePath;
        }
      },
    );
  }

  Widget _buildSizeText(int size) {
    const units = ["B", "KiB", "MiB", "GiB"];
    int unitIndex = 0;
    while (unitIndex + 1 < units.length && size >= 1024) {
      size >>= 10;
      unitIndex++;
    }

    return Text(size.toString() + ' ' + units[unitIndex]);
  }
}
