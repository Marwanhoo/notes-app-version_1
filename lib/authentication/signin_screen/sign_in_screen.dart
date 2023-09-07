import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_notes_app/authentication/signup_screen/sign_up_screen.dart';
import 'package:flutter_notes_app/components/components.dart';
import 'package:flutter_notes_app/screens/home/home_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../forgot_pass/forgot_pass_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  TextEditingController emailAddressController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isPassword = true;
  var formKey = GlobalKey<FormState>();

  signIn() async {
    if (formKey.currentState!.validate()) {
      try {
        showLoading(context);
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailAddressController.text,
          password: passwordController.text,
        );
        return userCredential;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          Navigator.of(context).pop();
          showErrorWhenSignInEmail();
        } else if (e.code == 'wrong-password') {
          Navigator.of(context).pop();
          showErrorWhenSignInPassword();
        }
      }
    }
  }

  showErrorWhenSignInEmail() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Email",
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        content: const Text("No user found for that email."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  showErrorWhenSignInPassword() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Password",
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        content: const Text("Wrong password provided for that user."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    emailAddressController.dispose();
    passwordController.dispose();
    super.dispose();
  }
@override
  void initState() {
  AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    if(!isAllowed){
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  });
  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 10,
      channelKey: 'basic_channel',
      title: 'Notes App',
      body: 'Welcome Back',
    ),
  );
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //automaticallyImplyLeading: false,
        title: const Text('Sign In Screen'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      controller: emailAddressController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter email address';
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                      )),
                  const SizedBox(height: 20),
                  TextFormField(
                    obscureText: isPassword,
                    controller: passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            isPassword = !isPassword;
                          });
                        },
                        icon: (isPassword)
                            ? const Icon(Icons.visibility)
                            : const Icon(Icons.visibility_off),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account?",
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SignUpScreen(),
                            ),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            "Sign Up",
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ForgotPassScreen(),
                            ),
                          );
                        },
                        child: const Text("Forgot Password?"),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () async {
                        UserCredential response = await signIn();
                        debugPrint("response : $response");
                        if (context.mounted) {
                          Navigator.of(context).pushReplacement(
                            CupertinoPageRoute(
                              builder: (context) => const HomeScreen(),
                            ),
                          );
                        }
                      },
                      child: const Text("Sign In"),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await signInWithGoogle();
                        if (context.mounted) {
                          Navigator.of(context).pushReplacement(
                            CupertinoPageRoute(
                              builder: (context) => const HomeScreen(),
                            ),
                          );
                        }
                      },
                      label: const Text("Sign In With Google"),
                      icon: Image.asset(
                        "assets/images/google.png",
                        width: 40,
                        height: 20,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {},
                      label: const Text("Sign In With Facebook"),
                      icon: Image.asset(
                        "assets/images/facebook.png",
                        width: 40,
                        height: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    if (context.mounted) {
      showLoading(context);
    }
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}
