
import 'package:flutter/material.dart';
import 'package:whatsapp_webapp/View/WebPages/home_page.dart';
import 'package:whatsapp_webapp/View/WebPages/login_signup_page.dart';
import 'package:whatsapp_webapp/View/WebPages/messages_page.dart';

import '../../Model/user_model.dart';

class RoutesForWebPages {
  static Route<dynamic> createRoutes(RouteSettings settingsRoute) {
    final arguments = settingsRoute.arguments;
    switch (settingsRoute.name) {
      case '/':
        return MaterialPageRoute(builder: (context) => const LoginSignUpPage());
      case '/login':
        return MaterialPageRoute(builder: (context) => const LoginSignUpPage());
      case '/home':
        return MaterialPageRoute(builder: (context) => const HomePage());
      case '/messages':
        return MaterialPageRoute(builder: (context) => MessagesPage(arguments as UserModel));
    }
    return errorPageRoute();
  }
  static Route<dynamic> errorPageRoute(){
    return MaterialPageRoute(builder: (c){
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Web Page not found"),
        ),
        body: const Center(child: Text("Web Page not found")),
      );
    });
  }
}
