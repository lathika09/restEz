import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rest_ez_app/user/RatingsPage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rest_ez_app/user/editPost.dart';
import 'package:rest_ez_app/user/reportIssue.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../model/model.dart';
import '../widgets/widget.dart';
import 'Profile.dart';

class RestroomPageUser extends StatefulWidget {
  const RestroomPageUser({Key? key,
    required this.document,required this.dist,required this.pos,required this.restroomloc,required this.name,
  });

  final DocumentSnapshot document;
  final String dist;
  final Position pos;
  final LatLng restroomloc;
  final String name;
  // final String id;

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
  @override
  void initState() {
    super.initState();
    fetchRestroomById(widget.document.id);
    update_no_of_review(widget.document.id);
    print("${widget.document['no_of_reviews']}");
    setAverageRating(widget.document.id);
    print("priny : $restRoomData");
  }

  @override
  void didChangeDependencies() {
    fetchRestroomById(widget.document.id);
    update_no_of_review(widget.document.id);
    print("${widget.document['no_of_reviews']}");
  }

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.document['name'],style: TextStyle(fontWeight: FontWeight.bold,fontSize: 24),),
                Row(
                  children: [
                    Text("${widget.document['ratings']}",style: TextStyle(fontSize: 16)),
                    RatingBar.builder(
                      initialRating: double.parse(widget.document['ratings'].toString()),
                      itemSize: 20,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      ignoreGestures: true,
                      // itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) =>  Icon(
                        Icons.star,
                        color: Colors.amber,
                        // size: 10, // Adjust the size of the stars as needed
                      ),
                      onRatingUpdate: (rating) {
                        print(rating);
                        // You can update the rating here if needed
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text("Public Restroom ",style: TextStyle(fontSize: 16)),
                    SizedBox(width: 10,),
                    Icon(Icons.social_distance),
                    Text('  ${widget.dist} km ',style: TextStyle(fontSize: 16))
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    MaterialButton(
                        elevation: 0,
                        onPressed: () {
                          navigateToRestroom(widget.pos, widget.restroomloc);
                        },
                        color: Colors.blue[700],
                        textColor: Colors.white,
                        padding: EdgeInsets.all(8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(
                            color: Color(0xFFebf1fa),
                            width: 1.0,
                          ),
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 6,vertical: 4),
                          child: Row(
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
                          print("In onPResed");
                          print("object : $restRoomData");
                          List<dynamic> savedBy =restRoomData['savedBy']??[];
                          print("hish");
                          print(savedBy);
                          print("before bookmark");
                          Bookmark(savedBy);
                          print("after bookmark");
                          bool isFav = savedBy.contains(widget.name)??false;
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
                              savedBy.remove(widget.name);
                            }
                            else{
                              print("is saved true ADDED");
                              savedBy.add(widget.name);
                            }
                            print("SET END");
                            print(widget.name);

                          });

                        },
                        color: Colors.white,
                        textColor: Colors.blue[700],
                        padding: EdgeInsets.all(8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1.0,
                          ),
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 6,vertical: 4),
                          child: Row(
                            children: [
                              // restRoomData['savedBy'].contains("Hari Kumar")==true
                              //     ?Icon(Icons.bookmark,color: Colors.indigo,)
                              //     :Icon(Icons.bookmark_border,color: Colors.blue[700],),
                              FutureBuilder<List<dynamic>>(
                                future: getSavedBy(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {

                                    bool isSaved = snapshot.data?.contains(widget.name) ?? false;

                                    return isSaved
                                        ? Icon(Icons.bookmark, color: Colors.indigo)
                                        : Icon(Icons.bookmark_border, color: Colors.blue[700]);
                                  }
                                },
                              ),


                              Text(
                                "Save",
                                style: TextStyle(
                                    color: Colors.blue[700],
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        )
                    ),
                    MaterialButton(
                        elevation: 0,

                        onPressed: () {
                          List<dynamic> savedBy =widget.document['savedBy']??[];
                          print(savedBy);
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => GetJobRef_ConPage(),
                          //   ),
                          // );
                        },
                        color: Colors.white,
                        textColor: Colors.blue[700],
                        padding: EdgeInsets.all(8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1.0,
                          ),
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 6,vertical: 4),
                          child: Row(
                            children: [
                              Icon(Icons.share,color: Colors.blue[700],),
                              Text(
                                "Share",
                                style: TextStyle(
                                    color: Colors.blue[700],
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
                  margin: EdgeInsets.symmetric(vertical: 10),
                  height: 1,
                  color: Colors.grey[300],),
                TabBar(
                    indicatorColor: Colors.blue[800],
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorWeight: 2,
                    unselectedLabelStyle: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                        fontSize: 18),
                    labelStyle: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 16),
                    tabs: [
                      Tab(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "About",
                            style: TextStyle(),
                          ),
                        ),
                      ),
                      Tab(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Reviews",
                            style: TextStyle(),
                          ),
                        ),
                      ),
                      Tab(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
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
                              padding: const EdgeInsets.only(left:12,right:10,bottom:8,top: 15.0),
                              child: Row(
                                children: [
                                  Icon(Icons.groups,color: Colors.blue[900],),
                                  Expanded(
                                    child: Container(
                                      width: MediaQuery.of(context).size.width/1.5,
                                      padding: const EdgeInsets.only(left: 20.0,right:10),
                                      child: Row(
                                        children: [
                                          widget.document['handicappedAccessible']
                                              ?Text(
                                            'Female , Male, Handicapped',
                                            style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400,)
                                            ,overflow: TextOverflow.visible,softWrap: true,
                                          )
                                          :
                                          Text(
                                            'Female , Male',
                                            style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400,)
                                            ,overflow: TextOverflow.visible,softWrap: true,
                                          ),

                                        ],
                                      ),
                                    ),
                                  ),


                                ],
                              ),
                            ),
                            Divider(),
                            Padding(
                              padding: const EdgeInsets.only(left:12,right:10,bottom:8,top: 15.0),
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
                                            style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400,color: Colors.black)
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
                              onTap: (){
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(builder:
                                        (context) => ReportIssues(uname: widget.name, rest_id:widget.document.id, adminEmail: widget.document['handledBy'], restAddress:widget.document['address'], restName: widget.document['name'],),
                                    ),
                                );


                              },
                              child: Padding(
                                padding: const EdgeInsets.only(left:12,right:10,bottom:8,top: 15.0),
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
                              padding: EdgeInsets.only(left: 12,right: 12,bottom: 10,top:18),
                              child: Row(
                                children: [
                                  Column(
                                    children: [
                                      FutureBuilder<double>(
                                        future: calculateAverageRating(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                            return CircularProgressIndicator();
                                          } else if (snapshot.hasError) {

                                            return Text('Error: ${snapshot.error}');
                                          } else {

                                            double averageRating = snapshot.data ?? 0;
                                            avgRating = double.parse((snapshot.data ?? 0).toStringAsFixed(1));
                                            String formattedAverageRating = averageRating.toStringAsFixed(1);
                                            // setAverageRating(widget.document.id,avgRating);
                                            return Text(formattedAverageRating,style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),);
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
                                          // size: 10, // Adjust the size of the stars as needed
                                        ),
                                        onRatingUpdate: (rating) {
                                          print(rating);


                                          // You can update the rating here if needed
                                        },
                                      ),
                                      FutureBuilder<int>(
                                        future: get_review(widget.document.id),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                            return CircularProgressIndicator();
                                          } else if (snapshot.hasError) {
                                            return Text('Error: ${snapshot.error}');
                                          } else {
                                            int reviews = snapshot.data ?? 0;
                                            String reviewString = reviews.toString();
                                            return Text('(${reviewString})',style: TextStyle());
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
                                                // While waiting for the future to complete, show a loading indicator or placeholder.
                                                return Container(
                                                    height: 20,
                                                    width: 20,
                                                    child: CircularProgressIndicator()); // Or any other loading widget
                                              } else if (snapshot.hasError) {
                                                // If the future throws an error, show an error message.
                                                return Text('Error: ${snapshot.error}');
                                              } else {
                                                // If the future completes successfully, use the data to build the UI.
                                                return RatingProgress(text: rate.toString(), value: (snapshot.data ?? 0.0));
                                              }
                                            },
                                          ),
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
                                  Text("Rate and Review",style: TextStyle(fontSize: 19,fontWeight: FontWeight.bold),),
                                  Text("Share your experience to help others",style: TextStyle(fontSize: 14,color: Colors.black54),),
                                  SizedBox(height: 8,),
                                  InkWell(
                                    onTap: (){
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => RatingPage(uname: widget.name, document: widget.document, id: widget.document.id,)));

                                    },
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Colors.red[900],
                                          radius: 26,
                                          child: Text(
                                            Utils.getInitials(widget.name),
                                            style: TextStyle(
                                                fontSize: 22, color: Colors.white,fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        SizedBox(width: 20,),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children:
                                          List.generate(5, (index) {
                                            int starIndex = index + 1;
                                            return Icon(
                                              Icons.star_border_outlined,
                                              size: 40,
                                              color:Colors.black54,
                                            );
                                          }),

                                        ),
                                      ],
                                    ),
                                  ),
                                  Center(
                                    child: Container(
                                      margin: EdgeInsets.only(left: 16,top: 8,right: 16),
                                      width: MediaQuery.of(context).size.width/2,
                                      child: MaterialButton(
                                          elevation: 0,
                                          onPressed: () async{
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => RatingPage(uname: widget.name, document: widget.document, id: widget.document.id,)));

                                          },
                                          color: Colors.white,
                                          textColor: Colors.black,
                                          padding: EdgeInsets.all(8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30),
                                            side: BorderSide(
                                              color: Color(0xFF979393FF), // Set the border color
                                              width: 1.0,         // Set the border width
                                            ),
                                          ),
                                          child:Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Icon(Icons.edit_note_outlined,color: Colors.blue[800],),
                                              Text("Write a review",style: TextStyle(color:Colors.black,fontSize: 15,),),
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
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12.0),
                                    child: Text("Reviews",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                                  ),
                                  StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('restrooms')
                                        .doc(widget.document.id)
                                        .collection('reviews')
                                        .snapshots(),
                                    builder: (context, snapshot) {

                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Center(child: CircularProgressIndicator());
                                      }
                                      if (snapshot.hasError) {
                                        return Text('Error: ${snapshot.error}');
                                      }
                                      if (!snapshot.hasData ||
                                          snapshot.data!.docs.isEmpty) {
                                        return Center(child: Text('No reviews available.'));
                                      }
                                      // Display the reviews

                                      return Column(
                                        children: snapshot.data!.docs.map((reviewDoc) {
                                          int likesCount = reviewDoc['likeCounts'];
                                          List<dynamic> likedBy = reviewDoc['likedBy'] ?? [];
                                          print(reviewDoc['name']);
                                          return Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 15),
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: Colors.grey, // Choose your border color
                                                  width: 1.0, // Adjust the border width as needed
                                                ),
                                              ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    CircleAvatar(
                                                      backgroundColor: Colors.blue[800],
                                                      radius: 23,
                                                      child:Icon(
                                                        Icons.person,
                                                        size: 25,
                                                        color: Colors.white,
                                                      ),
                                                      // Text(
                                                      //   Utils.getInitials(reviewDoc['name']),
                                                      //   style: TextStyle(
                                                      //       fontSize: 16, color: Colors.white,fontWeight: FontWeight.bold),
                                                      // ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.only(left:14.0,right: 14),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text("${reviewDoc['name']}",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                                                          Text("",style: TextStyle(color: Colors.black54,fontSize: 14)),
                                                        ],
                                                      ),
                                                    ),
                                                    Spacer(),
                                                    PopupMenuButton<int>(
                                                      icon: Icon(FontAwesomeIcons.ellipsisVertical),
                                                      onSelected: (int value) {
                                                        // Handle menu option selection
                                                        switch (value) {
                                                          case 1:
                                                            print("object");
                                                            print(reviewDoc['rating'].runtimeType);
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (context) => EditRatingPage(
                                                                    uname: widget.name,
                                                                    document: widget.document,
                                                                    post: reviewDoc['comment'], rate:  reviewDoc['rating'].toInt(), reviewDocument: reviewDoc,)
                                                              ),
                                                            );
                                                            break;
                                                          case 2:
                                                            showDialog(
                                                              context: context,
                                                              builder: (BuildContext context) {
                                                                return AlertDialog(
                                                                  title: Text("Delete Review"),
                                                                  content: Text("Are you sure you want to delete this review?"),
                                                                  actions: <Widget>[
                                                                    TextButton(
                                                                      onPressed: () {
                                                                        Navigator.of(context).pop();
                                                                      },
                                                                      child: Text("No"),
                                                                    ),
                                                                    TextButton(
                                                                      onPressed: () async {
                                                                        // Delete review
                                                                        await FirebaseFirestore.instance
                                                                            .collection('restrooms')
                                                                            .doc(widget.document.id)
                                                                            .collection('reviews')
                                                                            .doc(reviewDoc.id)
                                                                            .delete();

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
                                                                      child: Text("Yes"),
                                                                    ),
                                                                  ],
                                                                );
                                                              },
                                                            );

                                                            break;
                                                          case 3:
                                                          // Option 2 selected
                                                            break;
                                                        }
                                                      },
                                                      itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                                                        PopupMenuItem<int>(
                                                          value: 1,
                                                          height: 40,
                                                          enabled: reviewDoc['name'] == widget.name,
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: [
                                                              Icon(Icons.edit,color: Colors.indigo,size: 24,),
                                                              SizedBox(width: 8,),
                                                              Flexible(child: Text('Edit',style: TextStyle(fontWeight: FontWeight.w600,fontSize: 16,color: reviewDoc['name'] == widget.name ? Colors.indigo[900] : Colors.grey),)),
                                                            ],
                                                          ),
                                                        ),
                                                        PopupMenuItem<int>(
                                                          value: 2,
                                                          height: 40,
                                                          enabled: reviewDoc['name'] == widget.name,
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: [
                                                              Icon(Icons.delete_forever,color: Colors.indigo,size: 24,),
                                                              SizedBox(width: 8,),
                                                              Flexible(child: Text('Delete',style: TextStyle(fontWeight: FontWeight.w600,fontSize: 16,color: reviewDoc['name'] == widget.name ? Colors.indigo[900] : Colors.grey),)),
                                                            ],
                                                          ),
                                                        ),
                                                        PopupMenuItem<int>(
                                                          value: 3,
                                                          height: 40,
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: [
                                                              Icon(Icons.report,color: Colors.indigo,size: 24,),
                                                              SizedBox(width: 8,),
                                                              Flexible(child: Text('Report',style: TextStyle(fontWeight: FontWeight.w600,fontSize: 16,color:Colors.indigo[900]),)),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    )

                                                  ],
                                                ),
                                                SizedBox(height: 10,),
                                                Row(
                                                  children: [
                                                     RatingBar.builder(
                                                      initialRating: double.parse('${reviewDoc['rating']}'),
                                                      itemSize: 15,
                                                      minRating: 0,
                                                      direction: Axis.horizontal,
                                                      allowHalfRating: true,
                                                      itemCount: 5,
                                                      // itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                                                      itemBuilder: (context, _) =>  Icon(
                                                        Icons.star,
                                                        color: Colors.amber,
                                                        // size: 10, // Adjust the size of the stars as needed
                                                      ),
                                                      ignoreGestures: true,
                                                      onRatingUpdate: (rating) {
                                                        // rating=rrating;
                                                        // rrating=rating;
                                                        print(rating);
                                                        // You can update the rating here if needed
                                                      },
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 12.0),
                                                      child: Text(getTimeAgo(reviewDoc['timestamp']),style: TextStyle(color: Colors.black54,fontSize: 12),),
                                                    ),

                                                  ],
                                                ),
                                                SizedBox(height: 5,),

                                                Container(
                                                    width: MediaQuery.of(context).size.width,
                                                    // height:MediaQuery.of(context).size.height/2,
                                                    child:
                                                    EllipsisText(
                                                      text: "${reviewDoc['comment']}",
                                                      style: TextStyle(fontSize: 15),
                                                    ),

                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 8.0),
                                                  child: Row(

                                                    children: [
                                                      IconButton(
                                                        onPressed: (){
                                                          setState(() {
                                                            isLiked=!isLiked;
                                                            if(isLiked & !reviewDoc['likedBy'].contains(widget.name)){
                                                              likedBy.add(widget.name);
                                                              likesCount += 1;
                                                            }
                                                            else{
                                                              likedBy.remove(widget.name);
                                                              if( likesCount == 0){
                                                                likesCount = 0;
                                                              }
                                                              else{
                                                                likesCount -= 1;
                                                              }
                                                            }
                                                          });
                                                          FirebaseFirestore.instance
                                                              .collection('restrooms')
                                                              .doc(widget.document.id)
                                                              .collection('reviews')
                                                              .doc(reviewDoc.id) // Assuming reviewDoc.id is the document ID of the review
                                                              .update({
                                                            'likedBy': likedBy,
                                                            'likeCounts': likesCount});
                                                        },
                                                        icon:reviewDoc['likedBy'].contains(widget.name)
                                                            ?Icon(Icons.thumb_up,color: Colors.blue[800],)
                                                        :
                                                        Icon(Icons.thumb_up_alt_outlined,color: Colors.black54,)

                                                      ),
                                                      // SizedBox(width: 5,),
                                                      Text('${reviewDoc['likeCounts']}'),
                                                      SizedBox(width: 8,),
                                                      Text("Like",style: TextStyle(fontWeight: FontWeight.bold),)
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            )


                            // Add more widgets as needed
                          ],
                        ),
                      ),
                      // Photos Tab Content
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            Text('Photos Tab Content'),
                            // Add more widgets as needed
                          ],
                        ),
                      ),

                    ],
                  ),
                ),


              ],

            ),
        ),

      ),
        ),
    );
  }
  String getTimeAgo(Timestamp timestamp) {
    final now = DateTime.now();
    final createdAt = timestamp.toDate(); // Convert Firestore Timestamp to DateTime
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
}
