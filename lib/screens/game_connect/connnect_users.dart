import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_spy/helper/extensions.dart';
import 'package:i_spy/helper/helper.dart';
import 'package:i_spy/screens/game_connect/display_image.dart';
import 'package:intl/intl.dart';

import '../../models/model_game_chat.dart';
import '../../models/model_users_list.dart';
import '../../services/firebase_service.dart';
import 'view_photo.dart';

class ConnectUsersScreen extends StatefulWidget {
  const ConnectUsersScreen({super.key, required this.userInfo});
  final ModelUsersInfo userInfo;

  @override
  State<ConnectUsersScreen> createState() => _ConnectUsersScreenState();
}

class _ConnectUsersScreenState extends State<ConnectUsersScreen> {
  ModelUsersInfo get userInfo => widget.userInfo;
  final FirebaseService firebaseService = FirebaseService();
  final TextEditingController textEditingController = TextEditingController();

  showDisplayImage(File file) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (c) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: DisplayImageScreen(
              file: file,
              textLetter: (String letter, String url) {
                firebaseService.sendImage(roomId: roomId, image: url, word: letter).then((value) {
                  Get.back();
                });
              },
              gameId: roomId,
            ),
          );
        });
  }

  String get roomId => firebaseService.createUniqueId(otherUserId: userInfo.userID.toString());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Hero(
          tag: userInfo.userName.toString(),
          child: Material(
            color: Colors.transparent,
            child: Text(
              userInfo.userName.toString(),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: firebaseService.connectUser(roomId: roomId),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  log(snapshot.data!.docs.map((e) => jsonEncode(e.data())).toList().toString());
                  List<ModelGameChat> gameChat =
                      snapshot.data!.docs.map((e) => ModelGameChat.fromJson(e.data())).toList();
                  if (gameChat.isEmpty) {
                    return const Center(
                      child: Text("Send image to start game"),
                    );
                  }
                  return ListView.builder(
                      itemCount: gameChat.length,
                      reverse: true,
                      itemBuilder: (c, i) {
                        final item = gameChat[i];
                        bool myMessage = item.senderId.toString() == firebaseService.currentUserID;
                        return chatWidget(myMessage, item, context);
                      });
                }
                return const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              },
            ),
          ),
          SafeArea(
            child: Row(
              children: [
                IconButton(
                    onPressed: () {
                      NewHelper.showImagePickerSheet(
                          gotImage: (File file) {
                            showDisplayImage(file);
                          },
                          context: context);
                    },
                    icon: const Icon(
                      Icons.image_outlined,
                      color: Colors.purple,
                    )),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: TextFormField(
                    controller: textEditingController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        enabled: true,
                        hintText: "Enter Message....",
                        contentPadding: const EdgeInsets.all(12)),
                  ),
                )),
                IconButton(
                    onPressed: () {
                      if (textEditingController.text.isNotEmpty) {
                        firebaseService.sendMessage(roomId: roomId, word: textEditingController.text).then((value) {
                          textEditingController.clear();
                        });
                      }
                    },
                    icon: const Icon(
                      Icons.send_rounded,
                      color: Colors.purple,
                    )),
              ],
            ),
          )
        ],
      ),
    );
  }

  Padding chatWidget(bool myMessage, ModelGameChat item, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 10),
      child: Row(
        mainAxisAlignment: myMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Card(
              color: myMessage ? Colors.white : null,
              surfaceTintColor: myMessage ? Colors.white : null,
              elevation: 3,
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: myMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: myMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
                      children: [
                        if (item.image != null)
                          Flexible(
                              child: Container(
                                  constraints: BoxConstraints(
                                    maxHeight: context.getSize.width * .5,
                                    maxWidth: context.getSize.width * .5,
                                  ),
                                  child: GestureDetector(
                                    onTap: (){
                                      Get.to(()=> ViewPhoto(
                                        urlImage: item.image.toString(),
                                      ));
                                    },
                                      child: CachedNetworkImage(imageUrl: item.image.toString())))),
                      ],
                    ),
                    if (item.type.toString() == "gameImage")
                      Text(
                        "I spy with my little eye a thing starting with the letter ${item.word}",
                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                      )
                    else
                      Text(item.message.toString(),
                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),),
                    Text(
                      DateFormat(" hh:mm a dd-MMM").format(DateTime.fromMillisecondsSinceEpoch(item.time!)),
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
