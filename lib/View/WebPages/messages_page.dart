import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_webapp/Model/user_model.dart';
import 'package:whatsapp_webapp/Widget/messaging_widget.dart';
import 'package:whatsapp_webapp/res/AppColors/app_colors.dart';

class MessagesPage extends StatefulWidget {
  final UserModel toUserData;
  MessagesPage( this.toUserData,{Key? key}):super(key: key);

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  late UserModel toUser;
  late UserModel fromUser;

  getUserData() {
    toUser = widget.toUserData;
    User? loggedInUser = FirebaseAuth.instance.currentUser;
    if (loggedInUser != null) {
      fromUser = UserModel(
        loggedInUser.uid,
        loggedInUser.displayName ?? "",
        loggedInUser.email ?? "",
        '',
        image: loggedInUser.photoURL ?? "",
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColor.primaryColor,
        centerTitle: true,
        title: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: Colors.grey,
              backgroundImage: NetworkImage(
                toUser.image.toString(),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              toUser.name.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                // fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: const [
          Icon(Icons.more_vert,color: Colors.white,),
        ],
      ),
      body: SafeArea(
        child: MessagingWidget(
          fromUserData: fromUser,
          toUserData: toUser,

        ),
      ),
    );
  }
}
