import 'dart:math';

import 'package:cydrive/globals.dart';
import 'package:cydrive_sdk/models/message.pb.dart';
import 'package:flutter/material.dart';

class ChannelView extends StatefulWidget {
  final List<Message> messages;

  ChannelView(this.messages);

  @override
  _ChannelViewState createState() => _ChannelViewState();
}

class _ChannelViewState extends State<ChannelView> {
  List<Message> messages;
  final _textEditingController = TextEditingController();

  _handleSubmitted(String text) {
    client.sendText(text, "").then((msg) {
      setState(() {
        _textEditingController.clear();
        messages.add(msg);
      });
    });
  }

  @override
  void initState() {
    super.initState();

    messages = widget.messages;

    client.getMessages().then((value) {
      setState(() {
        messages = value;
      });
    });

    client.connectMessageService().then((value) {
      client.listenMessage((msg) {
        setState(() {
          messages.add(msg);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flexible(
            child: ListView.builder(
                padding: EdgeInsets.all(8.0),
                reverse: true,
                itemCount: messages.length,
                itemBuilder: _buildMessageItem)),
        Divider(height: 1.0),
        _buildTextComposer(),
      ],
    );
  }

  Widget _buildMessageItem(BuildContext context, int index) {
    var message = messages[messages.length - index - 1];
    if (message.sender == client.deviceId) {
      // It's the message the current device sended
      return ListTile(
        title: Text(
          message.content,
          textAlign: TextAlign.right,
        ),
        // subtitle: Text(
        //   message.content,
        //   textAlign: TextAlign.right,
        // ),
        trailing: Column(children: [
          Icon(Icons.phone_android),
          Container(
              width: 50,
              child: Text(
                client.deviceName,
                textScaleFactor: 0.7,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              )),
        ]),
      );
    } else {
      // A message from another device
      return ListTile(
        leading: Column(
          children: [
            Icon(
              Icons.computer_sharp,
            ),
            Container(
                width: 50,
                child: Text(
                  message.senderName,
                  textScaleFactor: 0.7,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                )),
          ],
        ),
        title: Text(message.content),
      );
    }
  }

  Widget _buildTextComposer() {
    return IconTheme(
        data: IconThemeData(color: Theme.of(context).accentColor), //
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(children: <Widget>[
            Flexible(
              child: TextField(
                controller: _textEditingController,
                onSubmitted: _handleSubmitted,
                decoration:
                    InputDecoration.collapsed(hintText: "Send a message"),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () =>
                      _handleSubmitted(_textEditingController.text)),
            ),
          ]),
        ));
  }
}
