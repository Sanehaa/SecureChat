import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uwu_chat/features/tab/camera_view.dart';
import 'package:uwu_chat/features/tab/video_view.dart';

late List<CameraDescription> cameras;

class CameraLayout extends StatefulWidget {
  CameraLayout({Key? key, required this.onImageSend}) : super(key: key);
  final Function onImageSend;

  @override
  State<CameraLayout> createState() => _CameraLayoutState();
}

class _CameraLayoutState extends State<CameraLayout> {
  late CameraController _cameraController;
  late Future<void> cameraValue;
  bool isRecording = false;
  bool flash = false;
  bool isCameraFront = true;
  double transform = 0;

  @override
  void initState() {
    super.initState();
    // Initialize the cameras variable
    availableCameras().then((value) {
      setState(() {
        cameras = value;
        _cameraController = CameraController(cameras[0], ResolutionPreset.high);
        cameraValue = _cameraController.initialize();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _cameraController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          FutureBuilder(
            future: cameraValue,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: CameraPreview(_cameraController));
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 26, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(flash ? Icons.flash_on : Icons.flash_off,
                            color: Colors.white, size: 28),
                        onPressed: () {
                          setState(() {
                            flash = !flash;
                          });
                          flash
                              ? _cameraController.setFlashMode(FlashMode.torch)
                              : _cameraController.setFlashMode(FlashMode.off);
                        },
                      ),
                      GestureDetector(
                        onLongPress: () async {
                          await _cameraController.startVideoRecording();
                          setState(() {
                            isRecording = true;
                          });
                        },
                        onLongPressUp: () async {
                          XFile videoPath =
                          await _cameraController.stopVideoRecording();
                          setState(() {
                            isRecording = false;
                          });
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) =>
                                      VideoView(path: videoPath.path)));
                        },
                        onTap: () {
                          if (!isRecording) takePhoto(context);
                        },
                        child: isRecording
                            ? Icon(
                          Icons.radio_button_on,
                          color: Colors.red,
                          size: 80,
                        )
                            : Icon(Icons.panorama_fish_eye,
                            color: Colors.white, size: 70),
                      ),
                      IconButton(
                        icon: Transform.rotate(
                            angle: transform,
                            child: Icon(Icons.flip_camera_ios,
                                color: Colors.white, size: 28)),
                        onPressed: () async {
                          setState(() {
                            isCameraFront = !isCameraFront;
                            transform = transform + pi;
                          });
                          int cameraPos = isCameraFront ? 0 : 1;
                          _cameraController = CameraController(
                              cameras[cameraPos], ResolutionPreset.high);
                          cameraValue = _cameraController.initialize();
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // Adjust the spacing between Row and Text as needed
                  Text(
                    "Hold for video, tap for photo",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void takePhoto(BuildContext context) async {
    // final path = join((await getTemporaryDirectory()).path, "${DateTime.now()}.png");
    XFile path = await _cameraController.takePicture();
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (builder) => CameraView(
              path: path.path,
              onImageSend: widget.onImageSend,
            ))).then((value) => Navigator.pop(context));
  }
}
