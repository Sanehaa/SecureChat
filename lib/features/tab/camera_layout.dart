import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uwu_chat/features/tab/camera_view.dart';

late List<CameraDescription> cameras;

class CameraLayout extends StatefulWidget {
  const CameraLayout({Key? key}) : super(key: key);

  @override
  State<CameraLayout> createState() => _CameraLayoutState();
}

class _CameraLayoutState extends State<CameraLayout> {
  late CameraController _cameraController;
  late Future<void> cameraValue;

  @override
  void initState() {
    super.initState();
    initializeCamera().then((_) {
      _cameraController = CameraController(cameras[0], ResolutionPreset.high);
      cameraValue = _cameraController.initialize().then((_) {
        setState(() {}); // Trigger rebuild after camera initialization
      });
    });
  }

  Future<void> initializeCamera() async {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
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
                return CameraPreview(_cameraController);
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
                        onPressed: () {},
                        icon: Icon(Icons.flash_off, color: Colors.white, size: 28),
                      ),
                      InkWell(
                        onTap: () {
                          takePhoto(context);
                        },
                        child: Icon(Icons.panorama_fish_eye, color: Colors.white, size: 70),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.flip_camera_ios, color: Colors.white, size: 28),
                      ),
                    ],
                  ),
                  SizedBox(height: 8), // Adjust the spacing between Row and Text as needed
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
    final directory = await getTemporaryDirectory();
    final path = join(directory.path, "${DateTime.now()}.png");
    //await _cameraController.takePicture(path!);
    Navigator.push(context, MaterialPageRoute(builder: (builder) => CameraView()));
  }
}
