import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:visiontube/screens/nav_screen.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formField = GlobalKey<FormState>();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  final Logger logger = Logger();

  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  bool isSaving = false;
  String? fullNameError;
  String? emailError;

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> addUser() async {
    setState(() {
      isSaving = true;
    });

    String email = emailController.text;
    String username = email.split('@')[0];
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      final String phoneNumber = currentUser.phoneNumber ?? '';

      // Add the user to the "users" collection
      DocumentReference userRef = usersCollection.doc(currentUser.uid);
      await userRef.set({
        'full_name': fullNameController.text,
        'email': emailController.text,
        'phone': phoneNumber,
        'username': username,
        'photoUrl': '',
        'subscribers': 0,
      });

      Fluttertoast.showToast(
        msg: "Successfully Registered",
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      setState(() {
        isSaving = false;
      });

      // Navigate to the MainScreen after a delay of 1 second
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NavScreen()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.black,
          ),
        ),
        elevation: 0,
      ),
      body: Container(
        margin: const EdgeInsets.only(left: 25, right: 25, bottom: 200),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Form(
            key: _formField,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Just a step away !',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Lexend',
                    color: Colors.white,
                    fontStyle: FontStyle.normal,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(
                          color: const Color.fromARGB(255, 206, 206, 206),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextFormField(
                        controller: fullNameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name *',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Field is required";
                          }
                          return null;
                        },
                      ),
                    ),
                    if (fullNameError != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 10, top: 5),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            fullNameError!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(
                          color: const Color.fromARGB(255, 206, 206, 206),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email ID *',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                        ),
                        validator: (value) {
                          bool emailValid = RegExp(
                                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(value!);
                          if (value.isEmpty) {
                            return "Field is required";
                          } else if (!emailValid) {
                            return "Enter Valid EmailID";
                          }
                          return null;
                        },
                      ),
                    ),
                    if (emailError != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 10, top: 5),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            emailError!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 90),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6318AF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      if (_formField.currentState!.validate()) {
                        setState(() {
                          fullNameError = null;
                          emailError = null;
                        });
                        addUser();
                      }
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (isSaving) const CircularProgressIndicator(),
                        const Text(
                          "Let's Start",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
