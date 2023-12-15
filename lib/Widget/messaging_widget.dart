import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_webapp/Model/chart.dart';
import 'package:whatsapp_webapp/Model/message.dart';
import 'package:whatsapp_webapp/ProviderChat/provider_chat.dart';
import 'package:whatsapp_webapp/res/AppColors/app_colors.dart';
import '../Model/user_model.dart';
import 'package:http/http.dart' as http;

class MessagingWidget extends StatefulWidget {
  final UserModel fromUserData;
  final UserModel toUserData;
  const MessagingWidget(
      {super.key, required this.fromUserData, required this.toUserData});

  @override
  State<MessagingWidget> createState() => _MessagingWidgetState();
}

class _MessagingWidgetState extends State<MessagingWidget> {
  var controller = TextEditingController();
  late StreamSubscription _streamSubscriptionMessages;
  final streamController = StreamController<QuerySnapshot>.broadcast();
  final scrollControllerMessages = ScrollController();
  String? fileTypeChoosed;
  bool _loadingPic = false;
  bool _loadingFile = false;
  Uint8List? _selectedImage;
  Uint8List? _selectedFile;
  String? _token;

  sendPushNotificationOnWeb(String messageText, String fromUserName) async {
    if (_token == null) {
      var snackBar = const SnackBar(
        content: Text("no token exists,unable to send pushNotification"),
        backgroundColor: AppColor.primaryColor,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    try{
     await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
     headers: <String,String>{
       "Content-Type": 'application/json',
       'Authorization': 'key=AAAAych7Nao:APA91bHclfdr70UGkphHnwYfV3xoS2cAI9A9_4S9vdRs1a6SdQt5pSuMChOQ5ZMnGg0oF50LIYpPaNmbZau-Pg-LrOpDdf3NQt6o_gw5RZbl9mDo7JbAEhXPaMHu2dDQ1qm_Zd21UYC7'

     },
     body: json.encode({
       'to':_token,
       'message':{
         'token' : _token,
       },
       'notification':{
         'title':fromUserName,
         'body':messageText,
       }
     }),
     );
    }catch(e){
      var snackBar = SnackBar(
        content: Text(e.toString()),
        backgroundColor: AppColor.primaryColor,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  sendMessage() {
    String messageData = controller.text.trim();
    if (messageData.isNotEmpty) {
      String fromUserID = widget.fromUserData.uid;
      final message = Message(
        fromUserID,
        messageData,
        Timestamp.now().toString(),
      );
      String toUserID = widget.toUserData.uid;
      String messageID = DateTime.now().millisecondsSinceEpoch.toString();

      //save message for sender
      saveMessageToDatabase(fromUserID, toUserID, message, messageID);
      //save recent chat[sender]
      final chatFromData = Chat(
        fromUserID,
        toUserID,
        message.text.trim(),
        widget.toUserData.name,
        widget.toUserData.email,
        widget.toUserData.image,
      );
      saveRecentChatToDatabase(chatFromData, messageData);

      //save message for receiver
      saveMessageToDatabase(toUserID, fromUserID, message, messageID);
      //save recent chat[receiver]
      final chatToData = Chat(
        toUserID,
        fromUserID,
        message.text.trim(),
        widget.fromUserData.name,
        widget.fromUserData.email,
        widget.fromUserData.image,
      );
      saveRecentChatToDatabase(chatFromData, messageData);
    }
  }

  saveMessageToDatabase(fromUserID, toUserID, message, messageID) {
    FirebaseFirestore.instance
        .collection("Messages")
        .doc(fromUserID)
        .collection(toUserID)
        .doc(messageID)
        .set(message.toMap());
    controller.clear();
  }

  saveRecentChatToDatabase(Chat chat, messageData) {
    FirebaseFirestore.instance
        .collection("Chats")
        .doc(chat.fromUserId)
        .collection('LastMessage')
        .doc(chat.toUserId)
        .set(chat.toMap())
        .then((value) async {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(chat.toUserId)
          .get()
          .then((snapshot) {
        setState(() {
          _token = snapshot.data()!['token'];
        });
      });
      //send  notification
      sendPushNotificationOnWeb(messageData,widget.fromUserData.name);
    });
    controller.clear();
  }

  createMessageListener({UserModel? toUserData}) {
    // live refresh message page directly from the firebase
    final streamMessage = FirebaseFirestore.instance
        .collection('Messages')
        .doc(widget.fromUserData.uid)
        .collection(toUserData?.uid ?? widget.toUserData.uid)
        .orderBy('dateTime', descending: false)
        .snapshots();
    //scroll at the end o message list
    _streamSubscriptionMessages = streamMessage.listen((data) {
      streamController.add(data);
      Timer(const Duration(seconds: 1), () {
        scrollControllerMessages
            .jumpTo(scrollControllerMessages.position.maxScrollExtent);
      });
    });
  }

  updateMessageListener() {
    UserModel? toUserData = context.watch<ProviderChat>().toUserData;
    if (toUserData != null) {
      createMessageListener(toUserData: toUserData);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // to update the message listener through providers
    updateMessageListener();
  }

  @override
  void dispose() {
    _streamSubscriptionMessages.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    createMessageListener();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            "images/background.png",
          ),
          fit: BoxFit.fill,
        ),
      ),
      child: Column(
        children: [
          // display messages here
          StreamBuilder(
              stream: streamController.stream,
              builder: (context, dataSnapshot) {
                switch (dataSnapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return const Expanded(
                      child: Center(
                        child: Column(
                          children: [
                            Text("Loading..."),
                            CircularProgressIndicator(),
                          ],
                        ),
                      ),
                    );
                  case ConnectionState.active:
                  case ConnectionState.done:
                    if (dataSnapshot.hasError) {
                      const Center(
                        child: Text('Error Occurred'),
                      );
                    } else {
                      final snapshot = dataSnapshot.data as QuerySnapshot;
                      List<DocumentSnapshot> messagesList =
                          snapshot.docs.toList();
                      return Expanded(
                        child: ListView.builder(
                            controller: scrollControllerMessages,
                            itemCount: snapshot.docs.length,
                            itemBuilder: (context, index) {
                              DocumentSnapshot eachMessage =
                                  messagesList[index];
                              //aligns messages balloons from sender and receivers
                              Alignment alignment = Alignment.bottomLeft;
                              Color color = Colors.white;
                              if (widget.fromUserData.uid ==
                                  eachMessage['uid']) {
                                alignment = Alignment.bottomRight;
                                color = const Color(0xffd2ffa5);
                              }
                              Size width = MediaQuery.of(context).size * 0.8;

                              return GestureDetector(
                                onLongPress: () async {
                                  if (eachMessage['uid'] ==
                                      FirebaseAuth.instance.currentUser!.uid) {
                                    await showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text("Delete Message ?"),
                                        content: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () async {
                                                Navigator.of(context).pop();
                                                await deleteForMe(
                                                  eachMessage.id,
                                                  FirebaseAuth.instance
                                                      .currentUser!.uid,
                                                  widget.toUserData.uid,
                                                  eachMessage['text']
                                                      .toString(),
                                                );
                                                await deleteForEveryone(
                                                  eachMessage.id,
                                                  FirebaseAuth.instance
                                                      .currentUser!.uid,
                                                  widget.toUserData.uid,
                                                  eachMessage['text']
                                                      .toString(),
                                                );
                                              },
                                              child: const Text(
                                                "Delete for Everyone",
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            ElevatedButton(
                                              onPressed: () async {
                                                Navigator.of(context).pop();
                                                await deleteForMe(
                                                  eachMessage.id,
                                                  FirebaseAuth.instance
                                                      .currentUser!.uid,
                                                  widget.toUserData.uid,
                                                  eachMessage['text']
                                                      .toString(),
                                                );
                                              },
                                              child: const Text(
                                                "Delete for me",
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text(
                                                "cancel",
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: eachMessage['text']
                                        .toString()
                                        .contains(".jpg")
                                    ? Align(
                                        alignment: alignment,
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          margin: const EdgeInsets.all(8),
                                          constraints:
                                              BoxConstraints.loose(width),
                                          decoration: BoxDecoration(
                                            color: color,
                                            borderRadius:
                                                const BorderRadius.all(
                                              Radius.circular(9),
                                            ),
                                          ),
                                          child: Image.network(
                                            eachMessage['text'],
                                            width: 200,
                                            height: 200,
                                          ),
                                        ),
                                      )
                                    : eachMessage['text']
                                                .toString()
                                                .contains(".pdf") ||
                                            eachMessage['text']
                                                .toString()
                                                .contains(".mp4'") ||
                                            eachMessage['text']
                                                .toString()
                                                .contains(".mp3") ||
                                            eachMessage['text']
                                                .toString()
                                                .contains(".docx") ||
                                            eachMessage['text']
                                                .toString()
                                                .contains(".pptx") ||
                                            eachMessage['text']
                                                .toString()
                                                .contains(".xlsx")
                                        ? Align(
                                            alignment: alignment,
                                            child: Container(
                                              padding: const EdgeInsets.all(16),
                                              margin: const EdgeInsets.all(8),
                                              constraints:
                                                  BoxConstraints.loose(width),
                                              decoration: BoxDecoration(
                                                color: color,
                                                borderRadius:
                                                    const BorderRadius.all(
                                                  Radius.circular(9),
                                                ),
                                              ),
                                              child: GestureDetector(
                                                onTap: () {},
                                                child: Image.asset(
                                                  "images/file.png",
                                                  height: 200,
                                                  width: 200,
                                                ),
                                              ),
                                            ),
                                          )
                                        : Align(
                                            alignment: alignment,
                                            child: Container(
                                              padding: const EdgeInsets.all(16),
                                              margin: const EdgeInsets.all(8),
                                              constraints:
                                                  BoxConstraints.loose(width),
                                              decoration: BoxDecoration(
                                                color: color,
                                                borderRadius:
                                                    const BorderRadius.all(
                                                  Radius.circular(9),
                                                ),
                                              ),
                                              child: Text(eachMessage['text']),
                                            ),
                                          ),
                              );
                            }),
                      );
                    }
                }
                return const Text("data");
              }),
          // text-field to send messages
          Container(
            padding: const EdgeInsets.all(8),
            color: AppColor.barBackgroundColor,
            child: Row(
              children: [
                //text-field with  icons
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.insert_emoticon,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: TextField(
                            controller: controller,
                            decoration: const InputDecoration(
                              hintText: "Enter Your Message",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        _loadingFile == false
                            ? IconButton(
                                onPressed: () {
                                  dialogBoxForSelectingFile();
                                },
                                icon: const Icon(Icons.attach_file),
                              )
                            : const Center(
                                child: CircularProgressIndicator(
                                  color: AppColor.primaryColor,
                                ),
                              ),
                        _loadingPic == false
                            ? IconButton(
                                onPressed: () {
                                  selectImage();
                                },
                                icon: const Icon(Icons.camera_alt),
                              )
                            : const Center(
                                child: CircularProgressIndicator(
                                  color: AppColor.primaryColor,
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
                FloatingActionButton(
                  mini: true,
                  backgroundColor: AppColor.primaryColor,
                  onPressed: () {
                    sendMessage();
                  },
                  child: const Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  dialogBoxForSelectingFile() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text("Send File"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Please choose the file type from the following"),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DropdownButton<String>(
                      hint: const Text("Choose Here"),
                      value: fileTypeChoosed,
                      underline: Container(),
                      items: <String>[
                        ".pdf",
                        '.mp4',
                        '.mp3',
                        '.docx',
                        '.pptx',
                        '.xlsx',
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ));
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          fileTypeChoosed = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    //select file
                    if (fileTypeChoosed != null) {
                      selectFile(fileTypeChoosed);
                      Navigator.of(context).pop();
                    } else {
                      var snackBar = const SnackBar(
                        content: Text("First select Filetype"),
                        backgroundColor: AppColor.primaryColor,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  },
                  child: const Text("Select File"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  selectFile(fileTypeChoosed) async {
    FilePickerResult? pickerResult =
        await FilePicker.platform.pickFiles(type: FileType.any);
    setState(() {
      _selectedFile = pickerResult!.files.single.bytes;
    });
    uploadFile(_selectedFile);
  }

  uploadFile(selectedFile) {
    setState(() {
      _loadingFile = true;
    });
    if (_selectedFile != null) {
      Reference fileRef = FirebaseStorage.instance.ref(
          "files/${DateTime.now().millisecondsSinceEpoch.toString()}.$fileTypeChoosed");
      UploadTask uploadTask = fileRef.putData(selectedFile);
      uploadTask.whenComplete(() async {
        String linkFile = await uploadTask.snapshot.ref.getDownloadURL();
        setState(() {
          controller.text = linkFile;
        });
        sendMessage();
        setState(() {
          _loadingFile = false;
        });
      });
    }
  }

  selectImage() async {
    FilePickerResult? pickerResult =
        await FilePicker.platform.pickFiles(type: FileType.image);
    setState(() {
      _selectedImage = pickerResult!.files.single.bytes;
    });
    uploadImage(_selectedImage);
  }

  uploadImage(selectedImage) {
    setState(() {
      _loadingPic = true;
    });
    if (_selectedImage != null) {
      Reference fileRef = FirebaseStorage.instance.ref(
          "Images/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg");
      UploadTask uploadTask = fileRef.putData(selectedImage);
      uploadTask.whenComplete(() async {
        String linkFile = await uploadTask.snapshot.ref.getDownloadURL();
        setState(() {
          controller.text = linkFile;
        });
        sendMessage();
        setState(() {
          _loadingPic = false;
        });
      });
    }
  }

  deleteForMe(messageID, myId, toUserID, messageTextToUpdate) async {
    await FirebaseFirestore.instance
        .collection('Messages')
        .doc(myId)
        .collection(toUserID)
        .doc(messageID)
        .update({
      'text': "🛇 you delete this message",
    });
  }

  deleteForEveryone(messageID, myId, toUserID, messageTextToUpdate) async {
    await FirebaseFirestore.instance
        .collection('Messages')
        .doc(toUserID)
        .collection(myId)
        .doc(messageID)
        .update({
      'text': "🛇 message deleted",
    });
  }
}
