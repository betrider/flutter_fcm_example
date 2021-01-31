import 'dart:async';

import 'package:flutter/material.dart';

import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('FCM'),
        ),
        body: MyHomePage(),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            sendAndRetrieveMessage();
          },
          child: Icon(Icons.send),
          backgroundColor: Colors.pink,
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> sendAndRetrieveMessage() async{
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
    var serverToken = 'AAAAPQqdszs:APA91bF3mtlbMoedwJBOX5jA9-_jhzTx0LwoR-azWE1wZcU7m6Ecn-PU2E91N0Xq_R1O23wrpS6VA4oi4XQBDwse8cdEKdiKRy-dWha_Y2_UVhVqopFVY9iEqYhxHq_m_7QX-znFT6pz';
    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': 'this is a body',
            'title': 'this is a title'
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done'
          },
          // 'to': await firebaseMessaging.getToken(),
          'to': 'f0nbQHEWQmaMLxgjhgn-BJ:APA91bE0cC0QLsLxme6ich6Jb8DAY5pxiV_3RJ7n3zhobvnGDNpCkNKVusB6WgO8YeIKgKPhyxNCqdR6NzbUycozPUahciQPvjxgreM5OoCbLAWOu1FzoTGD7sICuCYe55LpEXlGvu4D',
        },
      ),
    );

    final Completer<Map<String, dynamic>> completer =
    Completer<Map<String, dynamic>>();

    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        completer.complete(message);
      },
    );

    return completer.future;
  }
}

class MyHomePage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _MyHomePage();
  }
}

class _MyHomePage extends State<MyHomePage> {

  String token = '';
  String test = 'Test';

  @override
  void initState() {
    super.initState();
    firebaseCloudMessaging_Listeners();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FutureBuilder(
            future: _firebaseMessaging.getToken(),
            builder: (context, snapshot){
              token = snapshot.data;
              return SelectableText(
                'token : $token',
              );
            },
          ),
          SizedBox(
            height: 50,
          ),
          Text(
            'message : $test',
          ),
        ],
      ),
    );
  }

  void firebaseCloudMessaging_Listeners() {
    if (Platform.isIOS) iOS_Permission();

    _firebaseMessaging.getToken().then((token){
      print('token:'+token);
    });

    _firebaseMessaging.configure(
      //포그라운드
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
        setState(() {
          test  = 'on message';
        });
      },
      //백그라운드
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
        setState(() {
          test  = 'on resume';
        });
      },
      //꺼진경우
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
        setState(() {
          test  = 'on launch';
        });
      },
    );
  }

  void iOS_Permission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true)
    );
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings)
    {
      print("Settings registered: $settings");
    });
  }
}