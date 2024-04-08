import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
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
          title: const Text('Can\'t post' ),
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
          title: const Text('Successfully Posted'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
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

  String? _profileImageUrl;
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
    // fetchRestroomById(widget.id);
    update_no_of_review(widget.id);
    loadProfileImage(widget.uemail);
  }
  @override
  void didChangeDependencies() {
    // fetchRestroomById(widget.id);
    loadProfileImage(widget.uemail);

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
            icon: const Icon(Icons.close)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                          future: FirebaseFirestore.instance.collection('users').doc(widget.uemail).get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return  CircleAvatar(
                                  backgroundColor: Colors.blue[800],
                                  radius: 23,
                                  child: Text(
                                    Utils.getInitials(widget.uname),
                                    style: const TextStyle(
                                        fontSize: 22, color: Colors.white,fontWeight: FontWeight.bold),
                                  ),);
                            } else if (snapshot.hasError) {
                              return  CircleAvatar(
                                  backgroundColor: Colors.blue[800],
                                  radius: 23,
                                  child: Text(
                                  Utils.getInitials(widget.uname),
                            style: const TextStyle(
                            fontSize: 22, color: Colors.white,fontWeight: FontWeight.bold),
                            ),);
                            } else {
                              Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>;
                              // String? profileImageUrl = userData['prof_img'];
                              return userData['prof_img'] != ""
                                  ?
                              CircleAvatar(
                                radius: 23,
                                backgroundImage: NetworkImage(userData['prof_img']),
                              ):
                              CircleAvatar(
                                backgroundColor: Colors.blue[800],
                                radius: 23,
                                child: Text(
                                  Utils.getInitials(widget.uname),
                                  style: const TextStyle(
                                      fontSize: 22, color: Colors.white,fontWeight: FontWeight.bold),
                                ),);

                            }
                          },
                        ),
                        // CircleAvatar(
                        //   backgroundColor: Colors.blue[800],
                        //   radius: 25,
                        //   child: Text(
                        //     Utils.getInitials("${widget.uname}"),
                        //     style: TextStyle(
                        //         fontSize: 22, color: Colors.white,fontWeight: FontWeight.bold),
                        //   ),
                        // ),
                        Padding(
                          padding: const EdgeInsets.only(left:14.0,right: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.uname,style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                              const Text("Posting publicly",style: TextStyle(color: Colors.black54,fontSize: 14)),
                            ],
                          ),
                        )
                      ],
                    ),

                    //STAR TAPPING
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 13),
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
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child:Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(bottom: 12.0),
                            child: Text("Share more about your experience",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                          ),
                          Container(
                            // color: Colors.black54,
                            width:MediaQuery.of(context).size.width ,
                            padding: const EdgeInsets.only(top: 3,left: 12,right: 12,bottom: 40),
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
                              decoration: const InputDecoration(
                                hintText: 'Share details of your own experience at this restroom',
                                border: InputBorder.none,
                                hintMaxLines: 5,
                                contentPadding: EdgeInsets.symmetric(vertical: 6,),
                              ),
                            ),
                          ),
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
                  padding: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(
                      color: Color(0xFFebf1fa),
                      width: 1.0,
                    ),
                  ),
                  child:const Text("Post",style: TextStyle(color:Colors.white,fontSize: 20,fontWeight: FontWeight.bold
                  ),)
              ),
            ),
          ),
        ],
      ),

    );
  }

}
