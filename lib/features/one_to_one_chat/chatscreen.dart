import 'dart:async';
import 'dart:io';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:uwu_chat/constants/theme_constants.dart';
import 'package:uwu_chat/features/one_to_one_chat/contacts.dart';
import 'package:uwu_chat/features/one_to_one_chat/message.dart';
import 'package:uwu_chat/features/tab/camera_layout.dart';
import 'package:screen_capture_event/screen_capture_event.dart';
import 'package:uwu_chat/features/tab/camera_view.dart';
import 'package:uwu_chat/image/sender_img.dart';
import '../../call/call.dart';
import '../../call/utils.dart';
import '../../constants/icons.dart';
import 'package:uwu_chat/configurations/config.dart';
import 'package:http/http.dart' as http;
import '../../image/receiver_img.dart';
import 'package:file_picker/file_picker.dart';

//get the fcm token of other user
Future<String?> getFCMToken(String userId) async {
  print('User ID being sent in getFCMToken: $userId');
  var url = Uri.parse('$getfcm');
  var response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'userId': userId}),
  );

  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    var fcmToken = data['fcmToken'];
    print('FCM token retrieved successfully: $fcmToken');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('fcmToken', fcmToken);
    return fcmToken;
  } else {
    print('Failed to get FCM token: ${response.body}');
    return null;
  }
}

//ss notification
Future<void> sendScreenshotNotification(String receiverFcmToken) async {
  print(
      'To send the screenshot the fcmtoken of the receiver is: $receiverFcmToken');
  try {
    final prefs = await SharedPreferences.getInstance();
    final sender = prefs.getString('userEmail');
    if (sender == null) {
      print('Sender email not found in SharedPreferences');
      return;
    }

    var url = Uri.parse('http://192.168.112.37:3000/sendScreenshotNotification');
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'sender': sender,
        'receiverFcmToken': receiverFcmToken,
      }),
    );

    if (response.statusCode == 200) {
      print('Screenshot notification sent successfully');
    } else {
      print('Error sending screenshot notification: ${response.body}');
    }
  } catch (error) {
    print('Error sending screenshot notification: $error');
  }
}

//copy notification
Future<void> sendCopyNotification(
    String receiverFcmToken, String copiedText) async {
  print('copy button: $receiverFcmToken and $copiedText');

  try {
    final prefs = await SharedPreferences.getInstance();
    final sender = prefs.getString('userEmail');
    print('send is $sender');
    if (sender == null) {
      print('Sender email not found in SharedPreferences');
      return;
    }

    final url = Uri.parse('http://192.168.112.37:3000/sendCopyNotification');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'sender': sender,
        'receiverFcmToken': receiverFcmToken,
        'copiedText': copiedText,
      }),
    );

    if (response.statusCode == 200) {
      print('Copy notification sent successfully');
    } else {
      print('Error sending copy notification: ${response.body}');
    }
  } catch (error) {
    print('Error sending copy notification: $error');
  }
}

Future<void> sendForwardNotification(
    String receiverFcmToken, String forwardedMessage) async {
  print("forward button: $receiverFcmToken and $forwardedMessage");

  try {
    final prefs = await SharedPreferences.getInstance();
    final sender = prefs.getString('userEmail');
    print('send is $sender');
    if (sender == null) {
      print('Sender email not found in SharedPreferences');
      return;
    }

    final url = Uri.parse('http://192.168.112.37:3000/sendForwardNotification');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'sender': sender,
        'receiverFcmToken': receiverFcmToken,
        'forwardedMessage': forwardedMessage,
      }),
    );

    if (response.statusCode == 200) {
      print('Forward notification sent successfully');
    } else {
      print('Error sending forward notification: ${response.body}');
    }
  } catch (error) {
    print('Error sending forward notification: $error');
  }
}

class ChatScreenn extends StatefulWidget {
  final String username;
  final String userId;

  const ChatScreenn({Key? key, required this.username, required this.userId})
      : super(key: key);

