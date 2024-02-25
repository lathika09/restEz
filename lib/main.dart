import 'package:flutter/material.dart';
import 'package:rest_ez_app/screens/welcome.dart';
// import 'package:new_project/screens/welcome.dart';
import 'package:rest_ez_app/splashScreens/splash_screen.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {
        'welcome':(context)=>const WelcomePage(),
      },
      home: SplashScreen(),
    );
  }
}