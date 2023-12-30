// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_supabase_auth/homepage.dart';
import 'package:flutter_supabase_auth/signup.dart';
import 'package:gap/gap.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class SignIn extends StatefulWidget {
  const SignIn({super.key});
  String _generateRandomString() {
    final random = Random.secure();
    return base64Url.encode(List<int>.generate(16, (_) => random.nextInt(256)));
  }

// Sign in with Google
  Future<void> googleSignIn(Function(bool result) onSignInComplete) async {
    try {
      // await supabase.auth.signOut();
      const appAuth = FlutterAppAuth();

      // Just a random string
      final rawNonce = _generateRandomString();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

      /// Client ID that you registered with Google Cloud.
      final clientId = Platform.isIOS
          ? '119449090698-v7hm3bkot5uaka9fuo84phtbvvbl6nc2.apps.googleusercontent.com'
          : '119449090698-mlrmllnl96loepb2hd2n0isrn29pji00.apps.googleusercontent.com';

      /// Set as reversed DNS form of Google Client ID + `:/` for Google login
      final redirectUrl = '${clientId.split('.').reversed.join('.')}:/';
      print('redirectUrl:$redirectUrl');

      /// Fixed value for google login
      const discoveryUrl =
          'https://accounts.google.com/.well-known/openid-configuration';

      dev.log("google authrizations processing");

      // authorize the user by opening the concent page
      final result = await appAuth.authorize(
        AuthorizationRequest(
          clientId,
          redirectUrl,
          discoveryUrl: discoveryUrl,
          nonce: hashedNonce,
          scopes: [
            'openid',
            'email',
            'profile',
          ],
        ),
      );

      dev.log("google token 1");

      if (result == null) {
        throw 'No result';
      }

      dev.log("google token 2");

      // Request the access and id token to google
      final tokenResult = await appAuth.token(
        TokenRequest(
          clientId,
          redirectUrl,
          authorizationCode: result.authorizationCode,
          discoveryUrl: discoveryUrl,
          codeVerifier: result.codeVerifier,
          nonce: result.nonce,
          scopes: [
            'openid',
            'email',
            'profile',
          ],
        ),
      );

      final idToken = tokenResult?.idToken;

      if (idToken == null) {
        throw 'No idToken';
      }

      // AuthResponse resp = await supabase.auth.signInWithIdToken(
      //   provider: OAuthProvider.google,
      //   idToken: idToken,
      //   nonce: rawNonce,
      // );

      // bool resp = await supabase.auth
      //     .signInWithOAuth(Provider.google,
      //         authScreenLaunchMode:
      //             LaunchMode.inAppWebView);

      dev.log("google login successful");
      onSignInComplete(true);
    } catch (e) {
      dev.log("google login failed");
      dev.log(e.toString());
    }
    onSignInComplete(false);
  }

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset('assets/flutter_supabase.png',
                    height: 260, width: 350),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.only(
                      bottom: 20.0, left: 20.0, right: 20.0, top: 10.0),
                  child: Text('Sign In Page',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                Container(
                  padding:
                      const EdgeInsets.only(left: 25, right: 25, bottom: 20),
                  child: TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(40)),
                      ),
                      labelText: 'Email',
                      contentPadding: EdgeInsets.all(15),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 25, right: 25),
                  child: TextField(
                    obscureText: true,
                    controller: passwordController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(40)),
                      ),
                      labelText: 'Password',
                      contentPadding: EdgeInsets.all(15),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 130,
                      child: MaterialButton(
                        color: Colors.green,
                        height: 40,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 3,
                        onPressed: () async {
                          final sm = ScaffoldMessenger.of(context);

                          try {
                            // Attempt to sign up the user
                            final authResponse =
                                await supabase.auth.signInWithPassword(
                              password: passwordController.text,
                              email: emailController.text,
                            );
                            // Check if the sign-up was successful
                            if (authResponse.user != null) {
                              sm.showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Signed In Successful." /*${authResponse.user!.email!}*/,
                                  ),
                                ),
                              );
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const HomePage()));

                              // Navigate to the home page
                            } else {
                              // Display an appropriate error message
                              sm.showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        "Sign-In failed. Please try again.")),
                              );
                            }
                          } catch (error) {
                            // Handle specific errors, e.g., if user is already registered
                            if (error is AuthException) {
                              // for user friendly error message, nested "if"
                              if (error.statusCode == 400) {
                                sm.showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        " User not found. Please Sign Up "),
                                  ),
                                );
                              } else {
                                // Handle other AuthException errors
                                sm.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      " Authentication error: ${error.message}",
                                    ),
                                  ),
                                );
                              }
                            } else {
                              // Handle other errors
                              sm.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Error:${error.toString()}",
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        child: const Text(
                          'Sign In',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 130,
                      child: MaterialButton(
                        height: 40,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: Colors.green, width: 2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignUp()),
                          );
                        },
                        child: const Text('Sign Up'),
                      ),
                    )
                  ],
                ),
                const Gap(25),
                SizedBox(
                  width: 250,
                  child: MaterialButton(
                    height: 50,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.green, width: 2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    onPressed: () {
                      final sm = ScaffoldMessenger.of(context);
                      widget.googleSignIn(
                        (bool result) async {
                          if (result == true) {
                            // Sign-in completed successfully
                            sm.showSnackBar(
                              const SnackBar(
                                content: Text("Signed In Successful."),
                              ),
                            );
                            // Navigate to the home page
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomePage(),
                              ),
                            );
                          }
                          // else {
                          //   // Display an appropriate error message
                          //   sm.showSnackBar(
                          //     const SnackBar(
                          //       content:
                          //           Text("Sign-In failed. Please try again."),
                          //     ),
                          //   );
                          // }
                        },
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/google.png', height: 30, width: 30),
                        const Gap(10),
                        const Text('Sign In with Google'),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
