import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

import 'Profile.dart';

class RatingPage extends StatefulWidget {
  const RatingPage({super.key,required this.uname,required this.document});
final String uname;
final DocumentSnapshot document;

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

  void postReview(String name,int rate,String com,int no) async {
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
                            Utils.getInitials(widget.uname),
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
                          Center(
                            child: Container(
                              margin: EdgeInsets.only(left: 16,top: 18,right: 16),
                              width: MediaQuery.of(context).size.height/4.9,
                              child: MaterialButton(
                                  elevation: 0,
                                  onPressed: () async{
                                    // Navigator.push(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //         builder: (context) => RatingPage(uname: widget.name, document: widget.document,)));

                                  },
                                  color: Colors.white,
                                  textColor: Colors.black,
                                  padding: EdgeInsets.all(12),
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
                                      Icon(Icons.add_a_photo,color: Colors.blue[800],),
                                      Text("Add Photos",style: TextStyle(color:Colors.blue[800],fontSize: 15,),),
                                    ],
                                  )
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
                    postReview(widget.uname, selectedRating, reviewController.text,widget.document['no_of_reviews']);
                    print("no_of reviews : ${widget.document['no_of_reviews']}");
                    int newReview=widget.document['no_of_reviews']+1;
                    print("new reviews : $newReview");
                    FirebaseFirestore.instance
                        .collection('restrooms')
                        .doc(widget.document.id).set({
                      'no_of_reviews':newReview ,
                    }, SetOptions(merge: true));

                    print("object");
                    Navigator.of(context).pop();
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
