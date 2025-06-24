import 'package:flutter/material.dart';
import 'package:plantae_project/signUp.dart';
import 'package:plantae_project/login.dart';
import 'package:plantae_project/mainPage.dart';
import 'package:plantae_project/addPost.dart';
import 'package:plantae_project/userProfile.dart';
import 'package:plantae_project/EditUserProfile.dart';
import 'package:plantae_project/forgetPassword.dart';

class AppRoutes {
  static const String SIGNUP_PAGE = "/signup";
  static const String Login_PAGE = "/login";
  static const String HOME_PAGE = "/home";
  static const String ADD_POST = "/add_post";
  static const String USER_PROFILE = "/user_profile";
  static const String EDIT_USER_PROFILE = "/edit_user_profile";
  static const String FORGET_PASSWORD = "/forgetPassword";

  static Map<String, WidgetBuilder> routes = {
    '/': (context) => MainPage(),
    SIGNUP_PAGE: (context) => SignUp(),
    Login_PAGE: (context) => Login(),
    HOME_PAGE: (context) => MainPage(),
    ADD_POST: (context) => AddPost(),
    USER_PROFILE: (context) => UserProfile(),
    EDIT_USER_PROFILE: (context) => EditUserProfile(),
    FORGET_PASSWORD: (context) => Forgetpassword(),
  };

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (c) => MainPage());
      case AppRoutes.SIGNUP_PAGE:
        return MaterialPageRoute(builder: (c) => SignUp());
      case AppRoutes.Login_PAGE:
        return MaterialPageRoute(builder: (c) => Login());
      case AppRoutes.HOME_PAGE:
        return MaterialPageRoute(builder: (c) => MainPage());
      case AppRoutes.ADD_POST:
        return MaterialPageRoute(builder: (c) => AddPost());
      case AppRoutes.USER_PROFILE:
        return MaterialPageRoute(builder: (c) => UserProfile());
      case AppRoutes.EDIT_USER_PROFILE:
        return MaterialPageRoute(builder: (c) => EditUserProfile());
      case AppRoutes.FORGET_PASSWORD:
        return MaterialPageRoute(builder: (c) => Forgetpassword());
      default:
        return MaterialPageRoute(builder: (c) => MainPage());
    }
  }
  // <dynamic> for templates so that may return different types of values not single type
  // route is a class , dont know return datatype so write dynamic-> will automatically judge returntype
  // flutter says that to manage routes pass RoutesSettings to that function that returns routes
  // settings.name has string name of route
}
