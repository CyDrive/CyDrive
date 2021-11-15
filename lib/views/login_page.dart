import 'dart:async';
import 'dart:io';

import 'package:cydrive/globals.dart';
import 'package:cydrive/main.dart';
import 'package:cydrive/utils.dart';
import 'package:cydrive_sdk/models/account.pb.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class LogInData{
  Account account;
  bool isShowPwd,isShowClear,isRememberPwd,isAutoLogin;

  LogInData({String email='', String password=''}){
    this.account = Account(email: email, password: password);
    this.isShowPwd = this.isShowClear = this.isRememberPwd = this.isAutoLogin = false;
  }

  LogInData.fromjson(Map<String, dynamic> json)
      : account = Account(email: json['email'],password: json['passoword']),
        isRememberPwd = json['isRememberPwd'],
        isAutoLogin = json['isAutoLogin'];

   Map<String, dynamic> toJson() => {
        'email': account.email,
        'password': account.password,
        'isRememberPwd': isRememberPwd,
        'isAutoLogin': isAutoLogin
      };
}


class LogInPageState extends State<MyHomePage> {

  LogInData logInData = LogInData(email: 'test@cydrive.io', password: 'hello_world');
  FocusNode focusNodeEmail = new FocusNode();
  FocusNode focusNodePassword = new FocusNode();

  GlobalKey<FormState> logFormState = GlobalKey<FormState>();

  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  // String data
  String dataPath;
  Future<String> logInDataCallback;

  Future<Null> focusNodeListrener()async{
    if(focusNodeEmail.hasFocus){
      focusNodePassword.unfocus();
    }

    if(focusNodePassword.hasFocus){
      focusNodeEmail.unfocus();
    }
  }

  String checkEmail(value){
    RegExp exp = RegExp(r'^[a-zA-Z0-9_-]+@[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)+$');
    if (value.isEmpty){
      return "邮箱不能为空";
    }else if (! exp.hasMatch(value)){
      return "邮箱格式错误";
    }
    return null;
  }

  String checkPassword(value){
    if (value.isEmpty){
      return "密码不能为空";
    }
    return null;
  }

  Future<String> loadLogInData()async{
    await widget.dataReady;
    print('$filesCachePath' + "/account.json");
    Directory dir = Directory(filesCachePath);
    if (!await dir.exists())
      await dir.create();
    File file = File('$filesCachePath' + "/account.json");
    if (!await file.exists())
      await file.create();  
    var jsonString = await file.readAsString();
    return jsonString;
  }

  Future<bool> saveLogInData()async{
    await widget.dataReady;
    try{
      File file = File(dataPath);
      file.writeAsString(logInData.toJson().toString());
    } catch (e){
      print(e);
      return false;
    }
    return true;    
  }

  @override
  void initState(){
    print("init LoginPageState");
    logInDataCallback=loadLogInData();
    focusNodeEmail.addListener(focusNodeListrener);
    focusNodePassword.addListener(focusNodeListrener);

    passwordController.text = logInData.account.password;
    emailController.text = logInData.account.email;    
    emailController.addListener(() {
      if(emailController.text.length > 0){
        logInData.isShowClear = true;
      }else{
        logInData.isShowClear = false;
      }
    });
    super.initState();
  }

  @override
  void dispose(){
    focusNodeEmail.removeListener(focusNodeListrener);
    focusNodePassword.removeListener(focusNodeListrener);
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    Widget emailTextFiled = new TextFormField(
              controller: emailController,
              focusNode: focusNodeEmail,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "email",
                hintText: "请输入邮箱账号",
                prefixIcon: Icon(Icons.email),
                suffixIcon: (logInData.isShowClear)?IconButton(onPressed: (){emailController.clear();}, icon: Icon(Icons.clear)):null, 
              ),
              validator: checkEmail,
              onSaved: (String value){
                logInData.account.email = value;
              },
            );

    Widget passwordTextFiled = new TextFormField(
              controller: passwordController,
              focusNode: focusNodePassword,
              decoration: InputDecoration(
                labelText: "password",
                hintText: "请输入密码",
                prefixIcon: Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon((logInData.isShowPwd)?Icons.visibility : Icons.visibility_off),
                  onPressed: (){
                    setState(() {
                      logInData.isShowPwd = !logInData.isShowPwd;
                    });
                  },
                ) 
              ),
              obscureText: !logInData.isShowPwd,
              validator: checkPassword,
              onSaved: (String value){
                logInData.account.password = value;
              },
            );

    Widget inputTextArea = new Container(
      margin: EdgeInsets.only(left: 20, right: 20),
      decoration: new BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: Colors.white
      ),
      child: new Form(
        key: logFormState,
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            emailTextFiled,
            passwordTextFiled
          ],
        )
      )
    );

Widget loginButtonArea = new Container(
      margin: EdgeInsets.only(left: 20,right: 20),
      height: 55.0,
      child: new ElevatedButton(
        child: Text(
          "登录",
          style: Theme.of(context).primaryTextTheme.headline4,

        ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.blue[300])
        ),
        onPressed: (){
          saveLogInData().then((ok){if (!ok) print("data Cache error");});
          focusNodePassword.unfocus();
          focusNodeEmail.unfocus();

          if (logFormState.currentState.validate()) {
            logFormState.currentState.save();
            print('${logInData.account}');
            client.login(account: logInData.account).then((ok){
              if(ok){
                print("登录成功");
              } else{
                print("登录失败");
              }
            });
            print("$logInData");
          }

        },
      ),
    );

  Widget rememberCheckBox = new CheckboxListTile(
    title: const Text('记住密码'),
    value: logInData.isRememberPwd,
    onChanged: (bool value) {
        setState(() {
            logInData.isRememberPwd = !logInData.isRememberPwd;
        });
    },
  );

  Widget autoLoginCheckBox = new CheckboxListTile(
    title: const Text('自动登录'),
    value: logInData.isAutoLogin,
    onChanged: (bool value) {
        setState(() {
            logInData.isAutoLogin = !logInData.isAutoLogin;
        });
    },
  );
  
  return Scaffold(
      backgroundColor: Colors.white,
      body: new GestureDetector(
        onTap: (){
          print("点击控件外区域");
          focusNodePassword.unfocus();
          focusNodeEmail.unfocus();
        },
        child: new ListView(
          children: <Widget>[
            new SizedBox(height: 300),
            inputTextArea,
            new Row(
              children: <Widget>[
                Expanded(child: rememberCheckBox),
                Expanded(child: autoLoginCheckBox)
                ],
            ),
            loginButtonArea
          ],
        )
        ),
      );
  }

}