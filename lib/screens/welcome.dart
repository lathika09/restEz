import 'package:flutter/material.dart';
import 'package:rest_ez_app/constant/imageString.dart';

import '../admin/loginPage.dart';
import '../user/homepage.dart';



class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color:Colors.white,
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.symmetric(horizontal: 30,vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Expanded(
                flex: 0,
                child: Column(
                  children: [
                    Text("Welcome !!!",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                      ),
                    ),
                    SizedBox(
                      height:10,
                    ),
                    Text("To get started choose the User type",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),],
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  //margin: const EdgeInsets.symmetric(vertical: 40),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration: const BoxDecoration(
                    image: DecorationImage(image: AssetImage(wel_img),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      MaterialButton(
                        minWidth:double.infinity,
                        height: 50,
                        onPressed:(){
                          // Replacement
                          Navigator.push(context,MaterialPageRoute(builder: (context)=>UserPage()));//FOR PATIENTS
                        },
                        color: Color(0XFF92C7F2),
                        shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                color:Colors.black
                            ),
                            borderRadius: BorderRadius.circular(50)
                        ),
                        child: const Text("USER",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),),
                      ),
                      const SizedBox(height:15),
                      MaterialButton(
                        minWidth:double.infinity,
                        height: 50,
                        onPressed:(){
                          Navigator.push(context,MaterialPageRoute(builder: (context)=>LoginPage()));//FOR  DOCTOR BUTTON GO TO HOMEPAGE
                        },
                        color: Color(0XFF0E4674),
                        shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                color:Colors.black
                            ),
                            borderRadius: BorderRadius.circular(50)
                        ),
                        child: const Text("ADMIN",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),),
                      ),


                    ],
                  ),
                ),
              )

            ],
          ),

        ),
      ),
    );
  }
}
