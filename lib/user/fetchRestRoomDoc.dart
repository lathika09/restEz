import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
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
        .doc(widget.rest_id)
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
          iconTheme: const IconThemeData(
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
                          padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Restroom Details ',
                                style: TextStyle(fontWeight: FontWeight.bold,fontSize:16),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 5,bottom: 10),
                                padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                width: double.infinity,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding:  EdgeInsets.only(bottom: 3.0),
                                      child:  Text('Restroom Name ',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(top: 2),
                                      padding: const EdgeInsets.only(top: 5,left: 10,bottom: 5),
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            width: 1,
                                            color: Colors.black12
                                          ),
                                          borderRadius: BorderRadius.circular(10)
                                        ),
                                        child: Text('${restroomData['name']}',
                                          style: const TextStyle(fontSize: 15),
                                          softWrap: true,
                                          overflow: TextOverflow.visible,
                                        )
                                    ),
                                    const SizedBox(height: 10,),
                                    const Padding(
                                      padding:  EdgeInsets.only(bottom: 3.0),
                                      child:  Text('Location ',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                                    ),
                                    Container(
                                        margin: const EdgeInsets.only(top: 2),
                                        padding: const EdgeInsets.only(top: 5,left: 10,bottom: 5),
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 1,
                                                color: Colors.black12
                                            ),
                                            borderRadius: BorderRadius.circular(10)
                                        ),
                                        child: Text('${restroomData['address']}',
                                          style: const TextStyle(fontSize: 15),
                                          softWrap: true,
                                          overflow: TextOverflow.visible,
                                        )
                                    ),
                                    const SizedBox(height: 10,),


                                    const Padding(
                                      padding:  EdgeInsets.only(bottom: 3.0),
                                      child: Text('Availability ',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                                    ),
                                    Container(
                                        margin: const EdgeInsets.only(top: 2),
                                        padding: const EdgeInsets.only(top: 5,left: 10,bottom: 5),
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 1,
                                                color: Colors.black12
                                            ),
                                            borderRadius: BorderRadius.circular(10)
                                        ),
                                        child: Text('${restroomData['availabilityHours']}',
                                          style: const TextStyle(fontSize: 15),
                                          softWrap: true,
                                          overflow: TextOverflow.visible,
                                        )
                                    ),
                                    const SizedBox(height: 10,),

                                    const Padding(padding:  EdgeInsets.only(bottom: 3.0),
                                      child:  Text('Accessible For ',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                                    ),
                                    Container(
                                        margin: const EdgeInsets.only(top: 2),
                                        padding: const EdgeInsets.only(top: 5,left: 10,bottom: 5),
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

                                          style: const TextStyle(fontSize: 15),
                                          softWrap: true,
                                          overflow: TextOverflow.visible,
                                        )
                                    ),
                                    const SizedBox(height: 10,),

                                  ],
                                ),
                              ),
                              const SizedBox(height: 5,),
                              const Text(
                                'Rating and Reviews ',
                                style: TextStyle(fontWeight: FontWeight.bold,fontSize:16),
                              ),

                              Container(
                                margin: const EdgeInsets.only(top: 5,bottom: 10),
                                padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 12),
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
                                      padding: const EdgeInsets.only(left: 10,right: 10,bottom: 10,top:10),
                                      child: Row(
                                        children: [
                                          Column(
                                            children: [
                                              FutureBuilder<double>(
                                                future: calculateAverageRating(),
                                                builder: (context, snapshot) {
                                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                                    return const CircularProgressIndicator();
                                                  } else if (snapshot.hasError) {

                                                    return Text('Error: ${snapshot.error}');
                                                  } else {

                                                    double averageRating = snapshot.data ?? 0;
                                                    avgRating = double.parse((snapshot.data ?? 0).toStringAsFixed(1));
                                                    String formattedAverageRating = averageRating.toStringAsFixed(1);
                                                    // setAverageRating(widget.document.id,avgRating);
                                                    return Text(formattedAverageRating,style: const TextStyle(fontSize: 25,fontWeight: FontWeight.bold),);
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
                                                  // print(rating);
                                                },
                                              ),
                                              FutureBuilder<int>(
                                                future: get_review(widget.rest_id),
                                                builder: (context, snapshot) {
                                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                                    return const CircularProgressIndicator();
                                                  } else if (snapshot.hasError) {
                                                    return Text('Error: ${snapshot.error}');
                                                  } else {
                                                    int reviews = snapshot.data ?? 0;
                                                    String reviewString = reviews.toString();
                                                    return Text('($reviewString)',style: TextStyle());
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
                                                            child: const CircularProgressIndicator()); // Or any other loading widget
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
                                    const SizedBox(height: 10,),

                                    //REVIEW LIST
                                    const Text('Reviews ',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),

                                    const SizedBox(height: 10,),
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
                                                return const Center(child: CircularProgressIndicator());
                                              }
                                              if (snapshot.hasError) {
                                                return Text('Error: ${snapshot.error}');
                                              }
                                              if (!snapshot.hasData ||
                                                  snapshot.data!.docs.isEmpty) {
                                                return const Center(child: Text('No reviews available.'));
                                              }

                                              return Column(
                                                children: snapshot.data!.docs.map((reviewDoc) {
                                                  int likesCount = reviewDoc['likeCounts'];
                                                  List<dynamic> likedBy = reviewDoc['likedBy'] ?? [];
                                                  print(reviewDoc['name']);
                                                  return Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 15),
                                                    decoration: const BoxDecoration(
                                                      border: Border(
                                                        bottom: BorderSide(
                                                          color: Colors.grey,
                                                          width: 1.0,
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
                                                                style: const TextStyle(
                                                                    fontSize: 16, color: Colors.white,fontWeight: FontWeight.bold),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.only(left:14.0,right: 14),
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Text("${reviewDoc['name']}",style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                                                                  const  Text("",style: TextStyle(color: Colors.black54,fontSize: 14)),
                                                                ],
                                                              ),
                                                            ),



                                                          ],
                                                        ),
                                                        const SizedBox(height: 10,),
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
                                                                // size: 10,
                                                              ),
                                                              ignoreGestures: true,
                                                              onRatingUpdate: (rating) {
                                                              },
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.only(left: 12.0),
                                                              child: Text(getTimeAgo(reviewDoc['timestamp']),style: const TextStyle(color: Colors.black54,fontSize: 12),),
                                                            ),

                                                          ],
                                                        ),
                                                        const SizedBox(height: 5,),

                                                        Container(
                                                          width: MediaQuery.of(context).size.width,
                                                          // height:MediaQuery.of(context).size.height/2,
                                                          child:
                                                          EllipsisText(
                                                            text: "${reviewDoc['comment']}",
                                                            style: const TextStyle(fontSize: 15),
                                                          ),

                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.only(top: 8.0),
                                                          child: Row(

                                                            children: [
                                                              const Icon(Icons.thumb_up_alt_outlined,color: Colors.black54,),
                                                              // SizedBox(width: 5,),
                                                              Text('${reviewDoc['likeCounts']}'),
                                                              const SizedBox(width: 8,),
                                                              const Text("Like",style: TextStyle(fontWeight: FontWeight.bold),)
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

                              const SizedBox(height: 5,),
                              const Text(
                                'Issues Reported ',
                                style: TextStyle(fontWeight: FontWeight.bold,fontSize:16),
                              ),


                              Container(
                                margin: const EdgeInsets.only(top: 5,bottom: 10),
                                padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                width: double.infinity,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('No. of Reports ',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                                    Container(
                                        margin: const EdgeInsets.only(top: 2),
                                        padding: const EdgeInsets.only(top: 5,left: 10,bottom: 5),
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
                              const SizedBox(height: 5,),
                              const Text(
                                'Photos added ',
                                style: TextStyle(fontWeight: FontWeight.bold,fontSize:16),
                              ),

                              restroomData['images'].length!=0?
                              Container(
                                margin: const EdgeInsets.only(top: 5,bottom: 10),
                                padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 12),
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
                                              physics: const ScrollPhysics(),
                                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 2, // NO. of columns
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
                                        ],
                                      ),
                                    )


                                  ],
                                ),
                              )
                                  :
                              Container(
                                  margin:const  EdgeInsets.only(top: 5,bottom: 10),
                                  padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  width: double.infinity,
                                  child: const Text('No Photos added ',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500),)),


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
                      margin: const EdgeInsets.symmetric(horizontal: 16,vertical: 18),
                      width: MediaQuery.of(context).size.width/3,
                      child: MaterialButton(
                          elevation: 0,
                          onPressed: () async{
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Delete Restroom Data'),
                                  content: const Text("Are you sure you want to delete this data"),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Cancel'),
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
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          color: Colors.indigo[900],
                          textColor: Colors.white,
                          padding: const EdgeInsets.all(12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: const BorderSide(
                              color: Color(0xFFebf1fa),
                              width: 1.0,
                            ),
                          ),
                          child:const Text("Delete ",style: TextStyle(color:Colors.white,fontSize: 20,fontWeight: FontWeight.bold
                          ),)
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16,vertical: 18),
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
                          padding: const EdgeInsets.all(12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: const BorderSide(
                              color: Color(0xFFebf1fa),
                              width: 1.0,
                            ),
                          ),
                          child:const Text("Edit ",style: TextStyle(color:Colors.white,fontSize: 20,fontWeight: FontWeight.bold
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
                      fit: BoxFit.cover,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                          onPressed: (){
                        Navigator.pop(context);
                      },
                          icon: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Color.fromRGBO(20, 38, 162, 1), // Border color
                                width: 0.6, // Border width
                              ),
                            ),
                            child: CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.blue[50],
                            child: Icon(Icons.close_fullscreen,size: 30,color: Colors.blue[900],)),
                          )),
                      IconButton(
                          onPressed: (){
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Confirm Deletion"),
                              content:const  Text("Are you sure you want to delete this photo?"),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("No"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    deletePhoto(url,rest_id);
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("Yes"),
                                ),
                              ],
                            );
                          },
                        );
                        // Navigator.pop(context);
                      }, icon: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Color.fromRGBO(20, 38, 162, 1), // Border color
                            width: 0.6, // Border width
                          ),
                        ),
                        child: CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.blue[50],
                            child: Icon(Icons.delete,size: 30,color: Colors.blue[900],)),
                      )),
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
      await FirebaseFirestore.instance
          .collection('restrooms')
          .doc(doc_id)
          .update({
        'images': FieldValue.arrayRemove([strurl])
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Success"),
            content: const Text("Photo deleted successfully"),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: const Text("Failed to delete photo"),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  print(e.toString());
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
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
