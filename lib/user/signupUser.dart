import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/get_utils/get_utils.dart';
import '../splashScreens/splash_controller.dart';
import 'LoginUser.dart';


class SignupPageUser extends StatelessWidget {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _pswd = TextEditingController();
  final TextEditingController _conpswd = TextEditingController();

  bool validateEmail(String email) {
    return GetUtils.isEmail(email);
  }

  bool validatePhoneNumber(String phoneNumber) {
    return GetUtils.isPhoneNumber(phoneNumber);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,

        // brightness:Brightness.light,
        backgroundColor:Colors.white,
        // title: const Text("Restez",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 26,color:Colors.white),),
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios,size: 25,color: Colors.black,),

        ),
      ),
      body: SingleChildScrollView(
        child:Container(

          // decoration: const BoxDecoration(
          //   image: DecorationImage(
          //     image: AssetImage(bg),
          //     fit: BoxFit.cover,
          //   ),
          // ),
          padding: const EdgeInsets.symmetric(horizontal: 40,vertical:0),
          height: MediaQuery.of(context).size.height-60,
          width: double.infinity,
          child: Column(

            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text("Sign up",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30),),
              Padding(

                padding: const EdgeInsets.symmetric(vertical:10),
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment:CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Name",
                          style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.black87),
                        ),
                        const SizedBox(height:3),
                        TextField(
                          obscureText: false,
                          controller:_name,

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
                            prefixIcon: Icon(
                              Icons.person,
                              color: Color(0xFFBDBDBD),
                            ),
                          ),
                        ),
                        const SizedBox(height:10),
                      ],
                    ),
                    Column(
                      crossAxisAlignment:CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Email",
                          style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.black87),
                        ),
                        const SizedBox(height:3),
                        TextField(
                          obscureText: false,

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
                            prefixIcon: Icon(
                              Icons.email,
                              color: Color(0xFFBDBDBD),
                            ),
                          ),
                          controller:_email,
                        ),
                        const SizedBox(height:10),
                      ],
                    ),
                    Column(
                      crossAxisAlignment:CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Password",
                          style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.black87),
                        ),
                        const SizedBox(height:3),
                        PasswordTextField(controller: _pswd),
                        const SizedBox(height:10),
                      ],
                    ),
                    Column(
                      crossAxisAlignment:CrossAxisAlignment.start,
                      children: [
                        const Text(
                          " Confirm Password",
                          style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.black87),
                        ),
                        const SizedBox(height:3),
                        PasswordTextField(controller: _conpswd),
                        const SizedBox(height:10),
                      ],
                    ),

                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top:5,left: 3),
                child: MaterialButton(
                  minWidth:MediaQuery.of(context).size.width/2,
                  height: 50,
                  onPressed:()async{
                    if (!SplashScreenController.find.animate.value) {

                      FirebaseAuth.instance.createUserWithEmailAndPassword(email: _email.text, password: _pswd.text).then((value) {
                        print("account created");
                        addUserToFirestore(_name.text, _email.text,_pswd.text);//ADD TO FIREBASE
                        Navigator.push(context,MaterialPageRoute(builder: (context)=>UserLoginPage()));
                      }).onError((error, stackTrace) {
                        print("error ${error.toString()}");
                      });
                    }

                    if (_name.text.isEmpty) {
                      _showErrorDialog(context, "Please enter your name.");
                    } else if (!validateEmail(_email.text)) {
                      _showErrorDialog(context, "Invalid email format.");
                    } else if (_pswd.text.isEmpty || _conpswd.text.isEmpty) {
                      _showErrorDialog(context, "Please enter a password and confirm it.");
                    } else if (_pswd.text != _conpswd.text) {
                      _showErrorDialog(context, "Passwords do not match.");
                    } else {
                      try {
                        await FirebaseAuth.instance.createUserWithEmailAndPassword(
                          email: _email.text,
                          password: _pswd.text,
                        );
                        print("Account created");
                        addUserToFirestore(_name.text, _email.text,_pswd.text);//ADD TO FIREBASE
                        _showSuccessDialog(context, "Account created successfully!");

                      } catch (error) {
                        print("Error: ${error.toString()}");

                        String errorMessage = "Error creating account: ${error.toString()}";

                        if (error is FirebaseAuthException) {
                          if (error.code == "email-already-in-use") {
                            errorMessage = "This email is already registered.";
                          } else {
                            errorMessage = "Error: ${error.code} - ${error.message}";
                          }
                        }

                        _showErrorDialog(context, errorMessage);
                      }
                    }


                  },
                  color: Colors.blue[600],
                  shape: RoundedRectangleBorder(
                      side: const BorderSide(
                          color:Colors.black
                      ),
                      borderRadius: BorderRadius.circular(50)
                  ),
                  child: const Text("Create Account",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  const Text("Alreday have an account? ",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 15),),
                  //Text("Sign up",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 18),),
                  TextButton(
                    onPressed: (){
                      Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=>  UserLoginPage()));
                    },
                    child: const Text("Login",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 18),
                    ),
                  )
                ],
              ),


            ],
          ),
        ),
      ),
    );
  }


  void addUserToFirestore(String name, String email,String pass) async {
    CollectionReference admins = FirebaseFirestore.instance.collection('users');

    String documentId = email;
    DocumentReference docRef = admins.doc(documentId);

    await docRef.set({
      'name': name,
      'email': email,
      'no_of_reviews': 0,
      'no_of_reports': 0,
      'prof_img': "",
      "no_of_suggestion": 0,
      'password': pass,
    });
    //

    print('Document added with ID: ${docRef}');
  }


  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => UserLoginPage()),
                );
              },
            ),
          ],
        );
      },
    );
  }

}


class PasswordTextField extends StatefulWidget {
  final TextEditingController controller;

  PasswordTextField({required this.controller});

  @override
  _PasswordTextFieldState createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: _isObscured,
      controller: widget.controller,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFFBDBDBD),
          ),
        ),
        border: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFFBDBDBD),
          ),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isObscured ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _isObscured = !_isObscured;
            });
          },
        ),
      ),
    );
  }
}