import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_webapp/ChatMessageArea/ChatArea/chat_area.dart';
import 'package:whatsapp_webapp/ChatMessageArea/messeging_area.dart';
import 'package:whatsapp_webapp/Widget/notification_dialog_widget.dart';

import '../../Model/user_model.dart';
import '../../res/AppColors/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late UserModel currentUserData;
  String? _token;
  Stream<String>? _tokenStream;
  readCurrentUserData() async {
    User? currentFirebaseUser = FirebaseAuth.instance.currentUser!;
    if (currentFirebaseUser != null) {
      String uid = currentFirebaseUser.uid;
      String name = currentFirebaseUser.displayName ?? "";
      String email = currentFirebaseUser.email ?? "";
      String password = "";
      String image = currentFirebaseUser.photoURL ?? "";

      currentUserData = UserModel(uid, name, email, password, image: image);
    }
    await getPermissionForNotifications();
    await pushNotificationMessageListener();
    await FirebaseMessaging.instance.getToken().then(setTokenNow);
    _tokenStream =FirebaseMessaging.instance.onTokenRefresh;
    _tokenStream!.listen(setTokenNow);
    await saveTokenToUserinfo();
  }

  getPermissionForNotifications() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      sound: true,
      criticalAlert: false,
      provisional: false,
    );
  }

  pushNotificationMessageListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return NotificationDialogWidget(
                titleText: message.notification!.title,
                body: message.notification!.body,
              );
            });
      }
    });
  }

  setTokenNow(String? token){
    setState(() {
      _token = token;
    });

  }
  saveTokenToUserinfo()async{
    await FirebaseFirestore.instance.collection("Users").doc(FirebaseAuth.instance.currentUser!.uid).update({
      "token":_token,
    });
  }

  @override
  void initState() {
    super.initState();
    readCurrentUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColor.lightBarBackgroundColor,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.2,
                color: AppColor.primaryColor,
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.05,
              bottom: MediaQuery.of(context).size.height * 0.05,
              right: MediaQuery.of(context).size.height * 0.05,
              left: MediaQuery.of(context).size.height * 0.05,
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: ChatArea(currentUserData: currentUserData),
                  ),
                  Expanded(
                    flex: 10,
                    child: MessagingArea(currentUserData: currentUserData),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
