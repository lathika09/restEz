import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import 'Profile.dart';

class RatingPage extends StatefulWidget {
  const RatingPage({super.key,required this.uemail,required this.document, required this.id, required this.uname});
final String uemail;
final String uname;
final DocumentSnapshot document;
final String id;

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  TextEditingController reviewController = TextEditingController();
  int selectedRating = 0;

  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Can\'t post' ),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
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
          title: Text('Successfully Posted'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                // Navigator.pushReplacement(
                //   context,
                //   MaterialPageRoute(builder: (context) => LoginPage()),
                // );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> updateNumberOfReviews(String name) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('name', isEqualTo: name)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot<Map<String, dynamic>> documentSnapshot = querySnapshot.docs.first;


        // int currentNumberOfReviews = documentSnapshot['no_of_reviews'] ?? 0;
        // int updatedNumberOfReviews = currentNumberOfReviews + 1;

        await documentSnapshot.reference.set({'no_of_reviews': FieldValue.increment(1)}, SetOptions(merge: true));

        print('Number of reviews updated successfully for $name');
      } else {
        print('No user found with the name $name');
      }
    } catch (error) {
      print('Error updating number of reviews: $error');
    }
  }


  void postReview(String name,String useremail,int rate,String com,int no) async {
    if (selectedRating == 0) {
      _showErrorDialog(context, "Give Ratings to make Post");
    }

    if (com.isEmpty) {
      _showErrorDialog(context, "Give Ratings to make Post");
    }

    try {
      await FirebaseFirestore.instance.collection('restrooms').doc(widget.document.id).collection('reviews').add({
        'comment': com,
        'name': name,
        'email':useremail,
        'rating': rate,
        'timestamp': Timestamp.now(),
        'likeCounts':0,
        'likedBy':[],
      });



    } catch (e) {
      print('Error posting review: $e');
      _showErrorDialog(context, "Error: ${e.toString()}");

    }
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

  Future<void> sendImage(String restId, List<dynamic> urlsList, File file) async {
    final ext = file.path.split('.').last;
    final ref = FirebaseStorage.instance.ref().child(
        'images/$restId/${DateTime.now().millisecondsSinceEpoch}.$ext');
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });
    final imageUrl = await ref.getDownloadURL();
    List<dynamic> imagesList =urlsList??[];
    imagesList.add(imageUrl);


    await update_imageurl(restId,imagesList);
  }


  Future<void> update_imageurl(String id,List<dynamic> url)async{
    await FirebaseFirestore.instance
        .collection('restrooms')
        .doc(widget.document.id)
        .update({'images': url});

    // FirebaseFirestore.instance
    //     .collection('restrooms')
    //     .doc(id).set({
    //   'images':url ,
    // }, SetOptions(merge: true));

    print("Update image url : $url");
  }
  Future<List<dynamic>> fetchRestroomImagesById(String id) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance.collection('restrooms').doc(id).get();
      if (snapshot.exists) {
        List<dynamic> images = snapshot.data()?['images'];
        return images;
      } else {
        print('Restroom document not found.');
        return [];
      }
    } catch (error) {
      print('Error fetching restroom images: $error');
      return [];
    }
  }
  @override
  void initState() {
    super.initState();
    // fetchRestroomById(widget.id);
    update_no_of_review(widget.id);
  }
  @override
  void didChangeDependencies() {
    // fetchRestroomById(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          // backgroundColor: Colors.black,
          elevation: 3,
          title:Text("${widget.document['name']}"),
        leading: IconButton(
            onPressed: (){
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.close)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20,vertical: 15),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue[800],
                          radius: 25,
                          child: Text(
                            Utils.getInitials("${widget.uname}"),
                            style: TextStyle(
                                fontSize: 22, color: Colors.white,fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left:14.0,right: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${widget.uname}",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                              Text("Posting publicly",style: TextStyle(color: Colors.black54,fontSize: 14)),
                            ],
                          ),
                        )
                      ],
                    ),

                    //STAR TAPPING
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 13),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children:
                        List.generate(5, (index) {
                          int starIndex = index + 1;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedRating = starIndex;
                              });
                              print(selectedRating);
                            },
                            child: Icon(
                              index < selectedRating
                                  ? Icons.star
                                  : Icons.star_border_outlined,
                              size: 45,
                              color: index < selectedRating
                                  ? Colors.amber
                                  : Colors.black54,
                            ),
                          );
                        }),

                      ),
                    ),
                    Container(
                      // color: Colors.black54,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child:Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Text("Share more about your experience",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                          ),
                          Container(
                            // color: Colors.black54,
                            width:MediaQuery.of(context).size.width ,
                            padding: EdgeInsets.only(top: 3,left: 12,right: 12,bottom: 40),
                            height: 200,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.grey.shade50,
                                border: Border.all(
                                  width: 1,
                                  color: Colors.blue.shade400,
                                )
                            ),
                            child: TextField(
                              controller: reviewController,
                              maxLines: null,
                              decoration: InputDecoration(
                                hintText: 'Share details of your own experience at this restroom',
                                border: InputBorder.none,
                                hintMaxLines: 5,
                                contentPadding: EdgeInsets.symmetric(vertical: 6,),
                              ),
                            ),
                          ),

                          //ADD PHOTOS
                          // Center(
                          //   child: Container(
                          //     margin: EdgeInsets.only(left: 16,top: 18,right: 16),
                          //     width: MediaQuery.of(context).size.height/4.9,
                          //     child: MaterialButton(
                          //         elevation: 0,
                          //         onPressed: () async{
                          //           final ImagePicker picker = ImagePicker();
                          //
                          //           // Pick image
                          //           final XFile? image = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
                          //           if (image != null) {
                          //             log('Image Path: ${image.path}');
                          //             await sendImage(widget.id, widget.document['images'], File(image.path));
                          //           }
                          //           // showDialog(
                          //           //   context: context,
                          //           //   builder: (context) {
                          //           //     return AlertDialog(
                          //           //       // title: Text('Add Photos from'),
                          //           //       content: Text('Add Photos from',style: TextStyle(fontSize: 18),),
                          //           //       actions: [
                          //           //
                          //           //         Row(
                          //           //           crossAxisAlignment: CrossAxisAlignment.start,
                          //           //           mainAxisAlignment: MainAxisAlignment.spaceAround,
                          //           //           children: [
                          //           //
                          //           //             TextButton(
                          //           //               onPressed: () async{
                          //           //                 // Navigator.of(context).pop();
                          //           //                 final ImagePicker picker = ImagePicker();
                          //           //                 List<dynamic> imagesList =widget.document['images']??[];
                          //           //                 final List<XFile> images = await picker.pickMultiImage(imageQuality: 70);
                          //           //                 for (var i in images) {
                          //           //                   log('Image Path: ${i.path}');
                          //           //
                          //           //                   await sendImage(widget.id, widget.document['images'], File(i.path));
                          //           //
                          //           //                 }
                          //           //
                          //           //               },
                          //           //               child: Container(
                          //           //                   // width:MediaQuery.of(context).size.width/4,
                          //           //                 padding:EdgeInsets.all(15),
                          //           //                 decoration:BoxDecoration(
                          //           //                   borderRadius: BorderRadius.circular(10),
                          //           //                   border: Border.all(
                          //           //                     width: 1,
                          //           //                     color: Colors.black26
                          //           //                   )
                          //           //                 ),
                          //           //                   child: Column(
                          //           //                     crossAxisAlignment: CrossAxisAlignment.center,
                          //           //                     children: [
                          //           //                       Icon(Icons.photo,size: 30,color: Colors.indigo[900],),
                          //           //                       Text('Gallery',style: TextStyle(color: Colors.indigo[900],fontSize: 15),),
                          //           //                     ],
                          //           //                   )
                          //           //               ),
                          //           //             ),
                          //           //             TextButton(
                          //           //               onPressed: () async {
                          //           //                 Navigator.of(context).pop();
                          //           //                 // setReportStatus(reports[index].id,"Solved",reports[index]['address']);
                          //           //               },
                          //           //               child:Container(
                          //           //                   // width:MediaQuery.of(context).size.width/4,
                          //           //                   padding:EdgeInsets.all(15),
                          //           //                   decoration:BoxDecoration(
                          //           //                       borderRadius: BorderRadius.circular(10),
                          //           //                       border: Border.all(
                          //           //                           width: 1,
                          //           //                           color: Colors.black26
                          //           //                       )
                          //           //                   ),
                          //           //                   child: Column(
                          //           //                     crossAxisAlignment: CrossAxisAlignment.center,
                          //           //                     children: [
                          //           //                       Icon(Icons.camera_alt,size: 30,color: Colors.indigo[900],),
                          //           //                       Text('Camera',style: TextStyle(color: Colors.indigo[900],fontSize: 15),),
                          //           //                     ],
                          //           //                   )
                          //           //               ),
                          //           //             ),
                          //           //           ],
                          //           //         ),
                          //           //       ],
                          //           //     );
                          //           //   },
                          //           // );
                          //
                          //
                          //
                          //
                          //           // Navigator.push(
                          //           //     context,
                          //           //     MaterialPageRoute(
                          //           //         builder: (context) => RatingPage(uname: widget.name, document: widget.document,)));
                          //
                          //         },
                          //         color: Colors.white,
                          //         textColor: Colors.black,
                          //         padding: EdgeInsets.all(12),
                          //         shape: RoundedRectangleBorder(
                          //           borderRadius: BorderRadius.circular(30),
                          //           side: BorderSide(
                          //             color: Color(0xFF979393FF),
                          //             width: 1.0,
                          //           ),
                          //         ),
                          //         child:Row(
                          //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          //           children: [
                          //             Icon(Icons.add_a_photo,color: Colors.blue[800],),
                          //             Text("Add Photos",style: TextStyle(color:Colors.blue[800],fontSize: 15,),),
                          //           ],
                          //         )
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),

                    )

                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16,vertical: 18),
              width: MediaQuery.of(context).size.height/3,
              child: MaterialButton(
                  elevation: 0,
                  onPressed: () async{
                    if (selectedRating == 0) {
                      _showErrorDialog(context, "Give Ratings to make Post");
                    }

                    else if (reviewController.text.isEmpty) {
                      _showErrorDialog(context, "Give Ratings to make Post");
                    }

                    else{
                      try {
                        postReview(widget.uname, widget.uemail,selectedRating, reviewController.text,widget.document['no_of_reviews']);
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

                        updateNumberOfReviews(widget.uname);
                        print("object");

                        _showSuccessDialog(context, "The review was posted publicly successfully!");
                        reviewController.clear();
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        print('Name associated with $widget.uemail is: ${widget.uname}');




                      } catch (error) {
                        print("Error: ${error.toString()}");

                        String errorMessage = "Error posting review: ${error.toString()}";
                        _showErrorDialog(context, errorMessage);
                      }
                    }

                  },
                  color: Colors.blue[700],
                  textColor: Colors.white,
                  padding: EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: BorderSide(
                      color: Color(0xFFebf1fa), // Set the border color
                      width: 1.0,         // Set the border width
                    ),
                  ),
                  child:Text("Post",style: TextStyle(color:Colors.white,fontSize: 20,fontWeight: FontWeight.bold
                  ),)
              ),
            ),
          ),
        ],
      ),

    );
  }

}
