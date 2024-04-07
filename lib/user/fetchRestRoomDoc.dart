import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rest_ez_app/user/restroomDetails.dart';

import '../admin/EditRestroomData.dart';
import '../widgets/widget.dart';
import 'Profile.dart';


class FetchRestroom extends StatefulWidget {
  const FetchRestroom({super.key,required this.adminEmail,required this.rest_id, required this.gen});
  final String adminEmail;
  final String rest_id;
  final List<String> gen;

  @override
  State<FetchRestroom> createState() => _FetchRestroomState();
}

class _FetchRestroomState extends State<FetchRestroom> {
  late double avgRating;
  Future<List<String>> getGenderById(String docId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('restrooms')
          .doc(docId)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        List<dynamic> genderList = data['gender'];
        List<String> gender = genderList.cast<String>();
        return gender;
      } else {
        print('Document with ID $docId does not exist.');
        return [];
      }
    } catch (e) {
      print('Error fetching gender: $e');
      return [];
    }
  }

  Future<double> calculateAverageRating() async {
    CollectionReference reviewsRef = FirebaseFirestore.instance
        .collection('restrooms')
        .doc(widget.rest_id) // Assuming widget.id is the ID of the restroom document
        .collection('reviews');

    QuerySnapshot querySnapshot = await reviewsRef.get();

    // Initialize variables to hold the sum of ratings and total number of reviews
    int totalRatings = 0;
    int totalReviews = querySnapshot.size;

    // Iterate through each document to sum up the ratings
    querySnapshot.docs.forEach((reviewDoc) {
      dynamic ratingValue = reviewDoc['rating'];
      if (ratingValue is int) {
        totalRatings += ratingValue;
      } else if (ratingValue is double) {
        totalRatings += ratingValue.toInt();
      } else {

      }
    });

    // Calculate the average rating
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

      // Iterate
      querySnapshot.docs.forEach((reviewDoc) {
        dynamic ratingValue = reviewDoc['rating'];
        if (ratingValue is int) {
          totalRatings += ratingValue;
        } else if (ratingValue is double) {
          totalRatings += ratingValue.toInt();
        } else {
        }
      });

      // Calculate the average rating
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
        .doc(widget.rest_id).collection('reviews');

    QuerySnapshot querySnapshot = await reviewsRef.where('rating', isEqualTo: rate).get();
    // print(querySnapshot.data);
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance.collection('restrooms').doc(widget.rest_id).get();


    int rateDocuments = querySnapshot.docs.length;
    print("rateDocuments$rateDocuments and rate :$rate");
    int totalDocuments=snapshot['no_of_reviews'];
    print('total $totalDocuments');
    if (totalDocuments == 0) {
      return 0.0;
    }



    double value = rateDocuments / totalDocuments;
    // Round the value to one decimal point
    double roundedValue = double.parse(value.toStringAsFixed(1));

    return roundedValue;

  }


  //DELETE
  Future<void> deleteRestroom(String docId) async {
    try {
      CollectionReference restroomsRef = FirebaseFirestore.instance.collection('restrooms');
      await restroomsRef.doc(docId).delete();
      print('Restroom with ID $docId deleted successfully.');
    } catch (e) {
      print('Error deleting restroom: $e');
    }
  }


