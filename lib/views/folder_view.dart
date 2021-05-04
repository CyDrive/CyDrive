import 'package:cydrive/models/file.dart';
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

  @override
  Widget build(BuildContext context) {
    // for (var i = 0; i < 100; i++) {
    //   widget.fileInfoList.add(FileInfo());
    //   widget.fileInfoList.last.size = Random().nextInt(1 << 30);
    //   widget.fileInfoList.last.filename = 'file_' + i.toString();
    // }

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
          fileInfoList = snapshot.data;
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
    return ListTile(
      leading: Icon(Icons.file_copy_sharp),
      title: Text(fileInfoList[index].filename),
      trailing: _buildSizeText(fileInfoList[index].size),
      onTap: () {
        if (fileInfoList[index].isDir) {
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
