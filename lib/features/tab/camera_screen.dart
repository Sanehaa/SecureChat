import 'package:flutter/material.dart';
import 'package:uwu_chat/features/tab/camera_layout.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  @override
  Widget build(BuildContext context) {
    return CameraLayout();
  }
}