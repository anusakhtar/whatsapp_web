import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_webapp/ChatMessageArea/ChatArea/contact_list.dart';
import 'package:whatsapp_webapp/res/AppColors/app_colors.dart';

import '../../Model/user_model.dart';
import 'recent_chat.dart';

class ChatArea extends StatelessWidget {
  final UserModel currentUserData;
  const ChatArea({super.key, required this.currentUserData});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColor.lightBarBackgroundColor,
          border: Border(
            right: BorderSide(width: 1, color: AppColor.backgroundColor),
          ),
        ),
        child: Column(
          children: [
            // header
            Container(
              color: AppColor.backgroundColor,
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.grey,
                    backgroundImage: NetworkImage(currentUserData.image),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    currentUserData.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      FirebaseAuth.instance.signOut().then((value) {
                        Navigator.of(context).pushReplacementNamed("/login");
                        var snackBar = const SnackBar(
                          content: Text('SignOut Successfully'),
                          backgroundColor: AppColor.primaryColor,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      });
                    },
                    icon: const Icon(Icons.login_outlined),
                  ),
                ],
              ),
            ),
            // 2 tab buttons
            const TabBar(
                unselectedLabelColor: Colors.grey,
                labelColor: Colors.black,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                indicatorColor: AppColor.primaryColor,
                indicatorWeight: 2,
                indicatorSize: TabBarIndicatorSize.tab,

                tabs: [
                  Tab(
                    text: "Chat",
                  ),
                  Tab(
                    text: "Contacts",
                  ),
                ]),
            Expanded(
              child: Container(
                color: Colors.white,
                child: const TabBarView(
                  children: [
                    //recent chat
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: RecentChat(),
                    ),
                    //contacts
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: ContactList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
