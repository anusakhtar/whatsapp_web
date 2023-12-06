import 'package:flutter/material.dart';
import 'package:whatsapp_webapp/res/AppColors/app_colors.dart';
import 'package:whatsapp_webapp/res/WebPages/home_page.dart';
import 'package:whatsapp_webapp/res/WebPages/login_signup_page.dart';
import 'package:whatsapp_webapp/res/routes/routes_web_pages.dart';
final String firstroute = '/';
void main() {
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final ThemeData defaultthemeofweb = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: AppColor.primaryColor));
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Whatsapp Webapp',
      theme: defaultthemeofweb,
      initialRoute: firstroute,
      onGenerateRoute: RoutesForWebPages.createroutes,
      home: LoginSignUpPage(),
    );
  }
}
