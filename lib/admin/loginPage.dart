import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rest_ez_app/screens/welcome.dart';
// import 'package:rest_ez_app/admin/signup.dart';
import '../constant/imageString.dart';
import 'home.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController login_email = TextEditingController();
  final TextEditingController login_pswd = TextEditingController();


  @override

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();

      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          // brightness:Brightness.light,

          backgroundColor: Colors.white,
          leading: IconButton(
              onPressed: (){
                // Navigator.pop(context);
                Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=>WelcomePage()));

              },
              icon: const Icon(
                Icons.arrow_back_ios,
                size:20,
                color: Colors.black,)
          ),
        ),
        body: SingleChildScrollView(child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              children: [
                const SizedBox(height: 20,),

                const Text("Login",
                  style: TextStyle(fontWeight: FontWeight.bold,fontSize: 33),
                ),
                const SizedBox(height:8,),
                Text("Login to your Admin account",
                  style: TextStyle(fontSize: 16, color: Colors.grey[800],),
                ),
              ],
            ),
            Padding(padding:const EdgeInsets.symmetric(horizontal: 40,vertical: 10),
              child: Column(
                children: [
                  const SizedBox(height:8,),
                  Column(
                    crossAxisAlignment:CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Email",
                        style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.black87),
                      ),
                      const SizedBox(height:5),
                      TextField(
                        controller: login_email,
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
                      SizedBox(height:5),
                      PasswordTextField(controller: login_pswd),
                      //SizedBox(height:10),
                      TextButton(
                        onPressed: () {
                          _showForgotPasswordDialog(context);
                        },
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                      ),

                    ],
                  ),
                ],
              ),
            ),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 40,vertical: 5),
              child: Container(
                padding: const EdgeInsets.only(left: 3),

                child: MaterialButton(
                  minWidth:MediaQuery.of(context).size.width/2,
                  height: 50,
                  onPressed:() async {
                    if (login_email.text.isEmpty) {
                      _showErrorDialog(context, "Please enter your Email to login.");
                    } else if (login_pswd.text.isEmpty) {
                      _showErrorDialog(context, "Please enter your Password to Login.");
                    }else{
                      try {
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                          email: login_email.text,
                          password: login_pswd.text,
                        ).then((value) {
                          Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=>AdminPage(email: login_email.text,)));

                        });
                      }
                      catch(error){
                        print("Error caught: ${error.toString()}");

                        if (error is FirebaseAuthException) {
                          String errorMessage = 'An error occurred during sign-in.';

                          switch (error.code) {
                            case 'invalid-email':
                              errorMessage = 'Invalid email address. Please enter a valid email.';
                              break;
                            case 'user-not-found':
                              errorMessage = 'User not found. Please check your email and try again.';
                              break;
                            case 'wrong-password':
                              errorMessage = 'Incorrect password. Please try again.';
                              break;
                            case 'user-disabled':
                              errorMessage = 'Your account has been disabled. Please contact support.';
                              break;
                            case 'too-many-requests':
                              errorMessage = 'Too many login attempts. Please try again later.';
                              break;
                            case 'email-already-in-use':
                              errorMessage = 'Email address is already in use. Please use a different email.';
                              break;
                            case 'weak-password':
                              errorMessage = 'Weak password. Please use a stronger password.';
                              break;
                            case 'network-request-failed':
                              errorMessage = 'Poor Internet connection.Try using better connection.';
                              break;
                            case 'invalid-credential':
                              errorMessage = 'Invalid password. Please enter a valid password.';
                              break;

                            default:
                              errorMessage = 'An error occurred during sign-in.';
                              break;
                          }

                          if (error.code == 'user-not-found') {
                            errorMessage = 'User not found. Please check your email and try again.';
                          }
                          print('Firebase Authentication Error: ${error.code} - ${error.message}');

                          _showErrorDialog(context, errorMessage);
                        } else {
                          print('Non-Firebase Exception: $error');
                          _showErrorDialog(context, 'An unexpected error occurred.');
                        }
                      }
                    }
                  },
                  color: Colors.indigo[600],
                  shape: RoundedRectangleBorder(
                      side: const BorderSide(
                          color:Colors.black
                      ),
                      borderRadius: BorderRadius.circular(50)
                  ),
                  child: const Text("LOGIN",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),),
                ),

              ),),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //
            //     const Text("Don't have an account? ",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 15),),
            //     //Text("Sign up",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 18),),
            //     TextButton(
            //       onPressed: (){
            //         Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=>SignupPage()));//SIGNUP PAGE NAVIGATE
            //
            //       },
            //       child: const Text("Sign up",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 18),
            //       ),
            //     )
            //   ],
            // ),
            Container(
              padding: EdgeInsets.only(top: 80),
              height: 200,
              decoration: const BoxDecoration(
                image: DecorationImage(image: AssetImage(login_pg),
                  fit: BoxFit.fitHeight,),
              ),
            ),
          ],
        )),
      ),
    );

  }
  void _showForgotPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Forgot Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('Enter your email to receive a password reset link:'),
              const SizedBox(height: 10),
              TextField(
                controller: TextEditingController(),
                decoration: const InputDecoration(
                  hintText: 'Email',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Reset Password'),
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(
                    email: login_email.text,
                  );
                  _showSuccessDialog(context, 'Password reset instructions sent to ${login_email.text}');
                  Navigator.of(context).pop();
                }
                catch (error) {
                  print("Error sending reset instructions: ${error.toString()}");
                  _showErrorDialog(context, 'Error sending reset instructions: ${error.toString()}');
                }
              },
            ),
          ],
        );
      },
    );
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
                Navigator.of(context).pop();// Close the dialog
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) =>HomePage(pemail: login_email.text,)),
                // );
              },
            ),
          ],
        );
      },
    );
  }
}

//WE WILL BE CREATING WIDGET FOR password
class PasswordTextField extends StatefulWidget {
  final TextEditingController controller;

  PasswordTextField({required this.controller});

  @override
  _PasswordTextFieldState createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _isObscured = true; // Initially, the password is obscured

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
        prefixIcon: const Icon(
          Icons.password,
          color: Color(0xFFBDBDBD),
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
