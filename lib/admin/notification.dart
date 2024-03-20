import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constant/imageString.dart';



class NotificationPage extends StatelessWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text("Notification"),
        ),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
              child: Column(
                children: [
                  // Center(child: Text("noxtification")),
                  SizedBox(height: 50,),
                  Center(
                    child: Container(
                      //margin: const EdgeInsets.symmetric(vertical: 40),
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height/3,
                      decoration: const BoxDecoration(
                        image: DecorationImage(image: AssetImage(wel_img),
                        ),
                      ),
                    ),
                  ),
                  Text("No Notification",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),


                ],
              ))),
    );
  }
}
