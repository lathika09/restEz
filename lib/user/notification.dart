import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        title: RichText(
          text: TextSpan(
              style: const TextStyle(fontSize: 28,
                  // fontFamily: 'El Messiri',
                  fontWeight: FontWeight.bold),
              children: <TextSpan>[
                const TextSpan(text: 'Rest', style: TextStyle(color: Colors.black)),
                TextSpan(
                    text: 'Ez', style: TextStyle(color: Colors.blueAccent[700]))
              ]
          ),
        ),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
              child: Container(
                color: Colors.indigo.shade100,
                child: Column(
                  children: [
                    // Center(child: Text("noxtification")),
                    SizedBox(height: 50,),
                    Center(
                      child: Container(
                        //margin: const EdgeInsets.symmetric(vertical: 40),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height/2,
                        child: Lottie.network("https://lottie.host/bfbb09ce-c8fc-4bd9-8525-8622d9334d28/uci9kEqmj7.json")
                          //  "https://lottie.host/6904c33f-a134-46f8-8e07-b54ba2d6141e/0TNJyxIgmU.json"),
                      ),
                    ),
                    Text("No Notification",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    SizedBox(height: 450,)

                  ],
                ),
              ))),
    );
  }
}
