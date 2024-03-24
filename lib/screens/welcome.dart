import 'package:flutter/material.dart';
import 'package:rest_ez_app/admin/home.dart';
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
                        // fontFamily: 'Headland One',
                        fontWeight: FontWeight.bold,
                        fontSize: 38,
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
              SizedBox(height: 20,),
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
                          Navigator.push(context,MaterialPageRoute(builder: (context)=>UserPage(name: 'Hari Kumar',)));//FOR USER
                        },
                        color: Colors.blue[100],
                        shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                color:Colors.black
                            ),
                            borderRadius: BorderRadius.circular(50)
                        ),
                        child: const Text("USER",
                          style: TextStyle(
                            fontFamily: 'Merriweather Sans',
                            color: Colors.black,

                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),),
                      ),
                      const SizedBox(height:15),
                      MaterialButton(
                        minWidth:double.infinity,
                        height: 50,
                        onPressed:(){
                          Navigator.push(context,MaterialPageRoute(builder: (context)=>LoginPage()
                              // Navigator.push(context,MaterialPageRoute(builder: (context)=>AdminPage(email: "admin@gmail.com")

                          ));//FOR  ADMIN
                        },
                        color: Colors.blue[900],
                        shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                color:Colors.black
                            ),
                            borderRadius: BorderRadius.circular(50)
                        ),
                        child: const Text("ADMIN",
                          style: TextStyle(
                            fontFamily: 'Merriweather Sans',
                            color: Colors.white,
                            fontSize: 26,
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
