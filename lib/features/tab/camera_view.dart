import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:uwu_chat/constants/theme_constants.dart';

class CameraView extends StatelessWidget {
  const CameraView({Key? key, required this.path, required this.onImageSend}) : super(key: key);
  final String path;
  final Function onImageSend;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: Theme.of(context).primaryIconTheme,
        backgroundColor: Colors.black,
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.crop_rotate, size: 27, color: Colors.white,)),
          IconButton(onPressed: () {}, icon: Icon(Icons.emoji_emotions_outlined, size: 27, color: Colors.white,)),
          IconButton(onPressed: () {}, icon: Icon(Icons.title, size: 27, color: Colors.white,)),
          IconButton(onPressed: () {}, icon: Icon(Icons.edit, size: 27, color: Colors.white,))
        ],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height-150,
              child: Image.file(
                File(path),
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                color: Colors.black38,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                child: TextFormField(
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    decoration: TextDecoration.none,
                  ),
                  maxLines: 6,
                  minLines: 1,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Add Caption....",
                      prefixIcon: Icon(Icons.add_photo_alternate, color: Colors.white, size: 27,),
                      hintStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                      ),
                      suffixIcon: InkWell(
                        onTap: () {
                          onImageSend(path);
                          Navigator.pop(context);
                        },
                        child: CircleAvatar(
                          radius: 27,
                          backgroundColor: AppColors.secondary,
                          child: Icon(Icons.check, color: Colors.white, size: 27,),
                        ),
                      )
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}