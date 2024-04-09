import 'package:flutter/material.dart';
import '../constant/imageString.dart';



class NotificationPage extends StatelessWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text("Notification",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 24),),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 50,),
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
                  const SizedBox(height: 20,),
                  const Text("No Notification",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                    ),
                  ),


                ],
              )
          )
      ),
    );
  }
}
