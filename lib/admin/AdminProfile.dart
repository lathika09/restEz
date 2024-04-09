import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import '../constant/imageString.dart';



class AdminProfile extends StatefulWidget {
  const AdminProfile({Key? key, required this.admin_email}) : super(key: key);
  final String admin_email;
  @override
  State<AdminProfile> createState() => _AdminProfileState();
}

class _AdminProfileState extends State<AdminProfile> {
  String? _profileImageUrl;


  final TextEditingController _name = TextEditingController();
  final TextEditingController _email= TextEditingController();
  final TextEditingController _add= TextEditingController();
  final TextEditingController _phone= TextEditingController();

  bool isEditing = false;
  Map<String, dynamic> adminData = {};

  Future<void> fetchAdminData() async {


    try {
      final snapshot = await FirebaseFirestore.instance.collection("admins").where("email", isEqualTo: widget.admin_email).get();
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          adminData = snapshot.docs.first.data();//as Map<String, dynamic>


          print(adminData);

          _name.text = adminData["name"] ?? "";
          _email.text = adminData["email"] ?? "";
          _add.text = adminData["location"] ?? "";
          _phone.text = adminData["phone"] ?? "";



        });
      }
    } catch (e) {
      log("Error fetching doctor data: $e");
    }
  }


  Future<void> uploadImageToFirebaseStorage(File imageFile, String Email) async {
    try {
      final Reference storageReference =
      FirebaseStorage.instance.ref().child('prof_images/$Email.jpg');

      final UploadTask uploadTask = storageReference.putFile(imageFile);

      await uploadTask.whenComplete(() async {
        loadProfileImage(Email);
        final imageUrl = await storageReference.getDownloadURL();
        log('Image uploaded to Firebase Storage: $imageUrl');

        final querySnap =await FirebaseFirestore.instance.collection('admins').where("email", isEqualTo: Email).get();
        // await FirebaseFirestore.instance.collection('doctor').doc(Email).update({
        //   'prof_image': imageUrl,
        // });

        if (querySnap.docs.isNotEmpty) {
          final doctorDocument = querySnap.docs.first;
          await doctorDocument.reference.update({
            'prof_img': imageUrl,
          });
        }
        else {
          log("No document found with email: $Email");
        }

        log('Image URL saved in Firestore.');
      });
    } catch (e) {
      log('Error uploading image to Firebase Storage: $e');
    }
  }
  Future<void> _onImagePickerButtonPressed(String adminEmail) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);

      uploadImageToFirebaseStorage(imageFile, adminEmail);
      // if (adminEmail != null) {
      //   uploadImageToFirebaseStorage(imageFile, adminEmail);
      // }

    }
  }

  Future<void> loadProfileImage(String adminEmail) async {
    final imageUrl = await getProfileImageUrl(adminEmail);
    if (imageUrl != null) {
      setState(() {
        _profileImageUrl = imageUrl;
      });
    }
  }


  @override
  void initState() {
    super.initState();
    loadProfileImage(widget.admin_email);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    fetchAdminData();
    loadProfileImage(widget.admin_email);

  }
  Future<String?> getProfileImageUrl(String userEmail) async {
    try {
      final Reference storageReference =
      FirebaseStorage.instance.ref().child('prof_images/$userEmail.jpg');

      final String downloadURL = await storageReference.getDownloadURL();
      return downloadURL;
    } catch (e) {
      log('Error getting profile image URL: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    
    Widget buttons;

    return Scaffold(
        appBar:AppBar(
          backgroundColor:Colors.indigo.shade700,
          iconTheme:const IconThemeData(
            color: Colors.white,
          ),
          title:const Center(
            child: Text(appname,
              style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
          elevation: 24.0,
          actions: <Widget>[IconButton(
            icon: const Icon(Icons.refresh,size: 30,color: Colors.white,),
            onPressed: () {
              // Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateProfile()),);
              loadProfileImage(widget.admin_email);
            },
          ),
          ],
        ),
        body:Column(
          children: [
            Expanded(
              child: Container(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 22,),
                      Center(
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: (){
                                loadProfileImage(widget.admin_email);
                              },
                              child: CircleAvatar(
                                radius: 60,
                                backgroundImage: _profileImageUrl != null
                                    ? NetworkImage(_profileImageUrl!)
                                    :const NetworkImage("https://www.pngitem.com/pimgs/m/421-4212266_transparent-default-avatar-png-default-avatar-images-png.png"),
                
                              ),
                            ),
                            Positioned(
                              bottom: -1,
                              left: 80,
                              child: IconButton(
                                onPressed:() async{
                                  log("pressed");
                                  _onImagePickerButtonPressed(widget.admin_email);
                                  // loadProfileImage();
                                },
                                icon: const Icon(Icons.add_a_photo),
                                iconSize: 30,
                                color: Colors.black,
                              ),

                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20,),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 30,vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              width: 10,
                              color: const Color.fromRGBO(232, 234, 246, 1),
                          )
                        ),
                        child: Column(
                          children: [
                
                            buildTextField("Name :",_name),
                            const SizedBox(height: 15,),
                            //email
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Text(
                                  "Email :",
                                  style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.black87),
                                ),
                                const SizedBox(width:10),
                                Flexible(
                                  child: TextField(
                                    style:const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black54,
                                    ),
                                    obscureText: false,
                                    controller:_email,
                                    enabled: false,
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
                                // SizedBox(height:10),
                              ],
                            ),
                            // buildTextField("Email :",_email),
                            const SizedBox(height: 20,),
                
                            //phone
                            buildTextField("Phone No. :",_phone),
                            const SizedBox(height: 20,),
                
                            //location
                            buildTextField("Address :",_add),

                            const SizedBox(height: 20,),
                
                
                          ],
                        ),
                      ),
                      const SizedBox(height: 30,),

                    ],
                  ),
                ),
              ),
            ),
            buttons = isEditing ? Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color:Colors.white, // Colors.indigo.shade700,
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.withOpacity(0.2),
                    spreadRadius: 10,
                    blurRadius: 20,
                    offset: const Offset(10, 0),
                  ),
                ],
              ),
              height:MediaQuery.of(context).size.height/10 ,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  //SAVE BUUTTON
                  MaterialButton(
                    minWidth: MediaQuery.of(context).size.width/3,
                    height: 50,
                    onPressed:(){
                      onSaveButtonClick();
                    },
                    color:Colors.indigo.shade700,
                    shape: RoundedRectangleBorder(
                        side: const BorderSide(
                            color:Colors.indigo,
                            width: 2
                        ),
                        borderRadius: BorderRadius.circular(50)
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: const Text("Save",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            )
                : Container(
              width: double.infinity,
              //Color.fromRGBO(232, 234, 246, 1),
              height:MediaQuery.of(context).size.height/10 ,
              decoration: BoxDecoration(
                color:Colors.indigo.shade700,
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.withOpacity(0.2),
                    spreadRadius: 10,
                    blurRadius: 20,
                    offset: const Offset(10, 0),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Edit button
                  MaterialButton(
                    minWidth:MediaQuery.of(context).size.width/3,
                    height: 50,
                    onPressed:(){
                      onEditButtonClick();
                    },

                    color:const Color.fromRGBO(232, 234, 246, 1),
                    shape: RoundedRectangleBorder(
                        side: const BorderSide(
                            color:Colors.white,
                            width: 2
                        ),
                        borderRadius: BorderRadius.circular(50)
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: const Text("Edit",
                      style: TextStyle(
                        color: Colors.indigo,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),),
                  ),
                ],
              ),
            ),
          ],
        )
    );
  }
  void onEditButtonClick() {
    setState(() {
      isEditing = true; // Enable editing mode
    });
  }

  void onSaveButtonClick() async {
    final updatedData = {
      "name": _name.text,
      "email": _email.text,
      "phone": _phone.text,
      "location": _add.text,

    };

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection("admins")
          .where("email", isEqualTo: widget.admin_email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final adminDoc = querySnapshot.docs.first;

        await adminDoc.reference.update(updatedData);

        setState(() {
          isEditing = false;
        });
      } else {
        log("No document found with email: ${widget.admin_email}");
      }
    } catch (e) {
      log("Error updating document: $e");
    }
  }
  final enabledTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.black,
  );
  final disabledTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.black54,
  );


  Widget buildTextField(String label, TextEditingController controller) {
    final textStyle = isEditing ? enabledTextStyle : disabledTextStyle;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.black87),
        ),
        const SizedBox(width:5),
        Flexible(
          child: TextField(
            style: textStyle,
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
        // SizedBox(height:10),
      ],
    );
  }
}

