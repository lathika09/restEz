import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rest_ez_app/user/shared.dart';
import 'homepage.dart';



class UserProfile extends StatefulWidget {
  const UserProfile({super.key, required this.uemail, required this.uname});
  final String uemail;
  final String uname;

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

  Future<void> editUserData(String uemail,String newName) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uemail)
          .set({"name": newName}, SetOptions(merge: true));
      print("edkted sucess");
    } catch (e) {
      print("Error saving user data: $e");
    }
  }
  Future<DocumentSnapshot<Map<String, dynamic>>?> fetchUserByEmail(String email) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String userId = querySnapshot.docs.first.get('userId');

        DocumentSnapshot<Map<String, dynamic>> userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        return userSnapshot;
      //   DocumentSnapshot<Map<String, dynamic>>? userDoc = await fetchUserByEmail('hari@gmail.com');
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching user by email: $e");
      return null;
    }
  }
  Future<void> fetchUserData(String userEmail) async {
    // final String userEmail = "hari@gmail.com";
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .where("email", isEqualTo: userEmail)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          Map<String, dynamic> userData = snapshot.docs.first.data();

          // _name.text = userData["name"] ?? "";
          _email.text = userData["email"] ?? "";
          _no_rev.text=(userData['no_of_reviews'] ?? 0).toString();
          _no_rep.text=(userData['no_of_reports'] ?? 0).toString();
          _no_sug.text=(userData['no_of_suggestion'] ?? 0).toString();
          print(userData['name']);

        });
      } else {
        print("No user data found for email: $userEmail");
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }
  String? _profileImageUrl;
  @override
  void initState() {
    super.initState();
    fetchUserData(widget.uemail);
    loadProfileImage(widget.uemail);
    print(_profileImageUrl);

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchUserData(widget.uemail);
    loadProfileImage(widget.uemail);
    print(_profileImageUrl);

  }
  Future<List<DocumentSnapshot>> getNewRestroomsForAdmin(String adminEmail, String location) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('newRestroom')
          .where('sendTo', arrayContains: '$adminEmail : $location')
          .get();

      return querySnapshot.docs;
    } catch (error) {
      print('Error fetching new restrooms: $error');
      return [];
    }
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
          backgroundColor:Colors.indigo[700],
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          title:RichText(
            text: TextSpan(
                style: const TextStyle(fontSize: 29,
                    // fontFamily: 'El Messiri',
                    fontWeight: FontWeight.bold),
                children: <TextSpan>[
                  const TextSpan(text: 'Rest', style: TextStyle(color: Colors.white)),
                  TextSpan(
                      text: 'Ez', style: TextStyle(color: Colors.tealAccent[100]))
                ]
            ),
          ),
          elevation: 24.0,
          actions: <Widget>[IconButton(
            icon: const Icon(Icons.edit,size: 30,color: Colors.white,),
            onPressed: () async{
              setState(() {
                isEditing = !isEditing;
              });
            },
          ),
            if (isEditing)
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: () {
                  setState(() {
                    isEditing = false;
                  });
                  if(_name.text.isNotEmpty){
                    editUserData(widget.uemail,_name.text);
                  }
                },
              ),

          ],
        ),
        body:SingleChildScrollView(
          child: Container(
            // color: Colors.white,
            color: Colors.indigo[100],
            child: Column(

              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 22,),
                Center(
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: (){
                          loadProfileImage(widget.uemail);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 4.0, // Adjust the width as needed
                            ),
                          ),
                          child: CircleAvatar(
                            // backgroundColor: Colors.indigo,
                            backgroundColor: Colors.teal[200],
                            radius: 50,

                            backgroundImage: _profileImageUrl != null
                                ? NetworkImage(_profileImageUrl!)
                                : null,
                            child: _profileImageUrl == null
                                ? Text(
                              Utils.getInitials(widget.uname),
                              style: TextStyle(fontSize: 40, color: Colors.black),
                            )
                                : null,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -10,
                        left: 60,
                        child: IconButton(
                          onPressed:() async{
                            print("pressed");
                            _onImagePickerButtonPressed(widget.uemail);
                            loadProfileImage(widget.uemail);
                          },
                          icon: Icon(Icons.add_a_photo),
                          iconSize: 30,
                          color: Colors.black,
                        ),

                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10,),
                SizedBox(
                  child: Container(
                    margin:const EdgeInsets.symmetric(horizontal: 20,vertical: 10) ,
                    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 18),
                   decoration: BoxDecoration(
                     color: Colors.white,
                     // color: Colors.indigo[100],
                     borderRadius: BorderRadius.circular(20),
                     border: Border.all(
                       width: 10,
                       color: Color.fromRGBO(232, 234, 246, 1)
                     ),
                   ),
                    child: Column(
                      children: [
                        Container(

                          // padding: EdgeInsets.only(left: 15),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Name :",
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Colors.black87),
                                  ),
                                  const SizedBox(width: 5),

                                  StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                                      stream: FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(widget.uemail)
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return Text(
                                            _name.text,
                                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black),
                                          );
                                        } else if (snapshot.hasError) {
                                          return Text('Error: ${snapshot.error}');
                                        } else if (!snapshot.hasData || !snapshot.data!.exists) {
                                          return const Text('Document not found');
                                        } else {
                                          var userData = snapshot.data!.data()!;
                                          return Flexible(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: isEditing
                                                  ? TextFormField(
                                                controller:_name,
                                                validator: (value) {
                                                  if (value == null || value.isEmpty) {
                                                    return 'Please enter valid name';
                                                  }
                                                  return null;
                                                },
                                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black),
                                                // initialValue:userData['name'],
                                                maxLines: null,
                                                keyboardType: TextInputType.multiline,
                                                decoration: const InputDecoration(
                                                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(color: Color(0xFFBDBDBD)),
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderSide: BorderSide(color: Color(0xFFBDBDBD)),
                                                  ),
                                                ),
                                                // onEditingComplete: () {
                                                //   // Update the text controller with the new value
                                                //   String newValue = _name.text;
                                                //   editUserData(widget.uemail, newValue);
                                                //
                                                //   // Clear focus when editing is complete
                                                //   FocusScope.of(context).unfocus();
                                                // },
                                                onSaved: (newValue) {
                                                  _name.text = newValue!;
                                                  editUserData(widget.uemail, newValue);

                                                },

                                              )
                                                  : Text(
                                                userData['name'],
                                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black),
                                              ),
                                            ),
                                          );
                                        }})
                                ])
                          // buildTextField("Name :",_name)
                        ),
                        const SizedBox(height: 15,),
                        //spec
                        Container(
                            // padding: EdgeInsets.only(left: 15),

                            child: buildTextField("Email :",_email)),
                        const SizedBox(height: 15,),



                        Container(

                            // padding: EdgeInsets.only(left: 15),
                            child: buildTextField("No. of Reviews :",_no_rev)),

                        const SizedBox(height: 15,),
                        Container(
                            // padding: EdgeInsets.only(left: 15),

                            child: buildTextField("No. of Reports :",_no_rep)),
                        const SizedBox(height: 15,),
                        Container(
                            // padding: EdgeInsets.only(left: 15),

                            child: buildTextField("No. of Suggestion :",_no_sug)),

                        const SizedBox(height: 25,),
                        Container(
                          // padding: EdgeInsets.symmetric(horizontal: 10),
                          // width: MediaQuery.of(context).size.width,
                          child: MaterialButton(
                            // minWidth:MediaQuery.of(context).size.width/,
                            height: 48,
                            onPressed:(){
                              giveSuggestionModalSheet(context);

                            },
                            color: Colors.indigo[600],
                            shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                  color:Color.fromRGBO(63, 81, 181, 1),
                                ),
                                borderRadius: BorderRadius.circular(50)
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.create,color: Colors.white,),
                                Padding(
                                  padding: EdgeInsets.only(left: 18.0),
                                  child: Text("Suggest Restroom",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),),
                                ),
                              ],
                            ),
                          ),
                        ),


                        const SizedBox(height: 5,),

                      ],
                    ),
                  ),

                ),
                const SizedBox(height: 10,),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  // width: MediaQuery.of(context).size.width,
                  child: MaterialButton(
                    // minWidth:MediaQuery.of(context).size.width/3,
                    height: 48,
                    onPressed:(){
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
                                  await FirebaseAuth.instance.signOut();
                                  SharedPreference.saveUserLoggedInStatus(false);

                                  Navigator.pushReplacement( context,
                                    MaterialPageRoute(builder: (context) => UserPage()),
                                  );

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
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        side: const BorderSide(
                          color:Color.fromRGBO(43, 67, 218, 1),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(50)
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout,color: Colors.indigo,),
                        Padding(
                          padding: const EdgeInsets.only(left: 18.0),
                          child: Text("LogOut",
                            style: TextStyle(
                              color: Colors.indigo,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30,),


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
          style: const TextStyle(fontSize: 15,fontWeight: FontWeight.w400,color: Colors.black87),
        ),
        const SizedBox(width:5),
        Flexible(
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10)
            ),
            child: TextField(
              style: const TextStyle(
                // backgroundColor: Colors.white,
                fontSize: 15,
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

  String location="";
  String address="";
  String selectedAdmin='';
  late bool isReq;

  Future<Position> determinePosition() async{
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled =await Geolocator.isLocationServiceEnabled();
    if(!serviceEnabled){
      await Geolocator.openLocationSettings();
      return Future.error("Location service are disabled");
    }
    permission=await Geolocator.checkPermission();
    if(permission==LocationPermission.denied){
      permission=await Geolocator.requestPermission();
      if(permission==LocationPermission.denied){
        return Future.error("Location permission are denied");

      }
    }
    if(permission==LocationPermission.deniedForever){
      return Future.error("Location Permission are permanently denie,we cannot request permission");

    }
    return await Geolocator.getCurrentPosition();

  }
  Future<void> GetAddressFromLatLong(Position position)async{
    List<Placemark> placemark=await placemarkFromCoordinates(position.latitude, position.longitude);
    print(placemark);
    Placemark place=placemark[0];
    String addr="";
    if(place.thoroughfare!="" && place.subLocality!=""){
      addr='${place.name}, ${place.subThoroughfare}, ${place.thoroughfare}, ${place.subLocality},  ${place.locality}, ${place.postalCode}'.trim();

    }
    else if(place.thoroughfare!=""){
      addr='${place.name}, ${place.subThoroughfare}, ${place.thoroughfare}, ${place.locality}, ${place.postalCode}'.trim();

    }
    else{
      addr='${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}'.trim();

    }
    address=addr;

  }

  Future<void> setSuggestionCount(String email) async {
     if (location.trim().isNotEmpty && address.trim().isNotEmpty && isReq){
       try {
         DocumentReference userRef =
         FirebaseFirestore.instance.collection('users').doc(email);

         await userRef.set({
           'no_of_suggestion': FieldValue.increment(1),
         }, SetOptions(merge: true));

         print('Suggestion count set successfully.');
       } catch (error) {
         print('Error setting suggestion count: $error');
       }
     }
     else {
       print("Location is Empty for setting no_of suggestuion in user");
     }

  }

  Future<void> storeNewRestroomData(Position position, String address, String nm,String admin) async {
    if (location.isNotEmpty && address.isNotEmpty && selectedAdmin.isNotEmpty) {
      GeoPoint geoPoint = GeoPoint(position.latitude, position.longitude);
      Timestamp timestamp = Timestamp.now();
      DocumentReference newRestroomRef = FirebaseFirestore.instance.collection('newRestroom').doc(address);

      DocumentSnapshot docSnapshot = await newRestroomRef.get();
      if (docSnapshot.exists) {
        Map<String, dynamic>? data = docSnapshot.data() as Map<String, dynamic>?;
        if (data != null) {
          List<dynamic>? suggestedBy = data['suggestedBy'];
          String adm=data['sendTo'];

          // && selectedAdmin==adm // //REASON TO REMOVE IS THAT MANY ADMIN WILL GET SAME SUGGEST
          if (suggestedBy != null && suggestedBy.contains(nm) ) {
            isReq=false;
            // User is already in the suggestedBy array, show a dialog
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Already suggested this location.'),
                  content: Text('You cannot suggest the same location again.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('OK'),
                    ),
                  ],
                );
              },
            );
            return;
          }
          isReq=true;
          // User is not in sugestedBy array, updat document
          await newRestroomRef.set({
            'location': geoPoint,
            'address': address,
            'status': 'Pending',
            'timestamp': timestamp,
            'no_of_suggestion': FieldValue.increment(1),
            'suggestedBy': FieldValue.arrayUnion([nm]),
            'sendTo':admin,
          }, SetOptions(merge: true));
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Successfully Sent'),
                content: Text("Successfully send suggestion about new restroom location"),
                actions: <Widget>[
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );

          print('New restroom data stored successfully.');
        }
      } else {
        isReq=true;
        // create a new document
        await newRestroomRef.set({
          'location': geoPoint,
          'address': address,
          'status': 'Pending',
          'timestamp': timestamp,
          'no_of_suggestion': 1,
          'suggestedBy': [nm],
          'sendTo':admin,
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Successfully Sent'),
              content: const Text("Successfully send suggestion about new restroom location"),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        print('New restroom data stored successfully.');
      }
    } else {
      print('Location is empty.');
    }
  }

  //DROPDOWN ADMIN
  Future<List<String>> getAllAdminEmails() async {
    List<String> adminEmails = [];

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('admins')
          .get();

      querySnapshot.docs.forEach((doc) {
        adminEmails.add('${doc['email']} : ${doc['location']}');
      });
    } catch (error) {
      print('Error fetching admin emails: $error');
    }

    return adminEmails;
  }

  void giveSuggestionModalSheet(BuildContext context){
    showModalBottomSheet(
      context: context,
      // useSafeArea: false,
      isScrollControlled: true,
      // enableDrag: false,
      builder: (BuildContext context){
        late List<String> _filterOptions;
        String? selectedFilter;

        return StatefulBuilder(builder: (BuildContext context, StateSetter setState){
          return Container(
            height: MediaQuery.of(context).size.height/1.38,//1.5 decrease then size increase
            // color: Color.fromRGBO(36, 21, 50, 0.94),
            child:Column(
              children: [
                SizedBox(height: 15,),
                Expanded(
                  child: Container(
                    // color: Colors.blue,
                    height: 330,
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 20,vertical: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Flexible(child: Text(
                          "Give Location of New Restroom ",
                          style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),softWrap: true,overflow: TextOverflow.visible,
                        )
                        ),
                        const SizedBox(height: 5,),
                        const Flexible(child: Text('Click on below \'GET LOCATION\' Botton to get your Current Location for getting Restroom location and address',
                          style: TextStyle(fontSize: 17,color: Colors.black87),softWrap: true,overflow: TextOverflow.visible,

                        )),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          // color: Colors.blue,
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.only(top: 20),

                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Flexible(flex:1,child: Container(
                                      width: double.infinity/4,
                                      child: Text("Location Position",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),))),
                                  Flexible(flex: 0,
                                      child: SizedBox(width: 10,)),

                                  Flexible(flex:3,child: Container(
                                    width: double.infinity/1.3,
                                    padding: EdgeInsets.symmetric(horizontal: 17,vertical: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.indigo[100],
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.black54,width: 1.0,

                                        )
                                      ),
                                      child: Text(
                                        // "Select button to get location djd kms nkdnknd nskndkmsk cncknd",
                                        location,
                                        style: const TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                                        softWrap: true,
                                        overflow: TextOverflow.visible,
                                      ),
                                  )),
                                ],
                              ),),
                              Container(
                                padding: const EdgeInsets.only(top: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Flexible(flex:1,child: Container(
                                        width: double.infinity/4,
                                        child: const Text("Address : ",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),))),
                                    const Flexible(
                                        flex: 0,
                                        child: SizedBox(width: 10,)),

                                    Flexible(flex:3,child: Container(
                                      width: double.infinity/1.3,
                                      padding: EdgeInsets.symmetric(horizontal: 17,vertical: 10),
                                      decoration: BoxDecoration(
                                          color: Colors.indigo[100],
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: Colors.black54,width: 1.0,

                                          )
                                      ),
                                      child: Text(
                                        // "Select button to get location djd kms nkdnknd nskndkmsk cncknd uss huhud ndjnd bduhnd dhjudnu dundud dujndudn du",
                                        address,
                                        style: const TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                                        softWrap: true,
                                        overflow: TextOverflow.visible,
                                      ),
                                    )),
                                  ],
                                ),),
                              Container(
                                padding: EdgeInsets.only(top: 20),
                                child: Row(
                                  children: [
                                    Flexible(flex:1,child: Container(
                                        width: double.infinity/4,
                                        child: const Text("Select Admin : ",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),))),
                                    const Flexible(flex: 0,
                                        child: SizedBox(width: 10,)),
                                    FutureBuilder<List<String>>(
                                      future: getAllAdminEmails(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return CircularProgressIndicator();
                                        } else if (snapshot.hasError) {
                                          return Text('Error: ${snapshot.error}');
                                        }
                                        else {
                                          _filterOptions = snapshot.data ?? [];
                                          return Flexible(
                                            flex: 3,
                                            child: Container(
                                              width: double.infinity/1.3,

                                              child: DropdownButton<String>(
                                                isExpanded: true,
                                                hint: const Text('Select an Option'),
                                                underline: Container(
                                                  height: 0,
                                                  color: Colors.transparent,
                                                ),
                                                value: selectedFilter,
                                                onChanged: (newValue) {
                                                  setState(() {
                                                    selectedFilter = newValue;
                                                    selectedAdmin=newValue!;
                                                  });
                                                  print(selectedFilter);
                                                },
                                                items: _filterOptions.map((valueItem) {
                                                  return DropdownMenuItem(
                                                    value: valueItem,
                                                    child: Text(
                                                      valueItem,
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          );
                                        }
                                  },
                                ),
                                  ],
                                ),

                              )
                            ],
                          ),
                        ),
                      ],
                    )
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16,vertical: 15),
                      width: MediaQuery.of(context).size.width/2.5,
                      // height:MediaQuery.of(context).size.height/12,
                      // height: 100,
                      // color: Colors.greenAccent,
                      child: MaterialButton(
                          elevation: 0,
                          onPressed: () async{
                            Position pos=await determinePosition();
                            print(pos.latitude);
                            location="Latitude :${pos.latitude}, Longitude : ${pos.longitude}";

                            GetAddressFromLatLong(pos);
                            setState(() {


                            });
                          },
                          color: Colors.indigo[800],
                          textColor: Colors.white,
                          padding: EdgeInsets.all(12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: const BorderSide(
                              color: Color(0xFFebf1fa), // Set the border color
                              width: 1.0,         // Set the border width
                            ),
                          ),
                          child:const Text("GET LOCATION ",style: TextStyle(color:Colors.white,fontSize: 18,fontWeight: FontWeight.bold
                          ),)
                      ),
                    ),
                    Container(
                      margin:const EdgeInsets.symmetric(horizontal: 16,vertical: 15),
                      width: MediaQuery.of(context).size.width/2.5,
                      // height:MediaQuery.of(context).size.height/12,
                      // height: 100,
                      // color: Colors.greenAccent,
                      child: MaterialButton(
                          elevation: 0,
                          onPressed: () async{//ABOVE FROM STORE FUNCTION REMOVED CONDITION DJD
                            // && selectedAdmin==adm // //REASON TO REMOVE IS THAT MANY ADMIN WILL GET SAME SUGGEST
                            if (location.trim().isNotEmpty && address.trim().isNotEmpty && selectedAdmin.isNotEmpty){
                              Position pos = await determinePosition();
                              storeNewRestroomData(pos,address,widget.uname,selectedAdmin);

                              // String? email = await getEmailFromName(widget.uname);
                              // if (email != null) {
                              //   setSuggestionCount(email);
                              //   print('Email for Hari Kumar: $email');
                              // } else {
                              //   print('No email found for Hari Kumar');
                              // }
                              setSuggestionCount("${widget.uemail}");
                              print('Email for Hari Kumar: ${widget.uemail}');
                              
                              print("Success");
                            }
                            else{
                              print("Location is Empty");
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Address is not generated'),
                                    content: Text("Click on \'GET LOCATION\' Button to generate current location and address."),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text('OK'),
                                        onPressed: () {
                                          Navigator.of(context).pop();

                                        },
                                      ),
                                    ],
                                  );
                                },
                              );


                            }


                          },
                          color: Colors.indigo[800],
                          textColor: Colors.white,
                          padding: EdgeInsets.all(12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: BorderSide(
                              color: Color(0xFFebf1fa), // Set the border color
                              width: 1.0,         // Set the border width
                            ),
                          ),
                          child:Text("SEND",style: TextStyle(color:Colors.white,fontSize: 18,fontWeight: FontWeight.bold
                          ),)
                      ),
                    ),
                  ],
                )

              ],
            ),
          );
        });
      },
    );
  }

  Future<String?> getEmailFromName(String name) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await FirebaseFirestore.instance
          .collection('users')
          .where('name', isEqualTo: name)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first['email'];
      } else {
        return null;
      }
    } catch (error) {
      print('Error retrieving email from name: $error');
      return null;
    }
  }


  Future<void> _onImagePickerButtonPressed(String email) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      if (email != null) {
        uploadImageToFirebaseStorage(imageFile, email);
      }

    }
  }
  Future<String?> getProfileImageUrl(String userEmail) async {
    try {
      final Reference storageReference =
      FirebaseStorage.instance.ref().child('prof_images/$userEmail.jpg');

      final String downloadURL = await storageReference.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('Error getting profile image URL: $e');
      return null;
    }
  }

  Future<void> loadProfileImage(String email) async {
    final imageUrl = await getProfileImageUrl(email);
    if (imageUrl != null) {
      setState(() {
        _profileImageUrl = imageUrl;
      });
    }
    print("PROFILE");
  }
  Future<void> uploadImageToFirebaseStorage(File imageFile, String Email) async {
    try {
      final Reference storageReference =
      FirebaseStorage.instance.ref().child('prof_images/$Email.jpg');

      final UploadTask uploadTask = storageReference.putFile(imageFile);

      await uploadTask.whenComplete(() async {
        loadProfileImage(Email);
        final imageUrl = await storageReference.getDownloadURL();

        print('Image uploaded to Firebase Storage: $imageUrl');
        final querySnap =await FirebaseFirestore.instance.collection('users').where("email", isEqualTo: Email).get();

        if (querySnap.docs.isNotEmpty) {
          final doctorDocument = querySnap.docs.first;
          await doctorDocument.reference.update({
            'prof_img': imageUrl,
          });

        }
        else {
          print("No document found with email: $Email");
        }

        print('Image URL saved in Firestore.');
      });
    } catch (e) {
      print('Error uploading image to Firebase Storage: $e');
    }
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