//MAIN
  Future<DocumentSnapshot<Map<String, dynamic>>> fetchRestroom(String docId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('restrooms')
          .doc(docId)
          .get();
      return snapshot;
    } catch (e) {
      throw Exception('Failed to fetch restroom data: $e');
    }
  }
  Stream<DocumentSnapshot<Map<String, dynamic>>> fetchRestroomStream(String docId) {
    try {
      return FirebaseFirestore.instance
          .collection('restrooms')
          .doc(docId)
          .snapshots();
    } catch (e) {
      throw Exception('Failed to fetch restroom stream: $e');
    }
  }
  //
  @override
  void initState() {
    super.initState();
    String docId = 'ztQP5fpjvZtUNGiduAAz';
    fetchRestroom(docId).then((DocumentSnapshot? snapshot) {
      if (snapshot != null) {
        print('Fetched restroom document: ${snapshot.data()}');
      } else {
        print('Restroom document with ID $docId does not exist.');
      }
    });

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor:Colors.indigo[700],
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          elevation: 3,
          title: RichText(
            text: TextSpan(
                style: const TextStyle(fontSize: 28,
                    // fontFamily: 'El Messiri',
                    fontWeight: FontWeight.bold),
                children: <TextSpan>[
                  const TextSpan(text: 'Rest', style: TextStyle(color: Colors.white)),
                  TextSpan(
                      text: 'Ez', style: TextStyle(color: Colors.tealAccent[100]))
                ]
            ),
          ),
      ),
      body:StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: fetchRestroomStream(widget.rest_id),
      // FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      //   future: fetchRestroom(widget.rest_id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return Center(
              child: Text('No data available'),
            );
          }


          Map<String, dynamic> restroomData = snapshot.data!.data()!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          color: Colors.indigo[50],
                          padding: EdgeInsets.symmetric(vertical: 15,horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Restroom Details ',
                                style: TextStyle(fontWeight: FontWeight.bold,fontSize:16),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 5,bottom: 10),
                                padding: EdgeInsets.symmetric(horizontal: 15,vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                width: double.infinity,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Restroom Name ',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                                    Container(
                                      margin: EdgeInsets.only(top: 2),
                                      padding: EdgeInsets.only(top: 5,left: 10,bottom: 5),
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            width: 1,
                                            color: Colors.black12
                                          ),
                                          borderRadius: BorderRadius.circular(10)
                                        ),
                                        child: Text('${restroomData['name']}',
                                          style: TextStyle(fontSize: 15),
                                          softWrap: true,
                                          overflow: TextOverflow.visible,
                                        )
                                    ),
                                      SizedBox(height: 10,),
                                    Text('Location ',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                                    Container(
                                        margin: EdgeInsets.only(top: 2),
                                        padding: EdgeInsets.only(top: 5,left: 10,bottom: 5),
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 1,
                                                color: Colors.black12
                                            ),
                                            borderRadius: BorderRadius.circular(10)
                                        ),
                                        child: Text('${restroomData['address']}',
                                          style: TextStyle(fontSize: 15),
                                          softWrap: true,
                                          overflow: TextOverflow.visible,
                                        )
                                    ),
                                    SizedBox(height: 10,),

                                    Text('Availability ',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                                    Container(
                                        margin: EdgeInsets.only(top: 2),
                                        padding: EdgeInsets.only(top: 5,left: 10,bottom: 5),
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 1,
                                                color: Colors.black12
                                            ),
                                            borderRadius: BorderRadius.circular(10)
                                        ),
                                        child: Text('${restroomData['availabilityHours']}',
                                          style: TextStyle(fontSize: 15),
                                          softWrap: true,
                                          overflow: TextOverflow.visible,
                                        )
                                    ),
                                    SizedBox(height: 10,),

                                    Text('Accessible For ',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                                    Container(
                                        margin: EdgeInsets.only(top: 2),
                                        padding: EdgeInsets.only(top: 5,left: 10,bottom: 5),
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 1,
                                                color: Colors.black12
                                            ),
                                            borderRadius: BorderRadius.circular(10)
                                        ),
                                        child:

                                        Text(
                                            (() {
                                              String accessibility = '';
                                              String genders = restroomData['gender'].join(', ');

                                              if (restroomData['handicappedAccessible']) {
                                                accessibility += 'Handicap, ';
                                              }
                                              if (genders.isNotEmpty) {
                                                accessibility += genders;
                                              }

                                              return accessibility.isNotEmpty ? accessibility : 'Not specified';
                                            })(),

                                          style: TextStyle(fontSize: 15),
                                          softWrap: true,
                                          overflow: TextOverflow.visible,
                                        )
                                    ),
                                    SizedBox(height: 10,),

                                  ],
                                ),
                              ),
                              SizedBox(height: 5,),
                              Text(
                                'Rating and Reviews ',
                                style: TextStyle(fontWeight: FontWeight.bold,fontSize:16),
                              ),

                              Container(
                                margin: EdgeInsets.only(top: 5,bottom: 10),
                                padding: EdgeInsets.symmetric(horizontal: 15,vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                width: double.infinity,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    //RATING ANALYSIS
                                    Container(
                                      padding: EdgeInsets.only(left: 10,right: 10,bottom: 10,top:10),
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
                                                initialRating: double.parse(restroomData['ratings'].toString()),
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
                                                future: get_review(widget.rest_id),
                                                builder: (context, snapshot) {
                                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                                    // Display a loading indicator while the future is being fetched
                                                    return CircularProgressIndicator();
                                                  } else if (snapshot.hasError) {
                                                    // Display an error message if the future encounters an error
                                                    return Text('Error: ${snapshot.error}');
                                                  } else {
                                                    // Render the widget with the calculated average rating
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
                                    SizedBox(height: 10,),

                                    //REVIEW LIST
                                    Text('Reviews ',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),

                                    SizedBox(height: 10,),
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 2,
                                          color: Colors.black12
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [

                                          StreamBuilder<QuerySnapshot>(
                                            stream: FirebaseFirestore.instance
                                                .collection('restrooms')
                                                .doc(widget.rest_id)
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
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          children: [
                                                            CircleAvatar(
                                                              backgroundColor: Colors.teal[800],
                                                              radius: 23,
                                                              child:
                                                              // Icon(
                                                              //   Icons.person,
                                                              //   size: 25,
                                                              //   color: Colors.white,
                                                              // ),
                                                              Text(
                                                                Utils.getInitials(reviewDoc['name']),
                                                                style: TextStyle(
                                                                    fontSize: 16, color: Colors.white,fontWeight: FontWeight.bold),
                                                              ),
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
                                                              Icon(Icons.thumb_up_alt_outlined,color: Colors.black54,),
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
                                    ),






                                  ],
                                ),
                              ),

                              SizedBox(height: 5,),
                              Text(
                                'Issues Reported ',
                                style: TextStyle(fontWeight: FontWeight.bold,fontSize:16),
                              ),


                              Container(
                                margin: EdgeInsets.only(top: 5,bottom: 10),
                                padding: EdgeInsets.symmetric(horizontal: 15,vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                width: double.infinity,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('No. of Reports ',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                                    Container(
                                        margin: EdgeInsets.only(top: 2),
                                        padding: EdgeInsets.only(top: 5,left: 10,bottom: 5),
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 1,
                                                color: Colors.black12
                                            ),
                                            borderRadius: BorderRadius.circular(10)
                                        ),
                                        child: Text('${restroomData['no_of_reports']}',
                                          style: TextStyle(fontSize: 15),
                                          softWrap: true,
                                          overflow: TextOverflow.visible,
                                        )
                                    ),
                                    SizedBox(height: 10,),


                                  ],
                                ),
                              ),
                              SizedBox(height: 5,),
                              Text(
                                'Photos added ',
                                style: TextStyle(fontWeight: FontWeight.bold,fontSize:16),
                              ),

                              restroomData['images'].length!=0?
                              Container(
                                margin: EdgeInsets.only(top: 5,bottom: 10),
                                padding: EdgeInsets.symmetric(horizontal: 15,vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                width: double.infinity,
                                child: Column(
                                  children: [
                                // int rowCount = (imageUrls.length / crossAxisCount).ceil();
                                    // double totalHeight = MediaQuery.of(context).size.width / crossAxisCount * childAspectRatio * rowCount;

                                    SizedBox(
                                      // height: MediaQuery.of(context).size.width / 2 * 0.5*( (restroomData['images'].length/2).ceil()),
                                      height:MediaQuery.of(context).size.height/4.5,//2.3
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [

                                          Expanded(
                                            child:
                                            GridView.builder(
                                              shrinkWrap: true,
                                              physics: ScrollPhysics(),
                                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 2, // You can adjust the number of columns here
                                                crossAxisSpacing: 0,
                                                mainAxisSpacing: 0,
                                              ),
                                              itemCount: restroomData['images'].length,
                                              itemBuilder: (context, index) {
                                                return InkWell(
                                                  onTap: () {
                                                    print(restroomData['images']);
                                                    showPhotos(context, "${restroomData['images'][index]}",widget.rest_id);
                                                  },
                                                  child: Container(
                                                    margin: EdgeInsets.all(5),
                                                    child: Image.network(
                                                      "${restroomData['images'][index]}",
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),

                                          ),

                                          // SizedBox(height: 10,),


                                        ],
                                      ),
                                    )


                                  ],
                                ),
                              )
                                  :
                              Container(
                                  margin: EdgeInsets.only(top: 5,bottom: 10),
                                  padding: EdgeInsets.symmetric(horizontal: 15,vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  width: double.infinity,
                                  child: Text('No Photos added ',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500),)),


                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                // padding: EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16,vertical: 18),
                      width: MediaQuery.of(context).size.width/3,
                      child: MaterialButton(
                          elevation: 0,
                          onPressed: () async{
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Delete Restroom Data'),
                                  content: Text("Are you sure you want to delete this data"),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.of(context).pop();
                                        deleteRestroom(widget.rest_id);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('${restroomData['name']} is Deleted Succesfully.'),
                                            ));


                                      },
                                      child: Text('Delete'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          color: Colors.indigo[900],
                          textColor: Colors.white,
                          padding: EdgeInsets.all(12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: BorderSide(
                              color: Color(0xFFebf1fa),
                              width: 1.0,
                            ),
                          ),
                          child:Text("Delete ",style: TextStyle(color:Colors.white,fontSize: 20,fontWeight: FontWeight.bold
                          ),)
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16,vertical: 18),
                      width: MediaQuery.of(context).size.width/3,
                      child: MaterialButton(
                          elevation: 0,
                          onPressed: () async{
                            // List<String> gender = restroomData['gender'].cast<String>();
                            // List<String> gender = List<String>.from(restroomData['gender']);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder:
                                  (context) => EditRestroomData(
                                adminEmail: widget.adminEmail,
                                rest_id:widget.rest_id,
                                rest_name:restroomData['name'],
                                address: restroomData['address'],
                                res_hours: restroomData['availabilityHours'],
                                rest_gender:widget.gen,
                                isHandicap: restroomData['handicappedAccessible'],
                                    images: restroomData['images'],
                              ),
                              ),
                            );
                          },
                          color: Colors.indigo[900],
                          textColor: Colors.white,
                          padding: EdgeInsets.all(12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: BorderSide(
                              color: Color(0xFFebf1fa),
                              width: 1.0,
                            ),
                          ),
                          child:Text("Edit ",style: TextStyle(color:Colors.white,fontSize: 20,fontWeight: FontWeight.bold
                          ),)
                      ),
                    ),
                  ],
                ),
              ),
              // Add more details as needed
            ],
          );
        },
      ),
    );

  }


  void showPhotos(BuildContext context,String url,String rest_id){
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
                      fit: BoxFit.cover, // Adjust the fit as needed
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                          onPressed: (){
                        Navigator.pop(context);
                      },
                          icon: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.blue[50],
                          child: Icon(Icons.close_fullscreen,size: 35,color: Colors.blue[900],))),
                      IconButton(
                          onPressed: (){
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Confirm Deletion"),
                              content: Text("Are you sure you want to delete this photo?"),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("No"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Delete photo if user confirms
                                    deletePhoto(url,rest_id);
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("Yes"),
                                ),
                              ],
                            );
                          },
                        );
                        // Navigator.pop(context);
                      }, icon: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.blue[50],
                          child: Icon(Icons.delete,size: 35,color: Colors.blue[900],))),
                    ],
                  ),
                ],
              ),
            );
          });
        });
  }
  Future<void> deletePhoto(String strurl,String doc_id) async {
    try {
      await FirebaseStorage.instance.refFromURL(strurl).delete();



      // Remove photo URL from Firestore document
      await FirebaseFirestore.instance
          .collection('restrooms')
          .doc(doc_id)
          .update({
        'images': FieldValue.arrayRemove([strurl])
      });

      // Show success message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Success"),
            content: Text("Photo deleted successfully"),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Show error message if deletion fails
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Failed to delete photo"),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  print(e.toString());
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
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


  Future<int> get_review(String id)async{
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('restrooms')
        .doc(id)
        .collection('reviews')
        .get();

    int reviewsLength = querySnapshot.docs.length.toInt();
    return reviewsLength;
  }

}
