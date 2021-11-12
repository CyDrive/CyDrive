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
    client.sendText(text, 0).then((msg) {
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
    if (message.sender == 1) {
      // It's the message the current device sended
      return ListTile(
        title: Text(
          message.content,
          textAlign: TextAlign.right,
        ),
        trailing: Icon(Icons.phone_android),
      );
    } else {
      // A message from another device
      return ListTile(
        leading: Icon(Icons.computer_sharp),
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
