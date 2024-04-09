import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:rest_ez_app/user/LoginUser.dart';
import 'package:rest_ez_app/user/RatingsPage.dart';
import 'package:rest_ez_app/user/editPost.dart';
import 'package:rest_ez_app/user/reportIssue.dart';
import 'package:rest_ez_app/user/shared.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/model.dart';
import '../widgets/widget.dart';
import 'Profile.dart';

class RestroomPageUser extends StatefulWidget {
  const RestroomPageUser({Key? key,
    required this.document,required this.dist,required this.pos,required this.restroomloc,
  });

  final DocumentSnapshot document;
  final String dist;
  final Position pos;
  final LatLng restroomloc;


  @override
  State<RestroomPageUser> createState() => _RestroomPageUserState();
}

class _RestroomPageUserState extends State<RestroomPageUser> {
  bool isLiked=false;
  bool expanded = false;
  bool isSaved=false;
  Map<String, dynamic> restRoomData = {};

  Future<void> fetchRestroomById(String id) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance.collection('restrooms').doc(id).get();
      if (snapshot.exists) {
        restRoomData = snapshot.data()!;
      } else {
        restRoomData = {};
      }
    } catch (error) {
      print('Error fetching restroom data: $error');
      restRoomData = {};
    }
  }


  void navigateToRestroom(Position userPosition, LatLng restroomLocation) async {
    String googleMapsUrl = 'https://www.google.com/maps/dir/?api=1&destination=${restroomLocation.latitude},${restroomLocation.longitude}';
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {

    }
  }
  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }
  void Bookmark(List<dynamic> savedBy)async{
    await FirebaseFirestore.instance
        .collection('restrooms')
        .doc(widget.document.id)
        .update({
      'savedBy': savedBy,
    });
  }
  Future<String?> getNameByEmail(String email) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first['name'];
      } else {
        print('No user found with email: $email');
        return null;
      }
    } catch (error) {
      print('Error fetching user data: $error');
      return null;
    }
  }

  Future<double> calculateAverageRating() async {
    CollectionReference reviewsRef = FirebaseFirestore.instance
        .collection('restrooms')
        .doc(widget.document.id)
        .collection('reviews');

    QuerySnapshot querySnapshot = await reviewsRef.get();

    int totalRatings = 0;
    int totalReviews = querySnapshot.size;

    querySnapshot.docs.forEach((reviewDoc) {
      dynamic ratingValue = reviewDoc['rating'];
      if (ratingValue is int) {
        totalRatings += ratingValue;
      } else if (ratingValue is double) {
        totalRatings += ratingValue.toInt();
      } else {

      }
    });

    double averageRating = totalReviews > 0 ? totalRatings / totalReviews : 0;

    return averageRating;
  }

  Future<void> setAverageRating(String restroomId) async {
    try {
      CollectionReference reviewsRef = FirebaseFirestore.instance
          .collection('restrooms')
          .doc(restroomId)
          .collection('reviews');

      QuerySnapshot querySnapshot = await reviewsRef.get();


      int totalRatings = 0;
      int totalReviews = querySnapshot.size;

      querySnapshot.docs.forEach((reviewDoc) {
        dynamic ratingValue = reviewDoc['rating'];
        if (ratingValue is int) {
          totalRatings += ratingValue;
        } else if (ratingValue is double) {
          totalRatings += ratingValue.toInt();
        } else {
        }
      });

      // Calculate tavg rating
      double averageRating = totalReviews > 0 ? totalRatings / totalReviews : 0;
      double avgRating=double.parse(averageRating.toStringAsFixed(1));

      await FirebaseFirestore.instance
          .collection('restrooms')
          .doc(restroomId)
          .set({'ratings': avgRating}, SetOptions(merge: true));


    } catch (error) {
      print('Error calculating average rating: $error');

    }
  }
  Stream<double> ratingStream(int rate) async* {
    while (true) {
      CollectionReference reviewsRef = FirebaseFirestore.instance
          .collection('restrooms')
          .doc(widget.document.id)
          .collection('reviews');

      QuerySnapshot querySnapshot = await reviewsRef.where('rating', isEqualTo: rate).get();
      DocumentSnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance.collection('restrooms').doc(widget.document.id).get();

      int rateDocuments = querySnapshot.docs.length;
      print("rateDocuments$rateDocuments and rate :$rate");
      int totalDocuments = snapshot['no_of_reviews'];
      print('total $totalDocuments');

      double value = totalDocuments > 0 ? rateDocuments / totalDocuments : 0.0;
      yield double.parse(value.toStringAsFixed(1));

      // Sleep for some time before emitting the next value (if needed)
      await Future.delayed(Duration(seconds: 1));
    }
  }

  Stream<double> convertRatingToValueStream(int rate) async* {
    CollectionReference reviewsRef = FirebaseFirestore.instance.collection('restrooms')
        .doc(widget.document.id).collection('reviews');

    QuerySnapshot querySnapshot = await reviewsRef.where('rating', isEqualTo: rate).get();
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance.collection('restrooms').doc(widget.document.id).get();

    int rateDocuments = querySnapshot.docs.length;
    int totalDocuments = snapshot['no_of_reviews'];

    if (totalDocuments == 0) {
      yield 0.0;
    }

    double value = rateDocuments / totalDocuments;
    double roundedValue = double.parse(value.toStringAsFixed(1));

    yield roundedValue;
  }

  Future<double> convertRatingToValue(int rate) async {

    CollectionReference reviewsRef = FirebaseFirestore.instance.collection('restrooms')
        .doc(widget.document.id).collection('reviews');

    QuerySnapshot querySnapshot = await reviewsRef.where('rating', isEqualTo: rate).get();
    // print(querySnapshot.data);
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance.collection('restrooms').doc(widget.document.id).get();


    int rateDocuments = querySnapshot.docs.length;
    print("rateDocuments$rateDocuments and rate :$rate");
    int totalDocuments=snapshot['no_of_reviews'];
    print('total $totalDocuments');
    if (totalDocuments == 0) {
      return 0.0;
    }
    double value = rateDocuments / totalDocuments;
    double roundedValue = double.parse(value.toStringAsFixed(1));
    return roundedValue;
  }

  Future<List<dynamic>> getSavedBy() async {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
        .collection('restrooms')
        .doc(widget.document.id)
        .get();
    List<dynamic> savedBy = snapshot.data()?['savedBy'] ?? [];
    return savedBy;
  }

  void update_no_of_review(String id)async{
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('restrooms')
        .doc(id)
        .collection('reviews')
        .get();

    int reviewsLength = querySnapshot.docs.length.toInt();
    print('Number of reviews: $reviewsLength');
    FirebaseFirestore.instance
        .collection('restrooms')
        .doc(id).set({
      'no_of_reviews':reviewsLength ,
    }, SetOptions(merge: true));

    print("object");
  }
  Future<int> get_review(String id)async{
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('restrooms')
        .doc(id)
        .collection('reviews')
        .get();

    int reviewsLength = querySnapshot.docs.length.toInt();
    return reviewsLength;
  }


  bool _isSignedIn = false;
  String email="";
  getUserLoggedInStatus() async {
    await SharedPreference.getUserLoggedInStatus().then((value) {
      if (value != null) {
        setState(() {
          _isSignedIn = value;
        });
      }
    });
  }

  getUserLoggedInEmail() async {
    await SharedPreference.getUserEmailFromSF().then((value) {
      if (value != null) {
        setState(() {
          email = value;
        });
      }
    });
  }
  void getNameByEmailFunc(String email, Function(String?) callback) {
    FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        callback(querySnapshot.docs.first['name']);
      } else {
        print('No user found with email: $email');
        callback(null);
      }
    }).catchError((error) {
      print('Error fetching user data: $error');
      callback(null);
    });
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
  @override
  void initState() {
    super.initState();
    fetchRestroomById(widget.document.id);
    update_no_of_review(widget.document.id);
    print("${widget.document['no_of_reviews']}");
    setAverageRating(widget.document.id);
    print("priny : $restRoomData");
    getUserLoggedInStatus();
    getUserLoggedInEmail();
  }
  void _launchWhatsApp(String message) async {
    // Encode the message using Uri.encodeFull to handle special characters
    String encodedMessage = Uri.encodeFull(message);
    String whatsappUrl = "whatsapp://send?text=$encodedMessage";

    // Check if WhatsApp is installed and launch the URL
    await canLaunch(whatsappUrl)
        ? launch(whatsappUrl)
        : print('Could not launch WhatsApp');
  }

  @override
  void didChangeDependencies() {
    fetchRestroomById(widget.document.id);
    update_no_of_review(widget.document.id);
    print("${widget.document['no_of_reviews']}");
  }
  String? _profileImageUrl;
  @override
  Widget build(BuildContext context) {
    // List<dynamic> savedBy =restRoomData['savedBy']??[];
    late double avgRating;

    return DefaultTabController(
        length: 3,//4
        child: Scaffold(
          appBar: CustomAppBar(
            appTitle: "Restroom Details",
            icon: FaIcon(Icons.arrow_back_ios),
          ),
          body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('restrooms')
                        .doc(widget.document.id)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || !snapshot.data!.exists) {
                        return Text('Document not found');
                      } else {
                        var documentData = snapshot.data!.data()!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(documentData['name'],style: TextStyle(fontWeight: FontWeight.bold,fontSize: 24),),
                            Row(
                              children: [
                                Text("${documentData['ratings']}",style: TextStyle(fontSize: 16)),
                                RatingBar.builder(
                                  initialRating: double.parse(widget.document['ratings'].toString()),
                                  itemSize: 20,
                                  minRating: 1,
                                  direction: Axis.horizontal,
                                  allowHalfRating: true,
                                  itemCount: 5,
                                  ignoreGestures: true,
                                  // itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                                  itemBuilder: (context, _) =>  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    // size: 10,
                                  ),
                                  onRatingUpdate: (rating) {
                                    print(rating);

                                  },
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Text("Public Restroom ",style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 10,),
                                const Icon(Icons.social_distance),
                                Text('  ${widget.dist} km ',style:  const TextStyle(fontSize: 16))
                              ],
                            ),
                            const SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                MaterialButton(
                                    elevation: 0,
                                    onPressed: () {
                                      navigateToRestroom(widget.pos, widget.restroomloc);
                                    },
                                    color: Colors.indigo[600],
                                    textColor: Colors.white,
                                    padding:  const EdgeInsets.symmetric(vertical: 6,horizontal: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      side: const BorderSide(
                                        color: Color(0xFFebf1fa),
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Container(
                                      padding:  const EdgeInsets.symmetric(horizontal: 6,vertical: 4),
                                      child: const Row(
                                        children: [
                                          Icon(Icons.directions,color: Colors.white,),
                                          Text(
                                            "Directions",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    )
                                ),
                                MaterialButton(
                                    elevation: 0,
                                    onPressed: ()async {
                                      if(_isSignedIn){
                                        print("In onPResed");
                                        print("object : $restRoomData");
                                        List<dynamic> savedBy =restRoomData['savedBy']??[];
                                        print("hish");
                                        print(savedBy);
                                        print("before bookmark");
                                        Bookmark(savedBy);
                                        print("after bookmark");
                                        bool isFav = savedBy.contains(email)??false;
                                        if (isFav) {
                                          //savedBy.remove(widget.name);
                                          isSaved=isFav;
                                          print("is saved true");
                                        }
                                        print("is saved false");
                                        await FirebaseFirestore.instance
                                            .collection('restrooms')
                                            .doc(widget.document.id)
                                            .update({'savedBy': savedBy});

                                        print("after update");

                                        setState(() {
                                          print("in set");
                                          isSaved=!isSaved;
                                          print("is saved  changed :$isSaved");
                                          if(!isSaved){
                                            print("is saved false REMOVED");
                                            savedBy.remove(email);
                                          }
                                          else{
                                            print("is saved true ADDED");
                                            savedBy.add(email);
                                          }
                                          print("SET END");
                                          print(email);

                                        });
                                      }

                                    },
                                    color: Colors.white,
                                    textColor: Colors.indigo[600],
                                    padding:  const EdgeInsets.symmetric(vertical: 6,horizontal: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      side: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6,vertical: 4),
                                      child: Row(
                                        children: [
                                          // restRoomData['savedBy'].contains("Hari Kumar")==true
                                          //     ?Icon(Icons.bookmark,color: Colors.indigo,)
                                          //     :Icon(Icons.bookmark_border,color: Colors.blue[700],),
                                          _isSignedIn & email.isNotEmpty
                                              ?
                                          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                                            stream: FirebaseFirestore.instance
                                                .collection('restrooms')
                                                .doc(widget.document.id)
                                                .snapshots(),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState == ConnectionState.waiting) {
                                                return Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.bookmark_border, color: Colors.indigo[600]),
                                                    SizedBox(width: 5,),
                                                    Text(
                                                      "Save",
                                                      style: TextStyle(
                                                          color: Colors.indigo[600],
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold),
                                                    ),
                                                  ],
                                                );
                                              } else if (snapshot.hasError) {
                                                return Text('Error: ${snapshot.error}');
                                              } else {
                                                List<dynamic> savedBy = snapshot.data?.data()?['savedBy'] ?? [];
                                                bool isSaved = savedBy.contains(email) ?? false;
                                                return isSaved
                                                    ?Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.bookmark, color: Colors.indigo),
                                                    SizedBox(width: 5,),
                                                    Text(
                                                      "Save",
                                                      style: TextStyle(
                                                          color: Colors.indigo[600],
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold),
                                                    ),
                                                  ],
                                                )
                                                    :Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.bookmark_border, color: Colors.indigo[600]),
                                                    SizedBox(width: 5,),
                                                    Text(
                                                      "Save",
                                                      style: TextStyle(
                                                          color: Colors.indigo[600],
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold),
                                                    ),
                                                  ],
                                                );





                                              }
                                            },
                                          )
                                              :
                                          GestureDetector(
                                            onTap: (){
                                              showDialog(context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text("You need to Login first"),
                                                    content: const Text(
                                                        "Click on login button if you want to save"),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context).pop();
                                                        },
                                                        child: const Text("Leave"),
                                                      ),
                                                      TextButton(
                                                        onPressed: () async {
                                                          Navigator.pushReplacement(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      UserLoginPage()
                                                                //         SignupPageUser
                                                              ));
                                                        },
                                                        child: Text("Login"),
                                                      ),
                                                    ],
                                                  );
                                                },);
                                            },

                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.bookmark_border, color: Colors.indigo[600]),
                                                SizedBox(width: 5,),
                                                Text(
                                                  "Save",
                                                  style: TextStyle(
                                                      color: Colors.indigo[600],
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                ),
                                MaterialButton(
                                    elevation: 0,

                                    onPressed: () => _launchWhatsApp(documentData['address']),
                                    color: Colors.white,
                                    textColor: Colors.indigo[600],
                                    padding:  const EdgeInsets.symmetric(vertical: 6,horizontal: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      side: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6,vertical: 4),
                                      child: Row(
                                        children: [
                                          Icon(Icons.share,color: Colors.indigo[600],),
                                          Text(
                                            "Share",
                                            style: TextStyle(
                                                color: Colors.indigo[600],
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    )
                                )
                              ],
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 15,bottom: 5),
                              height: 1,
                              color: Colors.grey[300],
                            ),
                            TabBar(
                                indicatorColor: Colors.indigo[600],
                                indicatorSize: TabBarIndicatorSize.tab,
                                indicatorWeight: 2,
                                unselectedLabelStyle: const TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16),
                                labelStyle: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 17),
                                tabs: const [
                                  Tab(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        "About",
                                        style: TextStyle(),
                                      ),
                                    ),
                                  ),
                                  Tab(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        "Reviews",
                                        style: TextStyle(),
                                      ),
                                    ),
                                  ),
                                  Tab(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        "Photos",
                                        style: TextStyle(),
                                      ),
                                    ),
                                  ),
                                ]),
                            Expanded(
                              child: TabBarView(
                                children: [
                                  // About Tab Content
                                  SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(left:12,right:10,bottom:8,top: 15.0),
                                          child: Row(
                                            children: [
                                              Icon(Icons.location_on_outlined,color: Colors.blue[900],),
                                              Expanded(
                                                child: Container(
                                                  width: MediaQuery.of(context).size.width/1.5,
                                                  padding: const EdgeInsets.only(left: 20.0,right:10,),
                                                  child: Text(
                                                    widget.document['address'],
                                                    style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400,height: 1.5)
                                                    ,overflow: TextOverflow.visible,softWrap: true,
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.content_copy),
                                                onPressed: () {
                                                  copyToClipboard(widget.document['address']);
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        Divider(),
                                        Padding(
                                          padding: const EdgeInsets.only(left:12,right:10,bottom:8,top: 8.0),
                                          child: Row(
                                            children: [
                                              Icon(Icons.groups,color: Colors.blue[900],),
                                              Expanded(
                                                child: Container(
                                                  width: MediaQuery.of(context).size.width/1.5,
                                                  padding: const EdgeInsets.only(left: 20.0,right:10),
                                                  child: Text(
                                                    (() {
                                                      String accessibility = '';
                                                      String genders = widget.document['gender'].join(', ');

                                                      if (widget.document['handicappedAccessible']) {
                                                        accessibility += 'Handicap, ';
                                                      }
                                                      if (genders.isNotEmpty) {
                                                        accessibility += genders;
                                                      }

                                                      return accessibility.isNotEmpty ? accessibility : 'Not specified';
                                                    })(),

                                                    style: const TextStyle(fontSize: 16,fontWeight: FontWeight.w400,)
                                                    ,overflow: TextOverflow.visible,softWrap: true,
                                                  ),
                                                ),
                                              ),


                                            ],
                                          ),
                                        ),
                                        Divider(),
                                        Padding(
                                          padding: const EdgeInsets.only(left:12,right:10,bottom:8,top: 8.0),
                                          child: Row(
                                            children: [
                                              Icon(Icons.access_alarm,color: Colors.blue[900],),
                                              Expanded(
                                                child: Container(
                                                  width: MediaQuery.of(context).size.width/1.5,
                                                  padding: const EdgeInsets.only(left: 20.0,right:10),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        widget.document['availabilityHours'],
                                                        style: const TextStyle(fontSize: 16,fontWeight: FontWeight.w400,color: Colors.black)
                                                        ,overflow: TextOverflow.visible,softWrap: true,
                                                      ),
                                                      // Icon(Icons.arrow_drop_down_sharp,color: Colors.grey,)
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Divider(),
                                        InkWell(
                                          onTap: ()async{
                                            if(_isSignedIn && email!=""){
                                              String? name = await getNameByEmail(email);

                                              if (name != null){
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder:
                                                      (context) => ReportIssues( rest_id:widget.document.id, adminEmail: widget.document['handledBy'], restAddress:widget.document['address'], restName: widget.document['name'], uemail:email,),
                                                  ),
                                                );

                                              }
                                              else{
                                                print("name not found for report issue");

                                              }
                                            }
                                            else{
                                              showDialog(context: context, builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text("You need to SignUp first"),
                                                  content: Text("Click on login button if you want to give review"),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                      },
                                                      child: Text("Leave"),
                                                    ),
                                                    TextButton(
                                                      onPressed: () async {
                                                        Navigator.pushReplacement(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) => UserLoginPage()
                                                              //         SignupPageUser
                                                            ));


                                                      },
                                                      child: Text("SignUp"),
                                                    ),
                                                  ],
                                                );
                                              },);
                                            }
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(left:12,right:10,bottom:8,top: 8.0),
                                            child: Row(
                                              children: [
                                                Icon(Icons.report,color: Colors.blue[900],),
                                                Expanded(
                                                  child: Container(
                                                    width: MediaQuery.of(context).size.width/1.5,
                                                    padding: const EdgeInsets.only(left: 20.0,right:10),
                                                    child: Row(
                                                      children: [

                                                        Text(
                                                          'Report Issue',
                                                          style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400,color: Colors.green[800])
                                                          ,overflow: TextOverflow.visible,softWrap: true,
                                                        ),

                                                      ],
                                                    ),
                                                  ),
                                                ),


                                              ],
                                            ),
                                          ),
                                        ),
                                        Divider(),

                                      ],
                                    ),
                                  ),
                                  // Reviews Tab Content
                                  SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.only(left: 12,right: 12,bottom: 10,top:18),
                                          child: Row(
                                            children: [
                                              Column(
                                                children: [
                                                  // FutureBuilder<double>(
                                                  //   future: calculateAverageRating(),
                                                  //   builder: (context, snapshot) {
                                                  //     if (snapshot.connectionState == ConnectionState.waiting) {
                                                  //       return CircularProgressIndicator();
                                                  //     } else if (snapshot.hasError) {
                                                  //
                                                  //       return Text('Error: ${snapshot.error}');
                                                  //     } else {
                                                  //
                                                  //       double averageRating = snapshot.data ?? 0;
                                                  //       avgRating = double.parse((snapshot.data ?? 0).toStringAsFixed(1));
                                                  //       String formattedAverageRating = averageRating.toStringAsFixed(1);
                                                  //       // setAverageRating(widget.document.id,avgRating);
                                                  //       return Text(formattedAverageRating,style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),);
                                                  //     }
                                                  //   },
                                                  // ),
                                                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                                                    stream: FirebaseFirestore.instance
                                                        .collection('restrooms')
                                                        .doc(widget.document.id)
                                                        .collection('reviews')
                                                        .snapshots(),
                                                    builder: (context, snapshot) {
                                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                                        return const Text(
                                                          "3.0",
                                                          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                                                        );
                                                      } else if (snapshot.hasError) {
                                                        return Text('Error: ${snapshot.error}');
                                                      } else {
                                                        int totalRatings = 0;
                                                        int totalReviews = snapshot.data!.size;

                                                        snapshot.data!.docs.forEach((reviewDoc) {
                                                          dynamic ratingValue = reviewDoc['rating'];
                                                          if (ratingValue is int) {
                                                            totalRatings += ratingValue;
                                                          } else if (ratingValue is double) {
                                                            totalRatings += ratingValue.toInt();
                                                          }
                                                        });

                                                        double averageRating = totalReviews > 0 ? totalRatings / totalReviews : 0;
                                                        return Text(
                                                          averageRating.toStringAsFixed(1),
                                                          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                                                        );
                                                      }
                                                    },
                                                  ),


                                                  RatingBar.builder(
                                                    initialRating: double.parse(widget.document['ratings'].toString()),
                                                    itemSize: 15,
                                                    minRating: 0,
                                                    direction: Axis.horizontal,
                                                    allowHalfRating: true,
                                                    itemCount: 5,
                                                    ignoreGestures: true,
                                                    // itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                                                    itemBuilder: (context, _) =>  Icon(
                                                      Icons.star,
                                                      color: Colors.amber,
                                                      // size: 10,
                                                    ),
                                                    onRatingUpdate: (rating) {
                                                      print(rating);


                                                      // You can update the rating here if needed
                                                    },
                                                  ),
                                                  // FutureBuilder<int>(
                                                  //   future: get_review(widget.document.id),
                                                  //   builder: (context, snapshot) {
                                                  //     if (snapshot.connectionState == ConnectionState.waiting) {
                                                  //       return CircularProgressIndicator();
                                                  //     } else if (snapshot.hasError) {
                                                  //       return Text('Error: ${snapshot.error}');
                                                  //     } else {
                                                  //       int reviews = snapshot.data ?? 0;
                                                  //       String reviewString = reviews.toString();
                                                  //       return Text('(${reviewString})',style: TextStyle());
                                                  //     }
                                                  //   },
                                                  // ),
                                                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                                                    stream: FirebaseFirestore.instance
                                                        .collection('restrooms')
                                                        .doc(widget.document.id)
                                                        .collection('reviews')
                                                        .snapshots(),
                                                    builder: (context, snapshot) {
                                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                                        return  Container(
                                                            height: 10,
                                                            width:10,
                                                            child: CircularProgressIndicator());
                                                      } else if (snapshot.hasError) {
                                                        return Text('Error: ${snapshot.error}');
                                                      } else {
                                                        int reviews = snapshot.data!.docs.length;
                                                        String reviewString = reviews.toString();
                                                        return Text('($reviewString)', style: TextStyle());
                                                      }
                                                    },
                                                  ),

                                                ],
                                              ),
                                              Expanded(
                                                child: Column(
                                                  children: [
                                                    for (int rate = 5; rate >= 1; rate--)
                                                      FutureBuilder<double>(
                                                        future: convertRatingToValue(rate),
                                                        builder: (context, snapshot) {
                                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                                            return RatingProgress(text: rate.toString(), value: 0.0);
                                                          } else if (snapshot.hasError) {
                                                            return Text('Error: ${snapshot.error}');
                                                          } else {
                                                            return RatingProgress(text: rate.toString(), value: (snapshot.data ?? 0.0));
                                                          }
                                                        },
                                                      ),
                                                    // StreamBuilder<double>(
                                                    //   stream: convertRatingToValueStream(rate),
                                                    //   builder: (context, snapshot) {
                                                    //     if (snapshot.connectionState == ConnectionState.waiting) {
                                                    //       return CircularProgressIndicator();
                                                    //     } else if (snapshot.hasError) {
                                                    //       return Text('Error: ${snapshot.error}');
                                                    //     } else {
                                                    //       return RatingProgress(text: rate.toString(), value: (snapshot.data ?? 0.0));
                                                    //     }
                                                    //   },
                                                    // ),

                                                    // StreamBuilder<double>(
                                                    //   stream: ratingStream(rate),
                                                    //   builder: (context, snapshot) {
                                                    //     if (snapshot.connectionState == ConnectionState.waiting) {
                                                    //       return CircularProgressIndicator();
                                                    //     } else if (snapshot.hasError) {
                                                    //       return Text('Error: ${snapshot.error}');
                                                    //     } else {
                                                    //       return RatingProgress(text: rate.toString(), value: snapshot.data ?? 0.0);
                                                    //     }
                                                    //   },
                                                    // ),
                                                  ],
                                                ),

                                              ),


                                            ],
                                          ),
                                        ),
                                        Divider(),
                                        Container(
                                          // color: Colors.black54,
                                          padding: EdgeInsets.only(left: 12,right: 12,bottom: 10,top:8),
                                          child: Column(
                                            crossAxisAlignment:CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              const Text("Rate and Review",style: TextStyle(fontSize: 19,fontWeight: FontWeight.bold),),
                                              const Text("Share your experience to help others",style: TextStyle(fontSize: 14,color: Colors.black54),),
                                              const SizedBox(height: 8,),
                                              InkWell(
                                                  onTap: ()async{
                                                    if(_isSignedIn){
                                                      String? name = await getNameByEmail(email);


                                                      if (name != null) {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) => RatingPage(uname: name, document: widget.document, id: widget.document.id, uemail: email,)));

                                                        print('Name associated with $email is: $name');
                                                      }
                                                      else {
                                                        print('No name found for email: $email');
                                                      }
                                                    }
                                                    else{
                                                      showDialog(context: context, builder: (BuildContext context) {
                                                        return AlertDialog(
                                                          title: Text("You need to SignUp first"),
                                                          content: Text("Click on login button if you want to give review"),
                                                          actions: <Widget>[
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.of(context).pop();
                                                              },
                                                              child: Text("Leave"),
                                                            ),
                                                            TextButton(
                                                              onPressed: () async {
                                                                Navigator.pushReplacement(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) => UserLoginPage()
                                                                      //         SignupPageUser
                                                                    ));


                                                              },
                                                              child: Text("SignUp"),
                                                            ),
                                                          ],
                                                        );
                                                      },);
                                                    }

                                                  },
                                                  child:FutureBuilder<String?>(
                                                    future: getNameByEmail(email),
                                                    builder: (context, snaps) {
                                                      if (snaps.connectionState == ConnectionState.waiting) {
                                                        return const CircularProgressIndicator();
                                                      } else if (snaps.hasError) {
                                                        return Text('Error: ${snaps.error}');
                                                      } else {
                                                        if (snaps.data != null) {
                                                          return Row(
                                                            children: [
                                                              _isSignedIn ?
                                                              CircleAvatar(
                                                                  backgroundColor: Colors.red[900],
                                                                  radius: 24,
                                                                  child: Text(
                                                                    Utils.getInitials("${snaps.data}"),
                                                                    style: const TextStyle(
                                                                        fontSize: 22, color: Colors.white,fontWeight: FontWeight.bold),
                                                                  )

                                                              )


                                                                  :
                                                              CircleAvatar(
                                                                backgroundColor: Colors.red[900],
                                                                radius: 24,
                                                                child:
                                                                const Icon(Icons.person,size:28,color: Colors.white,),
                                                              ),

                                                              SizedBox(width: 20,),
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                children:
                                                                List.generate(5, (index) {
                                                                  int starIndex = index + 1;
                                                                  return const Icon(
                                                                    Icons.star_border_outlined,
                                                                    size: 36,
                                                                    color:Colors.black54,
                                                                  );
                                                                }),

                                                              ),
                                                            ],
                                                          );
                                                        } else {
                                                          // No user found
                                                          return const Text('User not found.');
                                                        }
                                                      }
                                                    },
                                                  )

                                              ),
                                              Center(
                                                child: Container(
                                                  margin: EdgeInsets.only(left: 16,top: 4,right: 16),
                                                  width: MediaQuery.of(context).size.width/2,
                                                  child: MaterialButton(
                                                      elevation: 0,
                                                      onPressed: () async{
                                                        if(_isSignedIn){
                                                          String? name = await getNameByEmail(email);

                                                          if (name != null) {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) => RatingPage(uname: name, document: widget.document, id: widget.document.id, uemail: email,)));

                                                            print('Name associated with $email is: $name');
                                                          } else {
                                                            print('No name found for email: $email');
                                                          }
                                                        }
                                                        else{
                                                          showDialog(context: context, builder: (BuildContext context) {
                                                            return AlertDialog(
                                                              title: const Text("You need to SignUp first"),
                                                              content: const Text("Click on SignUp button if you want to give review"),
                                                              actions: <Widget>[
                                                                TextButton(
                                                                  onPressed: () {
                                                                    Navigator.of(context).pop();
                                                                  },
                                                                  child:const Text("Leave"),
                                                                ),
                                                                TextButton(
                                                                  onPressed: () async {
                                                                    Navigator.pushReplacement(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (context) => UserLoginPage()
                                                                          //         SignupPageUser
                                                                        ));


                                                                  },
                                                                  child: const Text("SignUp"),
                                                                ),
                                                              ],
                                                            );
                                                          },);
                                                        }
                                                      },
                                                      color: Colors.white,
                                                      textColor: Colors.black,
                                                      padding: const EdgeInsets.all(6),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(30),
                                                        side: const BorderSide(
                                                          color: Colors.grey,
                                                          width: 0.5,
                                                        ),
                                                      ),
                                                      child:Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Icon(Icons.edit_note_outlined,color: Colors.indigo[800],),
                                                          SizedBox(width:10),
                                                          const Text("Write a review",style: TextStyle(color:Colors.black,fontSize: 15,),),
                                                        ],
                                                      )
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Divider(),
                                        Container(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Padding(
                                                padding: EdgeInsets.only(left: 12.0,top: 10,bottom: 10),
                                                child: Text("Reviews",style: TextStyle(fontSize: 19,fontWeight: FontWeight.bold),),
                                              ),
                                              StreamBuilder(
                                                stream: FirebaseFirestore.instance
                                                    .collection('restrooms')
                                                    .doc(widget.document.id)
                                                    .collection('reviews')
                                                    .snapshots(),
                                                builder: (context, snapshot) {

                                                  if (snapshot.connectionState ==
                                                      ConnectionState.waiting) {
                                                    return ReviewSkeleton();//Center(child: CircularProgressIndicator());
                                                  }
                                                  if (snapshot.hasError) {
                                                    return Text('Error: ${snapshot.error}');
                                                  }
                                                  if (!snapshot.hasData ||
                                                      snapshot.data!.docs.isEmpty) {
                                                    return Center(child: Text('No reviews available.'));
                                                  }
                                                  // Display reviews
                                                  List<Review> reviewlist = snapshot.data!.docs.map((doc) => Review.fromFirestore(doc)).toList();

                                                  return Container(
                                                    height: MediaQuery.of(context).size.height/2,
                                                    child: ListView.builder(
                                                      // physics: NeverScrollableScrollPhysics(),
                                                        itemCount: reviewlist.length,
                                                        scrollDirection: Axis.vertical,
                                                        itemBuilder: (context, index) {
                                                          // Review reviewDocument = reviewlist[index];

                                                          int likesCount = reviewlist[index].likeCounts;
                                                          List<dynamic> likedBy = reviewlist[index].likedBy ?? [];
                                                          print(reviewlist[index].name);

                                                          return Container(
                                                            // height: 200,
                                                            margin: EdgeInsets.only(bottom: 8),

                                                            padding: const EdgeInsets.only(left: 8.0,right:8,top: 15),
                                                            decoration:  BoxDecoration(

                                                              border: Border.all(
                                                                color: Colors.grey.shade300,
                                                                width:0.7
                                                              ),
                                                              borderRadius: BorderRadius.circular(20)
                                                              // border: Border(
                                                              //   bottom: BorderSide(
                                                              //     color: Colors.grey,
                                                              //     width: 1.0,
                                                              //   ),
                                                              // ),
                                                            ),
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                                                                      future: FirebaseFirestore.instance.collection('users').doc(reviewlist[index].email).get(),
                                                                      builder: (context, snapshot) {
                                                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                                                          return  CircleAvatar(
                                                                              backgroundColor: Colors.indigo[600],
                                                                              radius: 19,
                                                                              backgroundImage:NetworkImage("https://cdn-icons-png.flaticon.com/512/9131/9131590.png"));

                                                                        } else if (snapshot.hasError) {
                                                                          return  CircleAvatar(
                                                                              backgroundColor: Colors.indigo[600],
                                                                              radius: 19,
                                                                              backgroundImage:NetworkImage("https://cdn-icons-png.flaticon.com/512/9131/9131590.png"));

                                                                        } else {
                                                                          Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>;
                                                                          String? profileImageUrl = userData['prof_img']; // Assuming 'prof_img' is the field containing the profile image URL
                                                                          return CircleAvatar(
                                                                            radius: 19,
                                                                            backgroundImage: userData['prof_img'] != ""
                                                                                ? NetworkImage(userData['prof_img']) : NetworkImage("https://cdn-icons-png.flaticon.com/512/9131/9131590.png"),
                                                                          );
                                                                        }
                                                                      },
                                                                    ),

                                                                    // CircleAvatar(
                                                                    //   backgroundColor: Colors.blue[800],
                                                                    //   radius: 23,
                                                                    //   backgroundImage: _profileImageUrl != null
                                                                    //       ? NetworkImage(_profileImageUrl!)
                                                                    //       :NetworkImage("https://cdn-icons-png.flaticon.com/512/9131/9131590.png"),
                                                                    //
                                                                    //   // child:Icon(
                                                                    //   //   Icons.person,
                                                                    //   //   size: 25,
                                                                    //   //   color: Colors.white,
                                                                    //   // ),
                                                                    //   // Text(
                                                                    //   //   Utils.getInitials(reviewDoc['name']),
                                                                    //   //   style: TextStyle(
                                                                    //   //       fontSize: 16, color: Colors.white,fontWeight: FontWeight.bold),
                                                                    //   // ),
                                                                    // ),
                                                                    Padding(
                                                                      padding: const EdgeInsets.only(left:14.0,right: 14),
                                                                      child: Column(
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(reviewlist[index].name,style:const  TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                                                                          const Text("",style: TextStyle(color: Colors.black54,fontSize: 14)),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Spacer(),
                                                                    (_isSignedIn && email!="")
                                                                        ?
                                                                    PopupMenuButton<int>(
                                                                      icon: const Icon(FontAwesomeIcons.ellipsisVertical),
                                                                      onSelected: (int value) async {
                                                                        switch (value) {
                                                                          case 1:
                                                                            if(_isSignedIn && email!=""){
                                                                              String? name = await getNameByEmail(email);

                                                                              if (name != null) {
                                                                                print("object");
                                                                                print(reviewlist[index].rating.runtimeType);
                                                                                DocumentSnapshot<Object?> reviewDocument = await FirebaseFirestore.instance
                                                                                    .collection('restrooms')
                                                                                    .doc(widget.document.id)
                                                                                    .collection('reviews')
                                                                                    .doc(reviewlist[index].id)
                                                                                    .get();

                                                                                Navigator.push(
                                                                                  context,
                                                                                  MaterialPageRoute(
                                                                                      builder: (context) => EditRatingPage(
                                                                                        uname:name,
                                                                                        document: widget.document,
                                                                                        post: reviewlist[index].comment, rate:  reviewlist[index].rating.toInt(), reviewDocument: reviewDocument,
                                                                                        uemail: email,)
                                                                                  ),
                                                                                );

                                                                                print('Name associated with $email is: $name');
                                                                              } else {
                                                                                print('No name found for email: $email');
                                                                              }
                                                                            }
                                                                            else{
                                                                              showDialog(context: context, builder: (BuildContext context) {
                                                                                return AlertDialog(
                                                                                  title: const Text("You need to SignUp first"),
                                                                                  content: const Text("Click on SignUp button if you want to edit review"),
                                                                                  actions: <Widget>[
                                                                                    TextButton(
                                                                                      onPressed: () {
                                                                                        Navigator.of(context).pop();
                                                                                      },
                                                                                      child: const Text("Leave"),
                                                                                    ),
                                                                                    TextButton(
                                                                                      onPressed: () async {
                                                                                        Navigator.pushReplacement(
                                                                                            context,
                                                                                            MaterialPageRoute(
                                                                                                builder: (context) => UserLoginPage()
                                                                                              //         SignupPageUser
                                                                                            ));


                                                                                      },
                                                                                      child: const Text("SignUp"),
                                                                                    ),
                                                                                  ],
                                                                                );
                                                                              },);
                                                                            }

                                                                            break;
                                                                          case 2:
                                                                            if(_isSignedIn && email!=""){
                                                                              String? name = await getNameByEmail(email);

                                                                              if (name != null) {
                                                                                showDialog(
                                                                                  context: context,
                                                                                  builder: (BuildContext context) {
                                                                                    return AlertDialog(
                                                                                      title: const Text("Delete Review"),
                                                                                      content: const Text("Are you sure you want to delete this review?"),
                                                                                      actions: <Widget>[
                                                                                        TextButton(
                                                                                          onPressed: () {
                                                                                            Navigator.of(context).pop();
                                                                                          },
                                                                                          child: const Text("No"),
                                                                                        ),
                                                                                        TextButton(
                                                                                          onPressed: () async {
                                                                                            // Delete review
                                                                                            await FirebaseFirestore.instance
                                                                                                .collection('restrooms')
                                                                                                .doc(widget.document.id)
                                                                                                .collection('reviews')
                                                                                                .doc(reviewlist[index].id)
                                                                                                .delete();

                                                                                            //user no_of_review update
                                                                                            DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(email);
                                                                                            await userRef.update({'no_of_reviews': FieldValue.increment(-1)});
                                                                                            print("updated user no_of review success");


                                                                                            //update NO. OF REVIEWS
                                                                                            QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                                                                                                .collection('restrooms')
                                                                                                .doc(widget.document.id)
                                                                                                .collection('reviews')
                                                                                                .get();


                                                                                            int reviewsLength = querySnapshot.docs.length;
                                                                                            print('Number of reviews: $reviewsLength');
                                                                                            FirebaseFirestore.instance
                                                                                                .collection('restrooms')
                                                                                                .doc(widget.document.id).set({
                                                                                              'no_of_reviews':reviewsLength ,
                                                                                            }, SetOptions(merge: true));
                                                                                            // get_review(widget.id);
                                                                                            Navigator.of(context).pop();
                                                                                          },
                                                                                          child: const Text("Yes"),
                                                                                        ),
                                                                                      ],
                                                                                    );
                                                                                  },
                                                                                );
                                                                              } else {
                                                                                print('No name found for email: $email');
                                                                              }


                                                                            }
                                                                            else{
                                                                              showDialog(context: context, builder: (BuildContext context) {
                                                                                return AlertDialog(
                                                                                  title: const Text("You need to Signup first"),
                                                                                  content: const Text("Click on login button if you want to edit review"),
                                                                                  actions: <Widget>[
                                                                                    TextButton(
                                                                                      onPressed: () {
                                                                                        Navigator.of(context).pop();
                                                                                      },
                                                                                      child: const Text("Leave"),
                                                                                    ),
                                                                                    TextButton(
                                                                                      onPressed: () async {
                                                                                        Navigator.pushReplacement(
                                                                                            context,
                                                                                            MaterialPageRoute(
                                                                                                builder: (context) => UserLoginPage()
                                                                                              //         SignupPageUser
                                                                                            ));


                                                                                      },
                                                                                      child: const Text("SignUp"),
                                                                                    ),
                                                                                  ],
                                                                                );
                                                                              },);
                                                                            }

                                                                            break;
                                                                        }
                                                                      },
                                                                      itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[


                                                                        PopupMenuItem<int>(
                                                                          value: 1,
                                                                          height: 40,
                                                                          enabled: reviewlist[index].email == email,
                                                                          child: Row(
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            children: [
                                                                              const Icon(Icons.edit,color: Colors.indigo,size: 24,),
                                                                              const SizedBox(width: 8,),
                                                                              Flexible(child: Text('Edit',style: TextStyle(fontWeight: FontWeight.w600,fontSize: 16,color: reviewlist[index].email == email ? Colors.indigo[900] : Colors.grey),)),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        PopupMenuItem<int>(
                                                                          value: 2,
                                                                          height: 40,
                                                                          enabled: reviewlist[index].email == email,
                                                                          child: Row(
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            children: [
                                                                              const Icon(Icons.delete_forever,color: Colors.indigo,size: 24,),
                                                                              const SizedBox(width: 8,),
                                                                              Flexible(child: Text('Delete',style: TextStyle(fontWeight: FontWeight.w600,fontSize: 16,color: reviewlist[index].email == email ? Colors.indigo[900] : Colors.grey),)),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        // PopupMenuItem<int>(
                                                                        //   value: 3,
                                                                        //   height: 40,
                                                                        //   child: Row(
                                                                        //     mainAxisAlignment: MainAxisAlignment.start,
                                                                        //     children: [
                                                                        //       Icon(Icons.report,color: Colors.indigo,size: 24,),
                                                                        //       SizedBox(width: 8,),
                                                                        //       Flexible(child: Text('Report',style: TextStyle(fontWeight: FontWeight.w600,fontSize: 16,color:Colors.indigo[900]),)),
                                                                        //     ],
                                                                        //   ),
                                                                        // ),
                                                                      ],
                                                                    )
                                                                        :
                                                                    IconButton(
                                                                      icon:const Icon(FontAwesomeIcons.ellipsisVertical,size: 18,),
                                                                      onPressed: () {
                                                                        showDialog(context: context, builder: (BuildContext context) {
                                                                          return AlertDialog(
                                                                            title: const Text("You need to Login first"),
                                                                            content: const Text("Click on login button if you want to edit review"),
                                                                            actions: <Widget>[
                                                                              TextButton(
                                                                                onPressed: () {
                                                                                  Navigator.of(context).pop();
                                                                                },
                                                                                child: const Text("Leave"),
                                                                              ),
                                                                              TextButton(
                                                                                onPressed: () async {
                                                                                  Navigator.pushReplacement(
                                                                                      context,
                                                                                      MaterialPageRoute(
                                                                                          builder: (context) => UserLoginPage()
                                                                                        //         SignupPageUser
                                                                                      ));


                                                                                },
                                                                                child: const Text("SignUp"),
                                                                              ),
                                                                            ],
                                                                          );
                                                                        });

                                                                      },
                                                                    )

                                                                  ],
                                                                ),
                                                                const SizedBox(height: 4,),
                                                                Row(
                                                                  children: [
                                                                    RatingBar.builder(
                                                                      initialRating: double.parse('${reviewlist[index].rating}'),
                                                                      itemSize: 15,
                                                                      minRating: 0,
                                                                      direction: Axis.horizontal,
                                                                      allowHalfRating: true,
                                                                      itemCount: 5,
                                                                      // itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                                                                      itemBuilder: (context, _) =>  Icon(
                                                                        Icons.star,
                                                                        color: Colors.amber,
                                                                        // size: 10,
                                                                      ),
                                                                      ignoreGestures: true,
                                                                      onRatingUpdate: (rating) {
                                                                        // rating=rrating;
                                                                        // rrating=rating;
                                                                        print(rating);
                                                                      },
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets.only(left: 12.0),
                                                                      child: Text(getTimeAgo(reviewlist[index].timestamp),style: TextStyle(color: Colors.black54,fontSize: 12),),
                                                                    ),

                                                                  ],
                                                                ),
                                                                const SizedBox(height: 5,),

                                                                Container(
                                                                  width: MediaQuery.of(context).size.width,
                                                                  // height:MediaQuery.of(context).size.height/2,
                                                                  child:
                                                                  EllipsisText(
                                                                    text: "${reviewlist[index].comment}",
                                                                    style:const  TextStyle(fontSize: 15),
                                                                  ),

                                                                ),
                                                                Container(
                                                                  padding: const EdgeInsets.only(top: 3.0),
                                                                  child: Row(

                                                                    children: [
                                                                      IconButton(
                                                                          onPressed: ()async{
                                                                            if(_isSignedIn && email!=""){
                                                                              setState(() {
                                                                                isLiked=!isLiked;
                                                                                if(isLiked & !reviewlist[index].likedBy.contains(email)){
                                                                                  likedBy.add(email);
                                                                                  likesCount += 1;
                                                                                }
                                                                                else{
                                                                                  likedBy.remove(email);
                                                                                  if( likesCount == 0){
                                                                                    likesCount = 0;
                                                                                  }
                                                                                  else{
                                                                                    likesCount -= 1;
                                                                                  }
                                                                                }
                                                                              }

                                                                              );
                                                                              FirebaseFirestore.instance
                                                                                  .collection('restrooms')
                                                                                  .doc(widget.document.id)
                                                                                  .collection('reviews')
                                                                                  .doc(reviewlist[index].id) // Assuming reviewDoc.id is the document ID of the review
                                                                                  .update({
                                                                                'likedBy': likedBy,
                                                                                'likeCounts': likesCount});
                                                                            }
                                                                            else{
                                                                              showDialog(context: context,
                                                                                builder: (BuildContext context) {
                                                                                  return AlertDialog(
                                                                                    title: const Text("You need to Sign-Up first"),
                                                                                    content: const Text(
                                                                                        "Click on Sign-Up button if you want to like review"),
                                                                                    actions: <Widget>[
                                                                                      TextButton(
                                                                                        onPressed: () {
                                                                                          Navigator.of(context).pop();
                                                                                        },
                                                                                        child: const Text("Leave"),
                                                                                      ),
                                                                                      TextButton(
                                                                                        onPressed: () async {
                                                                                          Navigator.pushReplacement(
                                                                                              context,
                                                                                              MaterialPageRoute(
                                                                                                  builder: (context) =>UserLoginPage()
                                                                                                // SignupPageUser()
                                                                                              ));
                                                                                        },
                                                                                        child: const Text("SignUp"),
                                                                                      ),
                                                                                    ],
                                                                                  );
                                                                                },);
                                                                            }
                                                                          },
                                                                          icon:_isSignedIn & reviewlist[index].likedBy.contains(email)
                                                                              ?Icon(Icons.thumb_up,color: Colors.blue[800],)
                                                                              :
                                                                          Icon(Icons.thumb_up_alt_outlined,color: Colors.black54,)

                                                                      ),
                                                                      // SizedBox(width: 5,),
                                                                      Text('${reviewlist[index].likeCounts}'),
                                                                      const SizedBox(width: 8,),
                                                                      const Text("Like",style: TextStyle(fontWeight: FontWeight.bold),)
                                                                    ],
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          );}
                                                    ),
                                                  );

                                                },
                                              ),
                                            ],
                                          ),
                                        )

                                      ],
                                    ),
                                  ),




                                  // Photos Tab Content
                                  SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height:MediaQuery.of(context).size.height,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Center(
                                                  child: Container(
                                                    // height:MediaQuery.of(context).size.width/10,
                                                    margin: const EdgeInsets.only(left: 16,top: 12,right: 16,bottom: 5),
                                                    width: MediaQuery.of(context).size.width/2.6,
                                                    child: MaterialButton(
                                                        elevation: 0,
                                                        onPressed: () async{
                                                          if(_isSignedIn && email!=""){
                                                            String? name = await getNameByEmail(email);

                                                            if (name != null){
                                                              print(" data : ${widget.document['images']}");
                                                              final ImagePicker picker = ImagePicker();

                                                              // Pick image
                                                              final XFile? image = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
                                                              if (image != null) {
                                                                print(" data : ${widget.document['images']}");
                                                                log('Image Path: ${image.path}');
                                                                await sendImage(widget.document.id, widget.document['images'], File(image.path));
                                                              }

                                                            }
                                                            else{
                                                              print("name not found for report issue");

                                                            }
                                                          }
                                                          else{
                                                            showDialog(context: context, builder: (BuildContext context) {
                                                              return AlertDialog(
                                                                title: const Text("You need to SignUp first"),
                                                                content: const Text("Click on login button if you want to give review"),
                                                                actions: <Widget>[
                                                                  TextButton(
                                                                    onPressed: () {
                                                                      Navigator.of(context).pop();
                                                                    },
                                                                    child: const Text("Leave"),
                                                                  ),
                                                                  TextButton(
                                                                    onPressed: () async {
                                                                      Navigator.pushReplacement(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (context) => UserLoginPage()
                                                                            //         SignupPageUser
                                                                          ));


                                                                    },
                                                                    child: const Text("SignUp"),
                                                                  ),
                                                                ],
                                                              );
                                                            },);
                                                          }



                                                        },
                                                        color: Colors.white,
                                                        textColor: Colors.black,
                                                        padding: const EdgeInsets.all(8),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(30),
                                                          side: const BorderSide(
                                                            color: Colors.grey,
                                                            width: 0.5,
                                                          ),
                                                        ),
                                                        child:Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                          children: [
                                                            Icon(Icons.add_a_photo,color: Colors.indigo[700],),
                                                            Text("Add Photos",style: TextStyle(color:Colors.indigo[700],fontSize: 15,),),
                                                          ],)
                                                    ),
                                                  ),
                                                ),
                                                //
                                                Divider(),
                                                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                                                  stream: FirebaseFirestore.instance
                                                      .collection('restrooms')
                                                      .doc(widget.document.id)
                                                      .snapshots(),
                                                  builder: (context, snapshot) {
                                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                                      return const Center(
                                                        child: CircularProgressIndicator(),
                                                      );
                                                    }
                                                    if (snapshot.hasError) {
                                                      return Center(
                                                        child: Text('Error: ${snapshot.error}'),
                                                      );
                                                    }
                                                    if (!snapshot.hasData || snapshot.data!.data() == null) {
                                                      return const Center(
                                                        child: Text('No data available'),
                                                      );
                                                    }

                                                    Map<String, dynamic> data = snapshot.data!.data()!;
                                                    List<String> imageUrls = List<String>.from(data['images'] ?? []);

                                                    if (imageUrls.isEmpty) {
                                                      return Center(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          // mainAxisAlignment: MainAxisAlignment.,
                                                          children: [
                                                            // SizedBox(height: 20,),
                                                            SizedBox(
                                                              height:MediaQuery.of(context).size.height/3,
                                                              child: Lottie.asset("assets/pic.json"),
                                                              // Lottie.network("https://lottie.host/168e3f7a-b3aa-4246-8116-b245913faee8/ny6G3sREHN.json"),
                                                            ),
                                                            // SizedBox(height: 10,),
                                                            Text('No images found.',style:TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                                                          ],
                                                        ),
                                                      );
                                                    }
                                                    return Expanded(
                                                      // height: 500,
                                                      child:
                                                      GridView.builder(
                                                        shrinkWrap: true,
                                                        physics: const ScrollPhysics(),
                                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                          crossAxisCount: 2, // no. of columns
                                                          crossAxisSpacing: 0,
                                                          mainAxisSpacing: 0,
                                                        ),
                                                        itemCount: imageUrls.length,
                                                        itemBuilder: (context, index) {
                                                          return InkWell(
                                                            onTap: () {
                                                              showPhotos(context, imageUrls[index]);
                                                            },
                                                            child: Container(
                                                              margin: EdgeInsets.all(5),
                                                              child: Image.network(
                                                                imageUrls[index],
                                                                fit: BoxFit.cover,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                      // ListView.builder(
                                                      //   itemCount: imageUrls.length,
                                                      //   physics:ScrollPhysics(),
                                                      //   itemBuilder: (context, index) {
                                                      //     return InkWell(
                                                      //       onTap: (){
                                                      //         showPhotos(context, imageUrls[index]);
                                                      //       },
                                                      //       child: Container(
                                                      //         height: 250,
                                                      //         margin: EdgeInsets.only(top: 10,left:12,right:12),
                                                      //         child: Image.network(
                                                      //           imageUrls[index],
                                                      //           fit: BoxFit.cover, // Adjust the fit as needed
                                                      //         ),
                                                      //       ),
                                                      //     );
                                                      //   },
                                                      // ),
                                                    );
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      )

                                  ),

                                ],
                              ),
                            ),


                          ],

                        );}
                    }
                )
            ),

          ),
        ),
    );
  }
  Future<String?> getProfImgByEmail(String email) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first['prof_img'] as String?;
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching prof_img: $e');
      return null;
    }
  }

  void showPhotos(BuildContext context,String url){
    showModalBottomSheet(
        context: context,
        // useSafeArea: false,
        isScrollControlled: true,
        // enableDrag: false,
        builder: (BuildContext context){

      return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
        return Container(
            height: MediaQuery
                .of(context)
                .size
                .height,
                // / 1.38, //1.5 decrease then size increase
            color: Colors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Container(
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                  ),
                ),
                IconButton(onPressed: (){
                  Navigator.pop(context);
                }, icon: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue[50],
                    child: Icon(Icons.close_fullscreen,size: 35,color: Colors.blue[900],))),
              ],
            ),
        );
      });
      });
        }

  Future<List<String>> getImageUrls(String documentId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('restrooms')
          .doc(documentId)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        List<String> imageUrls =
        List<String>.from(data['images'] ?? []);
        return imageUrls;
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching image URLs: $e');
      return [];
    }
  }


  Future<void> sendImage(String restId, List<dynamic> urlsList, File file) async {
    final ext = file.path.split('.').last;
    try{
      final Reference ref = FirebaseStorage.instance.ref().child(
          'images/$restId/${DateTime.now().millisecondsSinceEpoch}.$ext');
      // await ref
      //     .putFile(file, SettableMetadata(contentType: 'image/$ext'))
      //     .then((p0) {
      //   log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
      // });
      // final imageUrl = await ref.getDownloadURL();
      final UploadTask uploadTask = ref.putFile(file);

      await uploadTask.whenComplete(() async {
        final imageUrl = await ref.getDownloadURL();
        print('Image uploaded to Firebase Storage: $imageUrl');
        List<dynamic> imagesList =urlsList??[];
        imagesList.add(imageUrl);

        await FirebaseFirestore.instance
            .collection('restrooms')
            .doc(widget.document.id)
            .update({'images': imagesList});
        _showSuccessDialog(context, "Photo is successfully added");
        print('Image URL saved in Firestore.');
      });
    }
    catch (e, stackTrace) {
    print('Error uploading image: $e');
    print('Stack trace: $stackTrace');
    _showErrorDialog(context, 'Error uploading image: $e');
    }
  }





  String getTimeAgo(Timestamp timestamp) {
    final now = DateTime.now();
    final createdAt = timestamp.toDate();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays >= 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'just now';
    }
  }
  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Can\'t add photos' ),
          content: Text(errorMessage),
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
  }
  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Successfully Added Photo'),
          content: Text(message),
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

}


class ReviewSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 15),
      decoration:const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 1.0,
          ),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 46.0,
                  height: 46.0,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  width: 100.0,
                  height: 15.0,
                  color: Colors.grey[300],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Container(
                    width: 80.0,
                    height: 12.0,
                    color: Colors.grey[300],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 80.0,
              color: Colors.grey[300],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  Container(
                    width: 30.0,
                    height: 30.0,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 30.0,
                    height: 30.0,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 60.0,
                    height: 12.0,
                    color: Colors.grey[300],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
