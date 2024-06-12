import 'package:flutter/material.dart';

import '../configurations/config.dart';
import '../constants/theme_constants.dart';

class ReceiverImage extends StatelessWidget {
  const ReceiverImage({super.key, required this.path});
  final String path;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: Container(
          height: MediaQuery.of(context).size.height/2.3,
          width: MediaQuery.of(context).size.width/1.8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: AppColors.textLight,
          ),
          child: Card(
            margin: EdgeInsets.all(3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Image.network(
              imgurl+path, // Replace this with your image URL
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
