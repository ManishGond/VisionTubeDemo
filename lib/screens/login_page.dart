import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/otpverification.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String _verificationId = '';
  final FocusNode _focusNode = FocusNode();
  final _formkey = GlobalKey<FormState>();
  bool _isFieldFocused = false;

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _verifyPhoneNumber() async {
    String phoneNumber = '+91${_phoneNumberController.text.trim()}';
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);

        _navigateToOtpVerificationPage();
      },
      verificationFailed: (FirebaseAuthException e) {
        // Handle verification failure
        if (kDebugMode) {
          print('Verification Failed: ${e.message}');
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
        });
        // Navigate to the OTP verification page with the verificationId
        _navigateToOtpVerificationPage();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
        });
        // Handle code auto-retrieval timeout
      },
    );
  }

  void _navigateToOtpVerificationPage() {
    String phoneNumber = '+91${_phoneNumberController.text.trim()}';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyVerify(
          phoneNumber: phoneNumber,
          verificationId: _verificationId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 25),
                  Image.asset(
                    'assets/logo.png', // Replace with your image asset path
                    width: 400, // Adjust the width as needed
                    height: 400, // Adjust the height as needed
                  ),
                  SizedBox(height: 3),
                ],
              ),
            ),
          ),
          const Positioned(
            top: 345,
            left: 20,
            child: Text(
              'Login or SignUp',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(120, 120, 120, 1),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
              child: Form(
                key: _formkey,
                child: TextFormField(
                  controller: _phoneNumberController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Phone',
                    prefixIcon:
                        _isFieldFocused ? null : const Icon(Icons.phone),
                    prefixText: _isFieldFocused ? '+91 ' : '',
                    prefixStyle: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromRGBO(
                            99, 24, 175, 1), // Change the border color here
                      ),
                    ),
                  ),
                  focusNode: _focusNode,
                  onTap: () {
                    setState(() {
                      _isFieldFocused = true;
                    });
                  },
                  onEditingComplete: () {
                    setState(() {
                      _isFieldFocused = false;
                    });
                  },
                  validator: (value) {
                    // Step 2: Validation function
                    if (value == null || value.isEmpty) {
                      return 'Phone number is required'; // Step 3: Error message
                    }
                    return null; // Return null if validation succeeds
                  },
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 460,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_formkey.currentState!.validate()) {
                        // If form validation succeeds, proceed with verification
                        _verifyPhoneNumber();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(
                            99, 24, 175, 1), // Change the button color
                        minimumSize: const Size(double.infinity, 50)),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Lexend',
                          fontStyle: FontStyle.normal),
                    ),
                  ),
                  const SizedBox(
                    height: 200,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: RichText(
                      text: const TextSpan(
                        text: 'By continuing, you agree to our \n',
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'Lexend',
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                        ),
                        children: [
                          TextSpan(
                            text: 'Terms of Service',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          TextSpan(text: ' \t '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
