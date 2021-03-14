import 'dart:math';

import 'package:cydrive/models/message.dart';
import 'package:flutter/material.dart';

class ChannelView extends StatefulWidget {
  @override
  _ChannelViewState createState() => _ChannelViewState();
}

class _ChannelViewState extends State<ChannelView> {
  final messages = <Message>[];
  final _textEditingController = TextEditingController();

  _handleSubmitted(String text) {}

  @override
  Widget build(BuildContext context) {
    for (var i = 0; i < 100; i++) {
      messages.add(Message());

      if (Random().nextBool()) {
        messages.last.content = 'hello, my computer ' + i.toString();
        messages.last.sender = 'phone';
      } else {
        messages.last.content = 'hello, my phone ' + i.toString();
        messages.last.sender = 'computer';
      }
    }

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
    var message = messages[index];
    if (message.sender == 'phone') {
      return ListTile(
        title: Text(
          message.content,
          textAlign: TextAlign.right,
        ),
        trailing: Icon(Icons.phone_android),
      );
    } else {
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
