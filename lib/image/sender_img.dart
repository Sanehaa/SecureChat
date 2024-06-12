import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uwu_chat/constants/theme_constants.dart';
import '../configurations/config.dart';

class SenderImage extends StatelessWidget {
  const SenderImage({Key? key, required this.path}) : super(key: key);

  final String path;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: Container(

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            //color: AppColors.secondary,
          ),
          child: Card(
            margin: EdgeInsets.all(3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Image.network(
              imgurl+path,
              height: MediaQuery.of(context).size.height / 2.3,
              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }
                return CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

