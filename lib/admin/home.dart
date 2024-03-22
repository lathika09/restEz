import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rest_ez_app/admin/restroomManage.dart';
import 'package:rest_ez_app/admin/suggestionsList.dart';
import 'package:rest_ez_app/user/Profile.dart';

import '../constant/imageString.dart';
import 'loginPage.dart';
import 'notification.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key,required this.email});
  final String email;

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        backgroundColor:Colors.white,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        leading: IconButton(
          onPressed: (){
            showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Logout Confirmation"),
                content: const Text("Are you sure you want to log out?"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      Navigator.pushReplacement( context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                      await FirebaseAuth.instance.signOut();
                    },
                    child: const Text("Yes"),
                  ),
                  TextButton(
                    onPressed: () {
                      // User canceled, simply close the dialog
                      Navigator.of(context).pop();
                    },
                    child: const Text("No"),
                  ),
                ],
              );
            },
          );
          },
          icon: Icon(
            Icons.logout,
            size: 30,
            color: Colors.blue[900],
          ),
        ),
        title:Center(
          child: RichText(
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
        // elevation: 24.0,
        actions: <Widget>[IconButton(
          icon: const Icon(Icons.notifications,size: 30,color: Colors.black,),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationPage()),);
          },
        ),
        ],
      ),
      body:SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                  child:Container(
                    width: MediaQuery.of(context).size.width,
                    padding:const EdgeInsets.symmetric(vertical: 30.0, horizontal: 50.0),
                    decoration: BoxDecoration(
                      color:Colors.blue[900],
                      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30.0),    // Bottom-left corner
                        bottomRight: Radius.circular(30.0), ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          spreadRadius: 3,
                          blurRadius: 5,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 10.0),
                            child: Image.asset(logo, width: MediaQuery.of(context).size.width / 2),
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        const Text("Welcome to $appname",style: TextStyle(
                            fontSize: 27,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            shadows: [Shadow(color: Colors.blueAccent, offset: Offset(1,1), blurRadius:2)]
                        ),
                        ),
                      ],
                    ),
                  )
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 25.0),
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          // width: 130,
                          // height: 130,
                          width:MediaQuery.of(context).size.width/3,
                          height: MediaQuery.of(context).size.height/6,
                          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),

                          decoration: BoxDecoration(
                            color:Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.shade200.withOpacity(0.3),
                                spreadRadius: 3,
                                blurRadius: 5,
                                offset: const Offset(0, 20),
                              ),
                            ],),
                          child:GestureDetector(
                            child: Card(
                              color:Colors.blue[200],
                              elevation: 2,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    // width: 75,
                                    // height: 75,
                                    padding: const EdgeInsets.symmetric(vertical: 5.0,),
                                    color:Colors.transparent,
                                    child: const Icon(Icons.home_work_sharp,size: 50,color: Colors.black,),
                                  ),
                                  const Text("Restrooms",softWrap:true,style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 16),),
                                ],),
                            ),
                            onTap: (){

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>ManageRestroom(adminEmail: widget.email,),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 30,),
                        Container(
                          // width: 130,
                          // height: 130,
                          width:MediaQuery.of(context).size.width/3,
                          height: MediaQuery.of(context).size.height/6,
                          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                          decoration: BoxDecoration(
                            color:Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color:Colors.blue.shade200.withOpacity(0.3),
                                spreadRadius: 3,
                                blurRadius: 5,
                                offset: const Offset(0, 20),
                              ),
                            ],),
                          child:GestureDetector(
                            child: Card(
                              color:Colors.blue[200],
                              elevation: 2,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    // width: 75,
                                    // height: 75,
                                    padding: const EdgeInsets.symmetric(vertical: 5.0,),
                                    color:Colors.transparent,
                                    child: const Icon(FontAwesomeIcons.book ,size: 40,color: Colors.black,),
                                  ),
                                  const Text("Suggestions",maxLines:1,style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 16),),
                                ],),
                            ),
                            onTap: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) =>
                                    // UserProfile(name: "Hari Kumar")
                                    SuggestionStatus( adminEmail: widget.email,)
                              ),
                              );
                            },
                          ),
                        ),
                      ],),
                    const SizedBox(height: 30,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          // width: 130,
                          // height: 130,
                          width:MediaQuery.of(context).size.width/3,
                          height: MediaQuery.of(context).size.height/6,
                          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                          decoration: BoxDecoration(
                            color:Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.shade200.withOpacity(0.3),
                                spreadRadius: 3,
                                blurRadius: 5,
                                offset: const Offset(0, 20),
                              ),
                            ],),
                          child:GestureDetector(
                            child: Card(
                              color:Colors.blue[200],
                              elevation: 2,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    // height: same,
                                    // width: 75,
                                    padding: EdgeInsets.symmetric(vertical: 5.0,),
                                    color:Colors.transparent,
                                    child: const Icon(Icons.report,size: 50,color: Colors.black,),
                                  ),
                                  const Text("Issues",softWrap:true,maxLines:2,style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 16),),
                                ],),
                            ),
                            onTap: (){
                              // if (widget.email != null) {
                              //   Navigator.push(
                              //     context,
                              //     MaterialPageRoute(builder: (context) => MainChatScreenDoc(email: widget.email)),
                              //   );
                              // }
                            },
                          ),
                        ),
                        const SizedBox(width: 30,),
                        Container(
                          // width: 130,
                          // height: 130,
                          width:MediaQuery.of(context).size.width/3,
                          height: MediaQuery.of(context).size.height/6,

                          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),

                          decoration: BoxDecoration(
                            color:Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.shade200.withOpacity(0.3),
                                spreadRadius: 3,
                                blurRadius: 5,
                                offset: const Offset(0, 20),
                              ),
                            ],),
                          child:GestureDetector(
                            child: Card(
                              color:Colors.blue[200],
                              elevation: 2,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    // width: 75,
                                    // height: 75,
                                    padding: const EdgeInsets.symmetric(vertical: 5.0,),
                                    color:Colors.transparent,
                                    child: const Icon(FontAwesomeIcons.imagePortrait,size: 50,color: Colors.black,),
                                  ),
                                  const Text("Profile",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 16),),
                                ],),
                            ),
                            onTap: (){
                              // Navigator.pushNamed(
                              //   context,
                              //   'update_prof',
                              //   arguments: {
                              //     'email': widget.email,
                              //   },
                              // );
                            },
                          ),
                        ),
                      ],),
                  ],),
              )
            ],),
        ),
      ),
    );
  }
}
