import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:cydrive/globals.dart';
import 'package:cydrive/main.dart';
import 'package:cydrive/utils.dart';
import 'package:cydrive_sdk/models/account.pb.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class LogInData{
  Account account;
  bool isShowPwd,isShowClear,isRememberPwd,isAutoLogin,isLoadJson;

  LogInData({String email='', String password=''}){
    this.account = Account(email: email, password: password);
    this.isShowPwd = this.isShowClear = this.isRememberPwd = this.isAutoLogin = this.isLoadJson = false;
  }

  LogInData.fromjson(Map<String, dynamic> json)
      : account = Account(email: json['email'],password: json['password']),
        isRememberPwd = json['isRememberPwd'],
        isAutoLogin = json['isAutoLogin'],
        isLoadJson = false,
        isShowPwd = false, isShowClear = false;

   Map<String, dynamic> toJson() => {
        'email': account.email,
        'password': isRememberPwd? account.password: '',
        'isRememberPwd': isRememberPwd,
        'isAutoLogin': isAutoLogin
      };

  Account getHashAccount(){
    return Account(
      email: this.account.email, 
      password: passwordHash(this.account.password)
    );
  }
}


class LogInPage extends StatefulWidget {
  final Future pathReady = Future.wait([getApplicationSupportDirectory().then((value) {
        filesDirPath = value.path;
      }),
    getTemporaryDirectory().then((value) {
        filesCachePath = value.path + '/file_picker';
      })]);

  // title is the current dir path
  // empty title => root path
  // and in the case display CyDrive
  LogInPage({Key key, this.title}) : super(key: key) ;

  final String title;

  @override
  LogInPageState createState() => LogInPageState();
}

class LogInPageState extends State<LogInPage> {

  LogInData logInData = LogInData(email: '', password: '');
  FocusNode focusNodeEmail = new FocusNode();
  FocusNode focusNodePassword = new FocusNode();

  GlobalKey<FormState> logFormState = GlobalKey<FormState>();

  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

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

  Future<Null> loadLogInData()async{
    await widget.pathReady;
    
    //comfirm dir exist or create dir
    print('$filesCachePath' + "/account.json");
    Directory dir = Directory(filesCachePath);
    if (!await dir.exists())
      await dir.create();
    
    //confim data file exist or create json file
    File file = File('$filesCachePath' + "/account.json");
    if (!await file.exists())
      await file.create();  

    //json decode
    var jsonMap = json.decode(await file.readAsString());
    print(jsonMap);
    logInData=LogInData.fromjson(jsonMap);
  }

  Future<Null> saveLogInData()async{
    await widget.pathReady;
    File file = File('$filesCachePath' + "/account.json");
    file.writeAsString(json.encode(logInData));    
  }

  void logIn(){
    print("登录成功");
    setState(() {
      if (!logInData.isLoadJson)
        passwordController.text=passwordHash(logInData.account.password);
      if (!logInData.isRememberPwd)
        passwordController.text='';
      print(logInData.account.password);
      logInData.isShowPwd=false;
      logInData.isLoadJson=logInData.isRememberPwd;
    });
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (context)=>MyHomePage(
        key: widget.key,
        title: '',
      )));
  }

  @override
  void initState(){
    print("init LoginPageState");
    loadLogInData().then((_){
      setState(() {
        if (logInData.isAutoLogin)
          client.login(account: logInData.account).then((ok){
                if(ok)logIn();else{
                  print("自动登录失败");
                }
          });
        logInData.isLoadJson = logInData.isRememberPwd;
        passwordController.text = logInData.account.password;
        emailController.text = logInData.account.email;
      });
    });

    focusNodeEmail.addListener(focusNodeListrener);
    focusNodePassword.addListener(focusNodeListrener);
    emailController.addListener(() {
      if(emailController.text.length > 0){
        logInData.isShowClear = true;
      }else{
        logInData.isShowClear = false;
      }
      setState(() {
      });
    });

    passwordController.addListener(() { 
      if(logInData.isLoadJson&&passwordController.text.length==0){
        logInData.isLoadJson=false;
        setState(() {
        });
      }
    });
    print(logInData.isLoadJson);
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
    print("buildWidget");
    Widget emailTextFiled = TextFormField(
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
    print( logInData.isLoadJson);
    Widget passwordTextFiled = TextFormField(
              controller: passwordController,
              focusNode: focusNodePassword,
              decoration: InputDecoration(
                labelText: "password",
                hintText: "请输入密码",
                prefixIcon: Icon(Icons.lock),
                suffixIcon: logInData.isLoadJson?
                  IconButton(
                    onPressed: (){
                      passwordController.clear();
                      setState(() {
                        logInData.isLoadJson=false;
                      });
                    },
                    icon: Icon(Icons.clear)
                  ):
                  IconButton(
                    icon: Icon((logInData.isShowPwd)?Icons.visibility : Icons.visibility_off),
                    onPressed: (){
                      setState(() {
                        logInData.isShowPwd = !logInData.isShowPwd;
                      });
                  }) 
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
          focusNodePassword.unfocus();
          focusNodeEmail.unfocus();

          if (logFormState.currentState.validate()) {
            logFormState.currentState.save();
            print('${logInData.account}');
            client.login(account: logInData.isLoadJson? logInData.account:logInData.getHashAccount()).then((ok){
              if(ok){
                  logIn();
                  saveLogInData().then((ok){print("保存成功");if (!ok) print("data Cache error");});
              } else{
                print("登录失败");
              }
            });
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
      body: GestureDetector(
        onTap: (){
          print("点击控件外区域");
          focusNodePassword.unfocus();
          focusNodeEmail.unfocus();
        },
        child: ListView(
          children: <Widget>[
            SizedBox(height: 300),
            inputTextArea,
            Row(
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