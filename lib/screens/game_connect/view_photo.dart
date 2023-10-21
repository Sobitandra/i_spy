import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ViewPhoto extends StatefulWidget {
  const ViewPhoto({super.key, required this.urlImage});
  final String urlImage;

  @override
  State<ViewPhoto> createState() => _ViewPhotoState();
}

class _ViewPhotoState extends State<ViewPhoto> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PhotoView(
        imageProvider: NetworkImage(widget.urlImage),
        wantKeepAlive: true,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ElevatedButton(
            onPressed: (){},
            style: ElevatedButton.styleFrom(
              shape: const StadiumBorder()
            ),
            child: const Text("Reply"),
          ),
        ),
      ),
    );
  }
}
