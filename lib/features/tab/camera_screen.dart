import 'package:flutter/material.dart';
import 'package:uwu_chat/features/tab/camera_layout.dart';
import 'package:http/http.dart' as http;

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  void onImageSend(String path) async {
    print("hey there working $path");
    var request = http.MultipartRequest("POST",Uri.parse("http://192.168.112.37:3000/routes/addImage"));
    request.files.add(await http.MultipartFile.fromPath("img", path));
    request.headers.addAll({
      "Content-type": "multipart/form-data",
    });
    http.StreamedResponse response = await request.send();
    print(response.statusCode);


  }

  @override
  Widget build(BuildContext context) {
    return CameraLayout(onImageSend: onImageSend,);
  }
}