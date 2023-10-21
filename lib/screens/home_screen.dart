import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_spy/services/firebase_service.dart';

import '../models/model_users_list.dart';
import 'game_connect/connnect_users.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService firebaseService = FirebaseService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome",style: TextStyle(
            fontWeight: FontWeight.w500
        ),),
        centerTitle: true,
        actions: [
          IconButton(onPressed: (){
            firebaseService.signOutUser();
          }, icon: const Icon(Icons.logout))
        ],
      ),
      body: StreamBuilder(
        stream: firebaseService.getAllUsers(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if(snapshot.hasData && snapshot.data != null){
            // log(snapshot.data!.docs.map((e) => jsonEncode(e.data())).toList().toString());
            List<ModelUsersInfo> users = snapshot.data!.docs.map((e) => ModelUsersInfo.fromJson(e.data())).toList();
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (c,i){
                final item = users[i];
                return ListTile(
                  onTap: (){
                    Get.to(()=> ConnectUsersScreen(userInfo: item,));
                  },
                  title: Hero(
                    tag: item.userName.toString(),
                    child: Material(
                      color: Colors.transparent,
                      child: Text(item.userName.toString(),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w500,
                      fontSize: 16),
                      maxLines: 1,),
                    ),
                  ),
                  trailing: Icon(Icons.adaptive.arrow_forward_rounded),
                  leading: Container(
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle
                    ),
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    child: Text(item.userName.toString().substring(0,1),style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600
                    ),),
                  ),
                );
              },);
          }
          return const Center(child: CircularProgressIndicator.adaptive(),);
        },
      ),
    );
  }
}
