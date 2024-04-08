import 'package:flutter/material.dart';
import 'package:rest_ez_app/screens/welcome.dart';
import 'package:rest_ez_app/splashScreens/splash_screen.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:firebase_core/firebase_core.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyBnT_PrYdayJZeWeCn1CXtn49CF01bDQGY",
        appId: "1:861406143290:android:dc0be6c4d60ae7f0416603",
        messagingSenderId: "861406143290",
        projectId: "restez-82af7",
        storageBucket:"restez-82af7.appspot.com",
    )
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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