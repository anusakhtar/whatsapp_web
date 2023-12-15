import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_webapp/Model/user_model.dart';

class ContactList extends StatefulWidget {
  const ContactList({super.key});

  @override
  State<ContactList> createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  String CurrentUserId = "";
  getCurrentFirebaseUser() {
    User? currentFirebaseUser = FirebaseAuth.instance.currentUser;
    if (currentFirebaseUser != null) {
      CurrentUserId = currentFirebaseUser.uid;
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentFirebaseUser();
  }

  Future<List<UserModel>> readContactList() async {
    final userRef = FirebaseFirestore.instance.collection("Users");
    QuerySnapshot allUserRecord = await userRef.get();
    List<UserModel> allUserList = [];
    for (DocumentSnapshot userRecord in allUserRecord.docs) {
      String uid = userRecord['uid'];
      if (uid == CurrentUserId) {
        continue;
      }
      String name = userRecord['name'];
      String email = userRecord['email'];
      String password = userRecord['password'];
      String image = userRecord['image'];

      UserModel userData = UserModel(uid, name, email, password, image: image);
      allUserList.add(userData);
    }
    return allUserList;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: readContactList(),
        builder: (context, dataSnapshot) {
          switch (dataSnapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Padding(
                padding: EdgeInsets.all(18.0),
                child: Center(
                  child: Column(
                    children: [
                      Text('Loading...'),
                      SizedBox(
                        height: 10,
                      ),
                      CircularProgressIndicator(),
                    ],
                  ),
                ),
              );
            case ConnectionState.active:
            case ConnectionState.done:
              if (dataSnapshot.hasError) {
                return const Center(
                  child: Text("Error in Loading the contacts"),
                );
              } else {
                List<UserModel>? userContactList = dataSnapshot.data;
                if (userContactList != null) {
                  return ListView.separated(
                    separatorBuilder: (context, index) {
                      return const Divider(
                        thickness: 0.3,
                        color: Colors.grey,
                      );
                    },
                    itemCount: userContactList.length,
                    itemBuilder: (context, index) {
                      UserModel userData = userContactList[index];
                      return ListTile(
                        onTap: () {
                          Future.delayed(Duration.zero, () {
                            Navigator.pushNamed(
                              context,
                              '/messages',
                              arguments: userData,
                            );
                          });
                        },
                        title: Text(
                          userData.name.toString(),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(9),
                        leading: CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.grey,
                          backgroundImage:
                              NetworkImage(userData.image.toString()),
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(
                    child: Text("No Contact Found"),
                  );
                }
              }
          }
        });
  }
}
