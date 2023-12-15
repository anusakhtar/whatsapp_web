import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_webapp/ProviderChat/provider_chat.dart';
import 'package:whatsapp_webapp/res/AppColors/app_colors.dart';

import '../../Model/user_model.dart';

class RecentChat extends StatefulWidget {
  const RecentChat({super.key});

  @override
  State<RecentChat> createState() => _RecentChatState();
}

class _RecentChatState extends State<RecentChat> {
  late UserModel fromUserData;
  final streamController = StreamController<QuerySnapshot>.broadcast();
  late StreamSubscription streamSubscriptionChats;

  chatListener() {
    final streamRecentChats = FirebaseFirestore.instance
        .collection("Chats")
        .doc(fromUserData.uid)
        .collection('LastMessage')
        .snapshots();
    streamSubscriptionChats = streamRecentChats.listen((newMessageData) {
      streamController.add(newMessageData);
    });
  }

  loadInitialData() {
    User? currentFirebaseUser = FirebaseAuth.instance.currentUser;
    if (currentFirebaseUser != null) {
      String userID = currentFirebaseUser.uid;
      String? name = currentFirebaseUser.displayName ?? "";
      String? email = currentFirebaseUser.email ?? "";
      String? password = '';
      String? profilePhoto = currentFirebaseUser.photoURL ?? "";
      fromUserData =
          UserModel(userID, name, email, password, image: profilePhoto);
    }
    chatListener();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadInitialData();
  }

  @override
  void dispose() {
    streamSubscriptionChats.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: streamController.stream,
        builder: (context, dataSnapshot) {
          switch (dataSnapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Center(
                  child: Column(
                children: [
                  Text('Loading'),
                  SizedBox(height: 4),
                  CircularProgressIndicator(color: AppColor.primaryColor),
                ],
              ));
            case ConnectionState.done:
            case ConnectionState.active:
              if (dataSnapshot.hasError) {
                return const Center(child: Text("Something Wrong"));
              } else {
                QuerySnapshot snapshotData = dataSnapshot.data as QuerySnapshot;
                List<DocumentSnapshot> recentChats = snapshotData.docs.toList();
                return ListView.separated(
                  itemCount: recentChats.length,
                  separatorBuilder: (context, index) {
                    return const Divider(
                      color: Colors.grey,
                      thickness: 0.4,
                    );
                  },
                  itemBuilder: (context, index) {
                    DocumentSnapshot chat = recentChats[index];
                    String toUserImage = chat['toUserImage'];
                    String toUserName = chat['toUserName'];
                    String toUserEmail = chat['toUserEmail'];
                    String lastMessage = chat['LastMessage'];
                    String toUserID = chat['toUserId'];

                    final toUserData = UserModel(
                        toUserID, toUserName, toUserEmail, '',
                        image: toUserImage);
                    return ListTile(
                      onTap: () {
                        context.read<ProviderChat>().toUserData = toUserData;
                      },
                      leading: CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.grey,
                        backgroundImage: NetworkImage(toUserData.image),
                      ),
                      title: Text(toUserData.name),
                      subtitle: Text(
                        lastMessage.toString().contains(".jpg")
                            ? "send you an Image"
                            : lastMessage.toString().contains(".pdf") ||
                                    lastMessage.toString().contains(".mp4'") ||
                                    lastMessage.toString().contains(".mp3") ||
                                    lastMessage.toString().contains(".docx") ||
                                    lastMessage.toString().contains(".pptx") ||
                                    lastMessage.toString().contains(".xlsx")
                                ? "send you an File"
                                : lastMessage.toString(),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      contentPadding: const EdgeInsets.all(9),
                    );
                  },
                );
              }
          }
        });
  }
}
