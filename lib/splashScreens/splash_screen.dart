import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rest_ez_app/constant/imageString.dart';
import 'package:rest_ez_app/splashScreens/splash_controller.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({Key? key}) : super(key: key);

  final splashScreenController=Get.put(SplashScreenController());

  @override
  Widget build(BuildContext context) {

    splashScreenController.startAnimation();
    return Scaffold(

      body:Container(
        decoration: BoxDecoration(
          // gradient: LinearGradient(
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          //   colors: [Colors.blue, Colors.green], // Adjust the colors as needed
          // ),
          image: DecorationImage(
            image: AssetImage('assets/bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Obx(
                  ()=> AnimatedPositioned(
                duration:const Duration(milliseconds: 1600),
                top: 110,
                left:splashScreenController.animate.value ? 0:30,
                right:splashScreenController.animate.value ? 0:30,
                child:AnimatedOpacity(
                    duration: const Duration(milliseconds: 1000),
                    opacity: splashScreenController.animate.value ? 1 : 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.transparent
                        ),

                      // width: MediaQuery.of(context).size.width*0.3,
                        child: Center(
                          child: Image.asset(SplashMiddle, width: MediaQuery.of(context).size.width*0.6,
                            height: MediaQuery.of(context).size.height*0.6,
                            // fit: BoxFit.cover,
                          ),
                        ))
                ),
              ),
            ),
            Obx(
                  ()=> AnimatedPositioned(duration:const Duration(milliseconds: 1100),
                bottom: 190,
                left:20,
                child:AnimatedOpacity(
                  duration: const Duration(milliseconds: 1000),
                  opacity: splashScreenController.animate.value ? 1 : 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width/6),
                    child:RichText(
                      text: TextSpan(
                          style: TextStyle(
                              // fontFamily: 'Headland One',
                              fontSize: 60, fontWeight: FontWeight.bold),
                          children: <TextSpan>[
                            TextSpan(text: 'Rest', style: TextStyle(color: Colors.black)),
                            TextSpan(
                                text: 'Ez', style: TextStyle(color: Colors.blue[900]))
                          ]),
                    ),
                    // Text(appname,style: TextStyle(
                    //     fontSize: 45,
                    //     color: Colors.black,
                    //     fontWeight: FontWeight.w700,
                    //     shadows: [Shadow(color: Colors.blueAccent, offset: Offset(1,1), blurRadius:2)]
                    // ),
                    // ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

    );
  }
}
