import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rest_ez_app/user/MakeSuggestion.dart';

import '../constant/imageString.dart';
import 'homepage.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email= TextEditingController();
  final TextEditingController _no_rev= TextEditingController();
  final TextEditingController _no_sug= TextEditingController();
  final TextEditingController _no_rep= TextEditingController();
  DocumentSnapshot<Map<String, dynamic>>? userDoc;

  bool isEditing = false;
  Future<DocumentSnapshot<Map<String, dynamic>>?> fetchUserByEmail(String email) async {
    try {
      // Query userEmails collection to get userId
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('userEmails')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String userId = querySnapshot.docs.first.get('userId');

        // Fetch user document using userId
        DocumentSnapshot<Map<String, dynamic>> userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        return userSnapshot;
      //   DocumentSnapshot<Map<String, dynamic>>? userDoc = await fetchUserByEmail('hari@gmail.com');
      } else {
        // No user found with the provided email
        return null;
      }
    } catch (e) {
      // Handle errors
      print("Error fetching user by email: $e");
      return null;
    }
  }
  Future<void> fetchUserData() async {
    // Get the user's email from route arguments or wherever it's stored
    final String userEmail = "hari@gmail.com"; // Replace with actual user email or fetch it from arguments

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .where("email", isEqualTo: userEmail)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          // Get the user data from the first document in the snapshot
          Map<String, dynamic> userData = snapshot.docs.first.data();

          // Update text controllers with user data
          _name.text = userData["name"] ?? "";
          _email.text = userData["email"] ?? "";
          _no_rev.text=(userData['no_of_reviews'] ?? 0).toString();
          _no_rep.text=(userData['no_of_reports'] ?? 0).toString();
          _no_sug.text=(userData['no_of_suggestion'] ?? 0).toString();
          print(userData['name']);

        });
      } else {
        // Handle case when no user data found
        print("No user data found for email: $userEmail");
      }
    } catch (e) {
      // Handle errors
      print("Error fetching user data: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }


  @override
  Widget build(BuildContext context) {
    Widget buttons;
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar:AppBar(
          backgroundColor:Colors.white,
          iconTheme: IconThemeData(
            color: Colors.blue[900],
          ),
          title:Center(
            child: RichText(
              text: TextSpan(
                  style: TextStyle(fontSize: 28,
                      // fontFamily: 'El Messiri',
                      fontWeight: FontWeight.bold),
                  children: <TextSpan>[
                    TextSpan(text: 'Rest', style: TextStyle(color: Colors.black)),
                    TextSpan(
                        text: 'Ez', style: TextStyle(color: Colors.blue[900]))
                  ]
              ),
            ),
          ),
          elevation: 24.0,
          actions: <Widget>[IconButton(
            icon: Icon(Icons.edit,size: 30,color: Colors.black,),
            onPressed: () async{
              DocumentSnapshot<Map<String, dynamic>>? userDoc = await fetchUserByEmail('hari@gmail.com');
              // Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateProfile()),);
              // loadProfileImage();
              print(userDoc);
            },
          ),
          ],
        ),
        body:SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Column(

              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 22,),
                Center(
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: (){
                          // loadProfileImage();
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.indigo,
                          radius: 50,
                          child: Text(
                            Utils.getInitials("Hari Kumar"),
                            style: TextStyle(
                                fontSize: 40, color: Colors.white),
                          ),
                        ),
                      ),
                      Positioned(
                        child: IconButton(
                          onPressed:() async{
                            print("pressed");
                            // _onImagePickerButtonPressed();
                            // loadProfileImage();
                          },
                          icon: Icon(Icons.add_a_photo),
                          iconSize: 30,
                          color: Colors.black,
                        ),
                        bottom: -10,
                        left: 60,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10,),
                SizedBox(
                  child: Container(
                    margin:EdgeInsets.symmetric(horizontal: 20,vertical: 10) ,
                    padding: EdgeInsets.symmetric(horizontal: 20,vertical: 18),
                   decoration: BoxDecoration(
                     color: Colors.indigo[100],
                     borderRadius: BorderRadius.circular(20),
                     border: Border.all(
                       width: 8,
                       color: Color.fromRGBO(232, 234, 246, 1)
                     ),
                   ),
                    child: Column(
                      children: [

                        Container(

                            // padding: EdgeInsets.only(left: 15),
                            child: buildTextField("Name :",_name)),
                        SizedBox(height: 15,),
                        //spec
                        Container(
                            // padding: EdgeInsets.only(left: 15),

                            child: buildTextField("Email :",_email)),
                        SizedBox(height: 15,),

                        Container(

                            // padding: EdgeInsets.only(left: 15),
                            child: buildTextField("No. of Reviews :",_no_rev)),
                        // SizedBox(height: 15,),

                        // buttons = isEditing ? Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                        //   children: [
                        //     //SAVE BUUTTON
                        //     MaterialButton(
                        //       minWidth: MediaQuery.of(context).size.width/3,
                        //       height: 50,
                        //       onPressed:(){
                        //         // onSaveButtonClick();
                        //       },
                        //       color: Colors.blue[600],
                        //       shape: RoundedRectangleBorder(
                        //           side: const BorderSide(
                        //               color:Colors.black
                        //           ),
                        //           borderRadius: BorderRadius.circular(50)
                        //       ),
                        //       child: const Text("Save",
                        //         style: TextStyle(
                        //           color: Colors.white,
                        //           fontSize: 25,
                        //           fontWeight: FontWeight.bold,
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // )
                        //     :
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                        //   children: [
                        //     // Edit button
                        //     MaterialButton(
                        //       minWidth:MediaQuery.of(context).size.width/3,
                        //       height: 50,
                        //       onPressed:(){
                        //         // onEditButtonClick();
                        //       },
                        //       color: Colors.blue[800],
                        //       shape: RoundedRectangleBorder(
                        //           side: const BorderSide(
                        //               color:Colors.black
                        //           ),
                        //           borderRadius: BorderRadius.circular(50)
                        //       ),
                        //       child: const Text("Edit",
                        //         style: TextStyle(
                        //           color: Colors.white,
                        //           fontSize: 25,
                        //           fontWeight: FontWeight.bold,
                        //         ),),
                        //     ),
                        //   ],
                        // ),
                        SizedBox(height: 15,),
                        Container(
                            // padding: EdgeInsets.only(left: 15),

                            child: buildTextField("No. of Reports :",_no_rep)),
                        SizedBox(height: 15,),
                        Container(
                            // padding: EdgeInsets.only(left: 15),

                            child: buildTextField("No. of Suggestion :",_no_sug)),

                      ],
                    ),
                  ),

                ),
                SizedBox(height: 25,),
                Container(
                  width: MediaQuery.of(context).size.width/1.4,
                  child: MaterialButton(
                    // minWidth:MediaQuery.of(context).size.width/,
                    height: 48,
                    onPressed:(){
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => MakeSuggestion()));

                    },
                    color: Colors.indigo[400],
                    shape: RoundedRectangleBorder(
                        side: const BorderSide(
                            color:Color.fromRGBO(63, 81, 181, 1),
                        ),
                        borderRadius: BorderRadius.circular(50)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.create,color: Colors.white,),
                        Padding(
                          padding: const EdgeInsets.only(left: 18.0),
                          child: Text("Suggest Restroom",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),),
                        ),
                      ],
                    ),
                  ),
                ),


                SizedBox(height: 15,),
                Container(
                  width: MediaQuery.of(context).size.width/1.4,
                  child: MaterialButton(
                    minWidth:MediaQuery.of(context).size.width/3,
                    height: 48,
                    onPressed:(){
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Logout Confirmation"),
                            content: Text("Are you sure you want to log out?"),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  Navigator.pushReplacement( context,
                                    MaterialPageRoute(builder: (context) => UserPage(name: 'Hari Kumar',)),
                                  );
                                  await FirebaseAuth.instance.signOut();
                                },
                                child: Text("Yes"),
                              ),
                              TextButton(
                                onPressed: () {
                                  // User canceled, simply close the dialog
                                  Navigator.of(context).pop();
                                },
                                child: Text("No"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        side: const BorderSide(
                            color:Colors.indigo,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(50)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout,color: Colors.indigo,),
                        Padding(
                          padding: const EdgeInsets.only(left: 18.0),
                          child: Text("LogOut",
                            style: TextStyle(
                              color: Colors.indigo[700],
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 35,),
              ],
            ),
          ),
        ),
        bottomNavigationBar: CustomBottomNavigationBar(
          index: 1,
        ),
      ),
    );
  }
  Widget buildTextField(String label,TextEditingController controller) {
    // final textStyle = isEditing ? enabledTextStyle : disabledTextStyle;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500,color: Colors.black87),
        ),
        const SizedBox(width:5),
        Flexible(
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10)
            ),
            child: TextField(
              style: TextStyle(
                // backgroundColor: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              obscureText: false,
              controller:controller,
              enabled: isEditing,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 0,horizontal: 10),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFFBDBDBD),
                  ),
                ),
                border:OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFFBDBDBD),
                  ),
                ),
              ),
            ),
          ),
        ),
        // SizedBox(height:10),
      ],
    );
  }
}


class Utils {
  static String getInitials(String fullName) {
    List<String> names = fullName.split(' ');

    if (names.isEmpty) {
      return 'Invalid full name';
    }

    String firstName = names.first;
    String lastName = names.length > 1 ? names.last : '';

    String initials = firstName[0];

    if (lastName.isNotEmpty) {
      initials += lastName[0];
    } else {
      initials += firstName.length > 1 ? firstName[1] : '';
    }

    return initials.toUpperCase();
  }
}
