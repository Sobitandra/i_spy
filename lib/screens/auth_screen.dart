import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:i_spy/helper/extensions.dart';
import 'package:i_spy/helper/helper.dart';
import 'package:i_spy/services/firebase_service.dart';

import 'home_screen.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseService firebaseService = FirebaseService();

  googleAuthenticate() async {
    OverlayEntry loader = Helpers.overlayLoader(context);
    Overlay.of(context).insert(loader);
    try {
      await GoogleSignIn().signOut();
      await auth.signOut();
      GoogleSignInAccount? googleSignIn = await GoogleSignIn().signIn();

      GoogleSignInAuthentication googleSignInAuthentication = await googleSignIn!.authentication;

      final userCredentials = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken, idToken: googleSignInAuthentication.idToken);
      await auth.signInWithCredential(userCredentials);
      await updateUser();
      Helpers.hideLoader(loader);
    } catch (e) {
      Helpers.hideLoader(loader);
      throw Exception(e);
    } finally {
      Helpers.hideLoader(loader);
    }
  }

  anonymousAuthenticate() async {
    OverlayEntry loader = Helpers.overlayLoader(context);
    Overlay.of(context).insert(loader);
    try {
      await auth.signOut();
      await auth.signInAnonymously();
      await updateUser();
    } catch (e) {
      Helpers.hideLoader(loader);
      throw Exception(e);
    } finally {
      Helpers.hideLoader(loader);
    }
  }

  Future updateUser() async {
    if (auth.currentUser != null) {
      await firebaseService.updateUserInfo().then((value) {
        // User is now logged in and Updated
        Get.offAll(() => const HomeScreen());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Login Screen",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body: SizedBox(
        width: context.getSize.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: googleAuthenticate, child: const Text("Continue with Google")),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(onPressed: anonymousAuthenticate, child: const Text("Continue Anonymously")),
          ],
        ),
      ),
    );
  }
}
