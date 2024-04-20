// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tripsathihackathon/auth/authmethods.dart';
import 'package:tripsathihackathon/screens/home.dart';
import 'package:tripsathihackathon/screens/login.dart';
import 'package:tripsathihackathon/screens/navbar.dart';
import 'package:tripsathihackathon/utils/utils.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  late Future<void> _preloadScreen;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phonecontroller = TextEditingController();
  final TextEditingController _otpcontroller = TextEditingController();

  Uint8List? _image;

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _emailError = false;
  late String verificationId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _preloadScreen = _preloadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _preloadData();
    }
  }

  Future<void> _preloadData() async {
    // ignore: unused_local_variable
    BuildContext context = this.context;

    await Future.delayed(const Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final Size screenSize = MediaQuery.of(context).size;

    return FutureBuilder(
      future: _preloadScreen,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            body: Stack(
              children: [
                _buildBackgroundImage(),
                _buildPunchlineText(screenSize),
                _buildGlassmorphismContainer(screenSize),
                _buildAgreementText(),
              ],
            ),
          );
        }
      },
    );
  }

  @override
  bool get wantKeepAlive => true;

  Widget _buildBackgroundImage() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/Spline1.jpeg'),
          fit: BoxFit.cover,
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white70.withOpacity(0.0),
                  Colors.white70.withOpacity(0.0)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPunchlineText(Size screenSize) {
    return Positioned(
      top: screenSize.height * 0.065,
      left: screenSize.width * 0.06,
      child: Text('Get Started!',
          style: GoogleFonts.dmSerifDisplay(
            color: Colors.black,
            fontSize: screenSize.width * 0.1,
            fontWeight: FontWeight.bold,
          )),
    );
  }

  Widget _buildGlassmorphismContainer(Size screenSize) {
    return Center(
      child: Container(
        width: screenSize.width * 0.95,
        height: screenSize.height * 0.72,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white70.withOpacity(0.4),
              Colors.white70.withOpacity(0.3)
            ],
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white70.withOpacity(0.3),
                    Colors.white70.withOpacity(0.3)
                  ],
                ),
              ),
              child: _buildFormFields(screenSize),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormFields(Size screenSize) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.bottomLeft,
            children: [
              _image != null
                  ? CircleAvatar(
                      radius: 64,
                      backgroundImage: MemoryImage(_image!),
                    )
                  : const CircleAvatar(
                      radius: 64,
                      backgroundImage: AssetImage('assets/images/default.png'),
                    ),
              Positioned(
                bottom: -10,
                left: 80,
                child: IconButton(
                  onPressed: selectImage,
                  icon: const Icon(Icons.add_a_photo),
                ),
              ),
            ],
          ),
          SizedBox(height: screenSize.height * 0.032),
          _buildTextField(
            hintText: 'Enter Username',
            suffixIcon: const Icon(Icons.person),
            onChanged: (value) {
              // Add your logic here
            },
            keyboardType: TextInputType.text,
            controller: _usernameController,
          ),
          SizedBox(height: screenSize.height * 0.022),
          _buildTextField(
            hintText: 'Enter Email',
            errorText: _emailError ? 'Enter a valid email' : null,
            suffixIcon: const Icon(Icons.email_outlined),
            onChanged: (_) => _validateEmail(),
            keyboardType: TextInputType.emailAddress,
            controller: _emailController,
          ),
          SizedBox(height: screenSize.height * 0.022),
          _buildTextField(
            hintText: 'Enter Password',
            suffixIcon: IconButton(
              icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
            onChanged: (_) {},
            keyboardType: TextInputType.text,
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
          ),
          SizedBox(height: screenSize.height * 0.022),
          _buildTextField(
            hintText: 'Enter Bio',
            suffixIcon: const Icon(Icons.info),
            onChanged: (value) {
              // Add your logic here
            },
            keyboardType: TextInputType.text,
            controller: _bioController,
          ),
          SizedBox(height: screenSize.height * 0.022),
          _buildSignupButton(screenSize),
          SizedBox(height: screenSize.height * 0.008),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    String? errorText,
    required Widget suffixIcon,
    required void Function(String) onChanged,
    required TextInputType keyboardType,
    required TextEditingController controller,
    bool obscureText = false,
  }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          errorText: errorText,
          suffixIcon: Padding(
            padding: EdgeInsets.only(
                right: MediaQuery.of(context).size.width * 0.00),
            child: suffixIcon,
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.deepPurple,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.black,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          filled: true,
          fillColor: Colors.white70.withOpacity(0.3),
          contentPadding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.02,
            horizontal: MediaQuery.of(context).size.width * 0.04,
          ),
        ),
        keyboardType: keyboardType,
        controller: controller,
        obscureText: obscureText,
      ),
    );
  }

  Widget _buildSignupButton(Size screenSize) {
    bool isButtonEnabled = _usernameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _bioController.text.isNotEmpty &&
        _image != null;

    return InkWell(
      onTap: isButtonEnabled ? signUpUser : null,
      child: Container(
        width: screenSize.width * 0.8,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.015),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: isButtonEnabled
                ? [Colors.purpleAccent, Colors.red]
                : [Colors.grey.withOpacity(0.5), Colors.grey.withOpacity(0.5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Text(
                'Sign Up',
                style: GoogleFonts.josefinSans(),
              ),
      ),
    );
  }

  Widget _buildAgreementText() {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'By signing up you agree to',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Ownership Statement'),
                    content: OwnershipStatement(),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Close'),
                      ),
                    ],
                  );
                },
              );
              // Add logic for terms and conditions
            },
            child: const Text(
              'Ownership Statement',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void selectImage() async {
    Uint8List? img = await pickAndCompressImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });
  }

  void _validateEmail() {
    setState(() {
      final String email = _emailController.text.trim();
      _emailError = !RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
          .hasMatch(email);
    });
  }

  void signUpUser() async {
    // _validateEmail();
    setState(() {
      _isLoading = true;
    });
    String res = await AuthMethods().signUpUsers(
      username: _usernameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      bio: _bioController.text,
      // phone: _phonecontroller.text,
      //  otp: _otpcontroller.text,
      file: _image!,
    );

    setState(() {
      _isLoading = false;
    });

    if (res != 'success') {
      showSnackBar(res, context);
    } else {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const PersonalFeed()));
    }

    if (!_emailError) {
      setState(() {
        _isLoading = true;
      });

      // Add your signup logic here

      setState(() {
        _isLoading = false;
      });
    }
  }
}
