import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_webapp/ProviderChat/provider_chat.dart';
import 'package:whatsapp_webapp/Widget/messaging_widget.dart';
import 'package:whatsapp_webapp/res/AppColors/app_colors.dart';

import '../Model/user_model.dart';

class MessagingArea extends StatelessWidget {
  final UserModel currentUserData;
  const MessagingArea({super.key, required this.currentUserData});

  @override
  Widget build(BuildContext context) {
    UserModel? toUserData = context.watch<ProviderChat>().toUserData;
    return toUserData == null
        ? Container(
            width: MediaQuery.sizeOf(context).width,
            color: Colors.white,
            child: Center(
              child: Image.asset('images/whatsapp.png'),
            ),
          )
        : Column(children: [
            //header
            Container(
              padding: const EdgeInsets.all(8),
              color: AppColor.backgroundColor,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.grey,
                    backgroundImage: NetworkImage(toUserData.image.toString()),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    toUserData.name.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.search),
                  const Icon(Icons.more_vert),
                ],
              ),
            ),
            //Messages List
            Expanded(
              child: MessagingWidget(
                fromUserData: currentUserData,
                toUserData: toUserData,
              ),
            ),
          ]);
  }
}
