import 'package:flutter/material.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:uwu_chat/configurations/login_response_model.dart';
import 'package:snippet_coder_utils/ProgressHUD.dart';
import 'package:uwu_chat/features/one_to_one_chat/home.dart';

class EmailVerification extends StatefulWidget {
  final String? email;
  final String otpHash;

  const EmailVerification({Key? key, required this.email, required this.otpHash})
      : super(key: key);

  @override
  State<EmailVerification> createState() => _EmailVerificationState();
}

class _EmailVerificationState extends State<EmailVerification> {
  String otpCode = '';
  bool isApiCallProcess = false;
  GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  Color customColor3 = const Color(0xFF088395);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Email Verification'),
            ),
            body: ProgressHUD(
                inAsyncCall: isApiCallProcess,
                key: UniqueKey(),
                child: Form(
                  key: globalKey,
                  child: loginverificationUI(),
                ))));
  }

  loginverificationUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Email verification',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Text(
            'Enter the 4 digit code you received on your email',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            width: 200,
            child: FormHelper.inputFieldWidget(
              context,
              "code",
              "",
              (onValidateVal) {
                if (onValidateVal.isEmpty) {
                  return 'Required';
                }
              },
              (onSaved) {
                otpCode = onSaved;
              },
              borderRadius: 10,
              borderColor: Colors.grey,
              maxLength: 4,
              isNumeric: true,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          FormHelper.submitButton('Submit',
                  btnColor: customColor3,() {
            if (validateandSave()) {
              setState(() {
                isApiCallProcess = true;
              });
              //print(email);
              int expires = DateTime.now().add(Duration(minutes: 5)).millisecondsSinceEpoch;
              APIService.verifyOTP(widget.email!, widget.otpHash!, otpCode, expires)
                  .then((response) {
                setState(() {
                  isApiCallProcess = false;
                });
                print("API Response: ${response.data}");

                if (response != null && response.data != null) {
                  // print("Data from API: ${response.data}");
                  FormHelper.showSimpleAlertDialog(context,
                      "Email Verification", response.message ?? "Success", "Ok", () {
                    Navigator.pop(context );
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => HomeScreen()));
                  });
                  //otp verification page
                  //print("Data from API: ${response.data}");
                } else {
                  print("API response or data is null");
                    FormHelper.showSimpleAlertDialog(context,
                        "Email Verification", response.message ?? "Error", "Ok", () {
                      Navigator.pop(context);
                    });
                    //otp verification page
                    //print("Data from API: ${response.data}");
                  }
              });
            }
          })
        ],
      ),
    );
  }

  bool validateandSave() {
    final form = globalKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }
}

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$').hasMatch(this);
  }
}