  @override
  State<ChatScreenn> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreenn> {
  bool _isScreenshotted = false;
  bool _isDarkMode = false;
  bool _isConnected = false;

  void _loadDarkModePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  void _sendScreenshottedMessage() {
    _socket.emit('screenshotted', {
      'message': 'This chat has been screenshotted',
      'sender': widget.username,
    });

    _socket.emit('screenshotted', {
      'message': 'This chat has been screenshotted',
      'sender': widget.username,
    });
  }

  String? fcmToken;
  final ScreenCaptureEvent screenListener = ScreenCaptureEvent();
  late IO.Socket _socket;
  final TextEditingController textEditingController = TextEditingController();

  static _ChatScreenState? of(BuildContext context) =>
      context.findAncestorStateOfType<_ChatScreenState>();

  List<Message> messagesList = [];
  late String userId;
  late String otherUserId = '';
  String channelname = "";

  Future<void> _getUserIdFromSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUserId = prefs.getString('userId');
    if (storedUserId != null) {
      setState(() {
        userId = storedUserId;
      });
      print('User ID from SharedPreferences: $storedUserId');
    } else {
      print('User ID not available');
    }
  }

  Future<void> _sendMessageToServer(String message, String path) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sender = prefs.getString('userEmail');
      print("this is the sender off this message: $sender");
      if (sender == null) {
        print('Sender email not found in SharedPreferences');
        return;
      }

