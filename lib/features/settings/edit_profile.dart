import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../auth/delete_account.dart';
import '../one_to_one_chat/home.dart';
import 'package:http_parser/http_parser.dart'as http_parser;
import 'package:uwu_chat/configurations/config.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late String _username = '';
  late XFile? _image = null;
  late TextEditingController _usernameController = TextEditingController();
  late TextEditingController _emailcontroller=TextEditingController();
  Color customColor1 = const Color(0xff0F2630);
  Color customColor2 = const Color(0xff0F2630);
  Color customColor3 = const Color(0xFF088395);

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadDarkModePreference();
  }



  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'John Doe';
      _usernameController.text = _username;
      String? imagePath = prefs.getString('profileImagePath');
      _image = imagePath != null ? XFile(imagePath) : null;
      String? userEmail = prefs.getString('userEmail');
      _emailcontroller.text = userEmail ?? '';
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      bool confirmChange = await _showConfirmDialog();

      if (confirmChange) {
        print("Selected image path: ${pickedImage.path}");
        _saveImageToLocalStorage(pickedImage.path);
        setState(() {
          _image = pickedImage;
        });

        // Upload the image and save its URL
        await uploadProfilePicture(pickedImage.path);
      }
    }
  }

  Future<void> _saveImageToLocalStorage(String imagePath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('profileImagePath', imagePath);
  }

  Future<void> _saveUsernameToLocalStorage(String newUsername) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', newUsername);
  }


  Future<bool> _showConfirmDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Change Profile Picture?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    ) ?? false;
  }
  Future<void> uploadProfilePicture(String imagePath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId == null) {
      print("User ID not found");
      return;
    }

    var apiUrl = Uri.parse('$updatepp/');
    var imageFile = File(imagePath);
    late String contentType;

    // Determine contentType based on file extension
    if (imageFile.path.toLowerCase().endsWith('.jpg') || imageFile.path.toLowerCase().endsWith('.jpeg')) {
      contentType = 'jpeg';
    } else if (imageFile.path.toLowerCase().endsWith('.png')) {
      contentType = 'png';
    } else {
      // Handle other formats if needed
      print("Unsupported image format");
      return;
    }

    var request = http.MultipartRequest('POST', apiUrl)
      ..files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: http_parser.MediaType('image', contentType),
      ))
      ..fields['userId'] = userId;

    print("Request URL: $apiUrl");
    print("User ID: $userId");
    print("Image Path: $imagePath");

    try {
      var response = await request.send();
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${await response.stream.bytesToString()}");


      if (response.statusCode == 200) {
        var imageUrl = await response.stream.bytesToString();
        await saveImageUrlToDatabase(imageUrl);
      } else {
        print("Failed to upload image. Status code: ${response.statusCode}");
      }
    } catch (error) {
      print("Error uploading image: $error");
    }
  }



  Future<void> saveImageUrlToDatabase(String imageUrl) async {
    var saveUrlApi = Uri.parse('$updatepp/');
    try {
      var response = await http.post(saveUrlApi, body: {'imageUrl': imageUrl});

      if (response.statusCode == 200) {
        print("Image URL saved in the database");
      } else {
        print("Failed to save image URL. Status code: ${response.statusCode}");
      }
    } catch (error) {
      print("Error saving image URL: $error");
    }
  }

  bool _isDarkMode = false;

  void _loadDarkModePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Profile',
          style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black,),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded),
          color: _isDarkMode ? Colors.white : Colors.black,
          onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => HomeScreen()
                )
              );
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Hero(
                  tag: 'profile-picture',
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DestinationScreen(profileImage: _image),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 40,
                        backgroundImage: _image != null && File(_image!.path).existsSync()
                            ? FileImage(File(_image!.path))
                            : null,
                    ),
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _username,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        const Text(
                          'Edit Profile Picture',
                          style: TextStyle(
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 50,),
            Column(
              children: [
                TextFormField(
                  controller: _usernameController,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                onChanged: (value) {
                  setState(() {
                    _username = value;
                  });
                  _saveUsernameToLocalStorage(value);
                },
                  decoration: InputDecoration(
                    fillColor: _isDarkMode ? Colors.white : Colors.black,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                  ),
                ),

                SizedBox(height: 30,),
                TextFormField(
                  enabled: false,
                  controller: _emailcontroller,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    fillColor:_isDarkMode ? Colors.white : Colors.black,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48.0),
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Username updated'),
                    ),
                  );                },
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      side: BorderSide(color: customColor3, width: 3),
                    ),
                  ),
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  minimumSize: MaterialStateProperty.all<Size>(Size(double.infinity, 50)),

                ),
                child: Text(
                  'Save Changes',
                  style: TextStyle(color: customColor3, fontWeight: FontWeight.w700, fontSize: 18),

                ),
              ),
            ),

            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 64, right: 64),
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Divider(
                  color: Colors.blueGrey,
                  thickness: 1.5,
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal:48.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DeleteAccount(),
                    ),
                  );
                },
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      side: BorderSide(color: Colors.blueGrey, width: 3),
                    ),
                  ),
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  minimumSize: MaterialStateProperty.all<Size>(Size(double.infinity, 50)),
                ),
                child: Text(
                  'Delete Account',
                  style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w700, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),

    );
  }
}


class DestinationScreen extends StatelessWidget {
  final XFile? profileImage;

  DestinationScreen({Key? key, this.profileImage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Hero(
          tag: 'profile-picture',
          child: CircleAvatar(
            radius: 80,
            backgroundImage: profileImage != null && File(profileImage!.path).existsSync()
                ? FileImage(File(profileImage!.path))
                : null,
          ),
        ),
      ),
    );
  }
}
