import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_spy/helper/extensions.dart';
import 'package:i_spy/helper/helper.dart';

import '../../services/firebase_service.dart';

class DisplayImageScreen extends StatefulWidget {
  const DisplayImageScreen({super.key, required this.file, required this.textLetter, required this.gameId});

  final File file;
  final String gameId;
  final Function(String letter, String url) textLetter;

  @override
  State<DisplayImageScreen> createState() => _DisplayImageScreenState();
}

class _DisplayImageScreenState extends State<DisplayImageScreen> {
  final TextEditingController controller = TextEditingController();
  RxString letter = "".obs;
  final FirebaseService firebaseService = FirebaseService();

  // -1 Represent no uploading progress
  RxDouble uploadingProgress = (-1.0).obs;

  uploadImage() async {
    try {
      // -2 Represent uploading Start
      uploadingProgress.value = -2;
      await firebaseService.uploadGameImage(gameId: widget.gameId, file: widget.file, progress: (double value) {
        // progress call back Function to display uploading progress
        uploadingProgress.value = value;
      }).then((value) {
        widget.textLetter(controller.text, value);
      });
    } catch (e) {
      uploadingProgress.value = -1;
      throw Exception();
    } finally {
      uploadingProgress.value = -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 25,),
        SizedBox(
          width: context.getSize.width,
          height: context.getSize.width * .6,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Image.file(widget.file,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      Image.network(widget.file.path,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(Icons.error_outline_rounded),
                      ),
                ),
              ),
              Positioned.fill(child: Obx(() {
                if(uploadingProgress.value > 0){}
                return uploadingProgress.value != -1 ?
                Center(

                  child: SizedBox(
                    width: 120,
                    height: 100,
                    child: Card(
                      color: Colors.white,
                      surfaceTintColor: Colors.white,

                      // check this to show user that uploading will start soon.
                      child: uploadingProgress.value != -2?
                      TweenAnimationBuilder(
                        tween: Tween<double>(
                            begin: 0,
                            end: uploadingProgress.value
                        ), duration: const Duration(milliseconds: 500),
                        builder: (BuildContext context, double value, Widget? child) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: value,
                                  color: Colors.purple,
                                  strokeCap: StrokeCap.round,
                                ),
                                const Flexible(child: Text("Uploading Please wait...",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500
                                ),))
                              ],
                            ),
                          );
                        },
                      ) : const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: Colors.purple,
                              strokeCap: StrokeCap.round,
                            ),
                            Flexible(child: Text("Uploading Please wait...",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),))
                          ],
                        ),
                      ),
                    ),
                  ),
                ) : const SizedBox.shrink();
              }))
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(() {
            return Text(
              "I spy with my little eye a thing starting with the letter ${letter.value.isEmpty ? "_" : letter.value}",
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500
              ),);
          }),
        ),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: TextFormField(
                  controller: controller,
                  onChanged: (value) {
                    letter.value = value;
                  },
                  decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabled: true,
                      hintText: "Enter Message....",
                      contentPadding: const EdgeInsets.all(12)
                  ),
                ),
              ),
            ),
            IconButton(onPressed: () {
              if (letter.value.isEmpty) {
                showToast("Please enter letter");
                return;
              }
              uploadImage();
            }, icon: const Icon(Icons.send_rounded, color: Colors.purple,)),
          ],
        )
      ],
    );
  }
}