      var url = Uri.parse('$sendmsg');
      var requestBody = json.encode({
        'message': message,
        'path': path,
        'senderUsername': sender,
        'userId': otherUserId,
      });
      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );
      if (response.statusCode == 201) {
        var data = json.decode(response.body);
        print('Message sent: ${data['message']}');
      } else {
        print('Failed to send message: ${response.body}');
      }
    } catch (error) {
      print('Error sending message: $error');
    }
  }

  Future<void> _fetchMessages() async {
    try {
      if (_isConnected) {
        // Fetch messages via socket communication
        var url =
            Uri.parse('http://192.168.112.37:3000/receivemsg/$otherUserId');
        var response = await http.get(
          url,
          headers: <String, String>{
            'Content-Type': 'application/json',
          },
        );
        if (response.statusCode == 200) {
          print('Response body: ${response.body}');
          var data = json.decode(response.body);
          setState(() {
            messagesList = (data['messages'] as List)
                .map((message) => Message.fromJson(message))
                .toList();
          });
          print('Messages fetched successfully');
        } else {
          print('Failed to fetch messages: ${response.body}');
        }
      } else {
        // Fetch messages via HTTP request
        // You can implement the logic to fetch messages from the server here
      }
    } catch (error) {
      print('Error fetching messages: $error');
    }
  }

  void _sendMessage(String message, String path) {
    if (_isConnected) {
      _socket.emit('message', {
        'message': message,
        'path': path,
        'sender': widget.username,
      });
    } else {
      _sendMessageToServer(message, path);
    }
  }

  void _connectSocket() {
    _socket.onConnect((_) {
      print('Connection established');
      setState(() {
        _isConnected = true;
      });
    });
    _socket.onConnectError((data) {
      print('Connect Error: $data');
      setState(() {
        _isConnected = false;
      });
    });
    _socket.onDisconnect((_) {
      print('Socket.IO server disconnected');
      setState(() {
        _isConnected = false;
      });
    });
    _socket.on('message', (data) {
      Message message = Message.fromJson(data);
      setState(() {
        messagesList.add(message);
      });
    });

    _socket.on('screenshotted', (data) {
      setState(() {
        _isScreenshotted = true;
      });
    });
  }



  @override
  void initState() {
    super.initState();

    _loadDarkModePreference();
    _getPermissions();
    _getUserIdFromSharedPrefs().then((_) {
      _socket = IO.io(
        'http://192.168.112.37:3000',
        IO.OptionBuilder().setTransports(['websocket']).setQuery(
            {'username': widget.username, 'userId': userId}).build(),
      );
      print('Socket connection established with userId: $userId');
      _connectSocket();
      screenListener.addScreenShotListener((filePath) {
        _sendScreenshotNotification(filePath);
      });
      screenListener.watch();

      _getOtherUserId(widget.username);
      print(widget.username);
      _getOtherUserId(widget.username).then((_) async {
        getFCMToken(otherUserId).then((token) {
          setState(() {
            fcmToken = token;
          });
          print('Retrieved FCM Token: $token');
          sendScreenshotNotification(token!);
        });
        _fetchMessages();
      });
    });
  }

  Future<void> _getMicPermissions() async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      final micPermission = await Permission.microphone.request();
      if (micPermission == PermissionStatus.granted) {
        //setState(() => _isMicEnabled = true);
      }
    } else {
      // setState(() => _isMicEnabled = !_isMicEnabled);
    }
  }

  Future<void> _getCameraPermissions() async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      final cameraPermission = await Permission.camera.request();
      if (cameraPermission == PermissionStatus.granted) {
        // setState(() => _isCameraEnabled = true);
      }
    } else {
      // setState(() => _isCameraEnabled = !_isCameraEnabled);
    }
  }

  Future<void> _getPermissions() async {
    await _getMicPermissions();
    await _getCameraPermissions();
  }

  Future<void> _getOtherUserId(String username) async {
    try {
      var url = Uri.parse('http://192.168.112.37:3000/user/id');
      var requestBody = json.encode({'email': widget.username});
      print('Request body: $requestBody');
      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data.containsKey('userId')) {
          otherUserId = data['userId'];
          print('Other user\'s userId: $otherUserId');
        } else {
          print('User ID not found in response data');
        }
      } else {
        print('Failed to get other user\'s userId: ${response.body}');
      }
    } catch (error) {
      print('Error getting other user\'s userId: $error');
    }
  }

  @override
  void dispose() {
    textEditingController.dispose();
    screenListener.dispose();
    super.dispose();
  }

  Future<void> getchannelname() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String senderemail = prefs.getString('userEmail') ?? "";
    String receiveremail = widget.username;
    channelname = senderemail.compareTo(receiveremail) <= 0
        ? senderemail + receiveremail
        : receiveremail + senderemail;
    print(channelname);
  }

  _sendScreenshotNotification(String filePath) {
    print("Screenshot stored on: $filePath");
    sendScreenshotNotification(fcmToken!);
    _sendScreenshottedMessage();

    setState(() {
      _isScreenshotted = true;
    });

    _socket.emit('screenshotted', {
      'message': 'This chat has been screenshotted',
      'sender': widget.username,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 54,
        leading: Align(
          alignment: Alignment.centerRight,
          child: IconBackground(
            icon: Icons.arrow_back,
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        title: Text(widget.username,
            style: TextStyle(
                color: _isDarkMode ? Colors.white : Colors.black,
                fontSize: 15)),
        actions: [
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: IconBorder(
                  icon: Icons.video_call,
                  onTap: () async {
                    await getchannelname();
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => VideoCallPage(
                          appId: appID,
                          token: null,
                          channelName: channelname,
                          isMicEnabled: true,
                          isVideoEnabled: true,
                        ),
                      ),
                    );
                  },
                ),
              )),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(
              child: IconBorder(
                icon: Icons.phone,
                onTap: () async {
                  await getchannelname();
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => VideoCallPage(
                        appId: appID,
                        token: null,
                        channelName: channelname,
                        isMicEnabled: true,
                        isVideoEnabled: false,
                      ),
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _DemoMessageList(
              messagesList: messagesList,
              username: widget.username, // Pass the username
              isScreenshotted: _isScreenshotted,
            ),
          ),
          _ActionBar(
            sendMessageCallback: _sendMessage,
            // _sendMessageCallback: _sendMessage,
          ),
          if (_isScreenshotted)
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8),
              color: Colors.blueGrey,
              child: Text(
                'This chat has been screenshotted',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DemoMessageList extends StatelessWidget {
  final List<Message> messagesList;
  final String username;
  final bool isScreenshotted;

  const _DemoMessageList(
      {Key? key,
      required this.messagesList,
      required this.username,
      required this.isScreenshotted})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListView.builder(
        itemCount: messagesList.length,
        itemBuilder: (context, index) {
          Message message = messagesList[index];

          bool isSentMessage = message.senderUsername == username;

          if (isSentMessage) {
            return _SendersMsg(
              message: message.message,
              path: message.path,
              messageDate: message.sentAt.toString(),
              isScreenshotted: isScreenshotted,
            );
          } else {
            return ReceiversMsg(
              message: message.message,
              path: message.path,
              messageDate: message.sentAt.toString(),
              isScreenshotted: isScreenshotted,
            );
          }
        },
      ),
    );
  }
}

class ReceiversMsg extends StatelessWidget {
  const ReceiversMsg({
    Key? key,
    required this.message,
    required this.path,
    required this.messageDate,
    required this.isScreenshotted,
  }) : super(key: key);

  final String message;
  final String path;
  final String messageDate;
  final bool isScreenshotted;

  static const _borderRadius = 20.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.copy),
                  title: Text('Copy'),
                  onTap: () async {
                    // Retrieve FCM token from shared preferences
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    String? receiverFcmToken = prefs.getString('fcmToken');

                    if (receiverFcmToken != null) {
                      //sendNotificationToOriginalSender(message);
                      Clipboard.setData(ClipboardData(text: message));
                      sendCopyNotification(receiverFcmToken, message);
                    } else {
                      print('FCM token not found in shared preferences');
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.forward),
                  title: Text('Forward'),
                  onTap: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    String? receiverFcmToken = prefs.getString('fcmToken');
                    if (receiverFcmToken != null) {
                      //sendNotificationToOriginalSender(message);
                      Clipboard.setData(ClipboardData(text: message));
                      sendForwardNotification(receiverFcmToken, message);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Contacts()),
                      );
                    } else {
                      print('FCM token not found in shared preferences');
                    }
                  },
                ),
              ],
            );
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              path == ""
                  ? Container(
                      decoration: const BoxDecoration(
                        color: AppColors.textLight,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(_borderRadius),
                          topRight: Radius.circular(_borderRadius),
                          bottomRight: Radius.circular(_borderRadius),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 20),
                        child: Text(
                          message,
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    )
                  : ReceiverImage(path: path),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  messageDate,
                  style: const TextStyle(
                    color: AppColors.textFaded,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _SendersMsg extends StatelessWidget {
  const _SendersMsg({
    Key? key,
    required this.message,
    required this.path,
    required this.messageDate,
    required this.isScreenshotted,
  }) : super(key: key);

  final String message;
  final String path;
  final String messageDate;
  final bool isScreenshotted;
  static const _borderRadius = 20.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.copy),
                  title: Text('Copy'),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.forward),
                  title: Text('Forward'),
                  onTap: () {},
                ),
              ],
            );
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Align(
          alignment: Alignment.centerRight,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              path == ""
                  ? Container(
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(_borderRadius),
                          bottomRight: Radius.circular(_borderRadius),
                          bottomLeft: Radius.circular(_borderRadius),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 20),
                        child: Text(message,
                            style: const TextStyle(
                              color: AppColors.textLight,
                            )),
                      ),
                    )
                  : SenderImage(path: path),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  messageDate,
                  style: const TextStyle(
                    color: AppColors.textFaded,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionBar extends StatefulWidget {
  final void Function(String message, String path) sendMessageCallback;

  const _ActionBar({required this.sendMessageCallback, Key? key})
      : super(key: key);

  @override
  State<_ActionBar> createState() => _ActionBarState();
}

class _ActionBarState extends State<_ActionBar> {
  bool showEmojiPicker = false;
  late TextEditingController textEditingController;
  late FocusNode textFocusNode;
  final ImagePicker _picker = ImagePicker();
  late XFile file;
  TimeOfDay? selectedTime;
  late String path;
  String? scheduledMessage;

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
    textFocusNode = FocusNode();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    textFocusNode.dispose();

    super.dispose();
  }

  void _showScheduleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Schedule Message'),
                SizedBox(height: 16),
                TextField(
                  controller: textEditingController,
                  decoration: InputDecoration(
                    labelText: 'Enter your message',
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final TimeOfDay? timeOfDay = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                      initialEntryMode: TimePickerEntryMode.dial,
                    );
                    if (timeOfDay != null) {
                      setState(() {
                        selectedTime = timeOfDay;
                      });
                    }
                  },
                  child: Text(selectedTime == null
                      ? 'Select Time'
                      : 'Selected Time: ${selectedTime!.format(context)}'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (selectedTime != null &&
                        textEditingController.text.trim().isNotEmpty) {
                      scheduledMessage = textEditingController.text.trim();
                      _scheduleMessage(selectedTime!, scheduledMessage!);
                    }
                  },
                  child: Text('Confirm'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  //documnet sharing
  Future<void> _pickAndShareDocument(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
      );

      if (result != null) {
        String filePath = result.files.single.path!;

        await _uploadDocument(filePath);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Document shared successfully')),
        );
      }
    } catch (e) {
      print('Error picking document: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing document: $e')),
      );
    }
  }

  Future<void> _uploadDocument(String filePath) async {
    Uri url = Uri.parse('http://192.168.112.37:3000/upload');

    var request = http.MultipartRequest('POST', url);

    request.files.add(await http.MultipartFile.fromPath('document', filePath));

    var response = await request.send();
    if (response.statusCode == 200) {
      print('Document uploaded successfully');
    } else {
      print('Failed to upload document. Status code: ${response.statusCode}');
    }
  }


  void _scheduleMessage(TimeOfDay time, String message) {
    final now = TimeOfDay.now();
    final currentTime = DateTime.now();
    final scheduledTime = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
      time.hour,
      time.minute,
    );

    final delay = scheduledTime.difference(currentTime);
    if (delay.isNegative) {
      final tomorrow = scheduledTime.add(Duration(days: 1));
      final newDelay = tomorrow.difference(currentTime);
      Timer(newDelay, () => _sendMessage(message));
    } else {
      Timer(delay, () => _sendMessage(message));
    }
  }

  void _sendMessage(String message) {
    String path = '';
    widget.sendMessageCallback(message, path);
    setState(() {
      selectedTime = null;
      textEditingController.clear();
    });
    print('Message sent: $message');
  }

  void onImageSend(String path) async {
    print("hey there working $path");
    var request = http.MultipartRequest(
        "POST", Uri.parse("http://192.168.112.37:3000/addImage"));
    request.files.add(await http.MultipartFile.fromPath("img", path));
    request.headers.addAll({
      "Content-type": "multipart/form-data",
    });
    http.StreamedResponse response = await request.send();
    print(response.statusCode);

    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      try {
        var jsonResponse = json.decode(responseBody);
        String message = '';
        String imgpath = jsonResponse["path"];
        widget.sendMessageCallback(message, imgpath);
      } catch (e) {
        print("Error decoding JSON response: $e");
      }
    } else {
      print("Error: Unexpected status code ${response.statusCode}");
    }
  }

  _onBackspacePressed() {
    textEditingController
      ..text = textEditingController.text.characters.toString()
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: textEditingController.text.length));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        width: 2,
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      toggleEmojiPicker();
                      FocusScope.of(context).unfocus();
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.0),
                      child: Icon(Icons.emoji_emotions_outlined),
                    ),
                  ),
                ),
                // Additional Icons
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        width: 2,
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      showModalBottomSheet(
                          backgroundColor: Colors.transparent,
                          context: context,
                          builder: (builder) => bottomSheet(context));
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.0),
                      child: Icon(Icons.attach_file),
                    ),
                  ),
                ),
                Container(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CameraLayout(
                                  onImageSend: onImageSend,
                                )),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.0),
                      child: Icon(Icons.camera_alt),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Stack(
                      children: [
                        TextField(
                          controller: textEditingController,
                          style: const TextStyle(fontSize: 14),
                          decoration: const InputDecoration(
                            hintText: 'Type something...',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                          ),
                        ),
                        Positioned.fill(
                          child: GestureDetector(
                            onLongPress: () {
                              _showScheduleDialog(context);
                            },
                            behavior: HitTestBehavior.translucent,
                            child: Container(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 12,
                    right: 18.0,
                  ),
                  child: IconButton(
                    onPressed: () {
                      if (textEditingController.text.trim().isNotEmpty) {
                        String message = textEditingController.text.trim();
                        String path = '';
                        widget.sendMessageCallback(message, path);
                        textEditingController.clear();
                      }
                    },
                    icon: const Icon(Icons.send_rounded),
                  ),
                ),
              ],
            ),
            Offstage(
              offstage: !showEmojiPicker,
              child: SizedBox(
                height: 250,
                child: EmojiPicker(
                  textEditingController: textEditingController,
                  onBackspacePressed: _onBackspacePressed,
                  config: const Config(
                    columns: 7,
                    emojiSizeMax: 32,
                    verticalSpacing: 0,
                    horizontalSpacing: 0,
                    gridPadding: EdgeInsets.zero,
                    bgColor: Colors.white,
                    indicatorColor: Colors.blue,
                    iconColor: Colors.grey,
                    iconColorSelected: Colors.blue,
                    backspaceColor: Colors.blue,
                    enableSkinTones: true,
                    recentTabBehavior: RecentTabBehavior.RECENT,
                    recentsLimit: 28,
                    replaceEmojiOnLimitExceed: false,
                    noRecents: Text(
                      'No Recents',
                      style: TextStyle(fontSize: 20, color: Colors.black26),
                      textAlign: TextAlign.center,
                    ),
                    loadingIndicator: SizedBox.shrink(),
                    tabIndicatorAnimDuration: kTabScrollDuration,
                    categoryIcons: CategoryIcons(),
                    buttonMode: ButtonMode.MATERIAL,
                    checkPlatformCompatibility: true,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget bottomSheet(BuildContext context) {
    return Container(
      height: 278,
      width: MediaQuery.of(context).size.width,
      child: Card(
        margin: const EdgeInsets.all(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconCreation(Icons.insert_drive_file, AppColors.secondary,
                      "Document", () {_pickAndShareDocument(context);}),
                  const SizedBox(width: 30),
                  iconCreation(Icons.camera_alt, AppColors.secondary, "Camera",
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CameraLayout(
                                onImageSend: onImageSend,
                              )),
                    );
                  }),
                  const SizedBox(width: 30),
                  iconCreation(
                      Icons.insert_photo, AppColors.secondary, "Gallery",
                      () async {
                    file =
                        (await _picker.pickImage(source: ImageSource.gallery))!;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CameraView(
                                path: file.path,
                                onImageSend: onImageSend,
                              )),
                    );
                  }),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconCreation(
                      Icons.headset, AppColors.secondary, "Audio", () {}),
                  const SizedBox(width: 30),
                  iconCreation(Icons.location_pin, AppColors.secondary,
                      "Location", () {}),
                  const SizedBox(width: 30),
                  iconCreation(
                      Icons.person, AppColors.secondary, "Contact", () {}),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget iconCreation(
      IconData icon, Color color, String text, Function()? onTap) {
    return Column(
      children: [
        IconButton(
          icon: CircleAvatar(
            radius: 30,
            backgroundColor: color,
            child: Icon(
              icon,
              size: 29,
              color: Colors.white,
            ),
          ),
          onPressed: onTap,
        ),
        const SizedBox(height: 1),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  void toggleEmojiPicker() {
    setState(() {
      showEmojiPicker = !showEmojiPicker;
    });
  }
}
