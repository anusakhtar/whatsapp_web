import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_webapp/View/WebPages/login_signup_page.dart';
import 'package:whatsapp_webapp/res/AppColors/app_colors.dart';

import 'package:whatsapp_webapp/res/routes/routes_web_pages.dart';
const String firstRoute = '/';
void main() async{
  Firebase.initializeApp(
    options:const FirebaseOptions(
        apiKey: "AIzaSyAqY2rQNSTGZyOlPkHlr4dVS_0bXYhIPeI",
        authDomain: "whatsappwebapp-35e75.firebaseapp.com",
        projectId: "whatsappwebapp-35e75",
        storageBucket: "whatsappwebapp-35e75.appspot.com",
        messagingSenderId: "866651944362",
        appId: "1:866651944362:web:966908d98f1db4febbe7d3"
    ),
  );
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final ThemeData defaultThemeOfWeb = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: AppColor.primaryColor));
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Whatsapp Webapp',
      theme: defaultThemeOfWeb,
      initialRoute: firstRoute,
      onGenerateRoute: RoutesForWebPages.createRoutes,
      home: const LoginSignUpPage(),
    );
  }
}
