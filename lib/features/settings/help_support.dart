import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart'as http_parser;
import 'package:shared_preferences/shared_preferences.dart';

class HelpandSupport extends StatefulWidget {
  const HelpandSupport({Key? key}) : super(key: key);

  @override
  _HelpandSupportState createState() => _HelpandSupportState();
}

class _HelpandSupportState extends State<HelpandSupport> {
  TextEditingController descriptionController = TextEditingController();
  PickedFile? _pickedImage;

  Future<void> _pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _pickedImage = pickedImage != null ? PickedFile(pickedImage.path) : null;
    });
  }

  Future<String?> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail');
  }

  Future<void> submitIssue(String description, String? imagePath) async {
    try {
      String? userEmail = await getUserEmail();

      final apiUrl = Uri.parse('http://172.16.168.90:3000/submit-issue');
      final request = http.MultipartRequest('POST', apiUrl);

      request.fields['description'] = description;
      if (userEmail != null) {
        request.fields['userEmail'] = userEmail;
      }

      // Add the image file if available
      if (imagePath != null) {
        final imageFile = File(imagePath);
        final contentType = imageFile.path.toLowerCase().endsWith('.jpg') ||
            imageFile.path.toLowerCase().endsWith('.jpeg')
            ? 'image/jpeg'
            : imageFile.path.toLowerCase().endsWith('.png')
            ? 'image/png'
            : 'application/octet-stream';

        request.files.add(await http.MultipartFile.fromPath(
          'screenshot',
          imageFile.path,
          contentType: http_parser.MediaType.parse(contentType),
        ));
      }

      print('Request URL: ${request.url}');
      print('Request headers: ${request.headers}');
      print('Request fields: ${request.fields}');
      print(
          'Request files: ${request.files.map((file) => file.filename)}');

      // Send the request
      final response =
      await http.Response.fromStream(await request.send());

      if (response.statusCode == 200) {
        // Issue submitted successfully
        final responseData = jsonDecode(response.body);
        print(responseData['message']);
      } else {
        // Handle error
        print('Failed to submit issue. Error: ${response.body}');
      }
    } catch (error) {
      // Handle error
      print('Error: $error');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help and Support'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Reports about abuse or spam shouldn\'t be submitted here. That includes things that aren\'t allowed on SecureChat, such as violence, criminal behavior, offensive content, and issues affecting safety, integrity, and authenticity.',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Describe the issue',
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _pickImage();
                },
                child: const Text('Attach Screenshot'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await submitIssue(descriptionController.text, _pickedImage?.path);
                },
                child: const Text('Send Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
