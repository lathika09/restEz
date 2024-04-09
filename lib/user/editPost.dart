import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'Profile.dart';

class EditRatingPage extends StatefulWidget {
  const EditRatingPage({super.key,required this.uname,required this.document, required this.post, required this.rate, required this.reviewDocument, required this.uemail});
  final String uname;
  final String uemail;
  final DocumentSnapshot document;
  final DocumentSnapshot reviewDocument;
  final String post;
  final int rate;


  @override
  State<EditRatingPage> createState() => _EditRatingPageState();
}

class _EditRatingPageState extends State<EditRatingPage> {
  TextEditingController reviewController = TextEditingController();
  int editselectedRating = 0;
  bool isEditing = false;

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
  // void editpostReview(String name,int rate,String com,int no) async {
  //   if (editselectedRating == 0) {
  //     _showErrorDialog(context, "Give Ratings to make Post");
  //   }
  //
  //   if (com.isEmpty) {
  //     _showErrorDialog(context, "Give Ratings to make Post");
  //   }
  //
  //   try {
  //     await FirebaseFirestore.instance.collection('restrooms').doc(widget.document.id).collection('reviews').add({
  //       'comment': com,
  //       'name': name,
  //       'rating': rate,
  //       'timestamp': Timestamp.now(),
  //       'likeCounts':0,
  //       'likedBy':[],
  //     });
  //
  //
  //
  //   } catch (e) {
  //     print('Error posting review: $e');
  //     _showErrorDialog(context, "Error: ${e.toString()}");
  //
  //   }
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        // backgroundColor: Colors.black,
        elevation: 3,
        title:Text("Edit Review : ${widget.document['name']}"),
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
                        ),

                      ],
                    ),

                    //STAR TAPPING
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 13),
                      child:
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          RatingBar.builder(
                            initialRating: double.parse('${widget.rate}'),
                            itemSize: 45,
                            minRating: 0,
                            direction: Axis.horizontal,
                            // allowHalfRating: true,
                            itemCount: 5,
                            // itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                            itemBuilder: (context, _) =>  const Icon(
                              Icons.star,
                              color: Colors.amber,
                              // size: 10,
                            ),
                            // ignoreGestures: true,
                            onRatingUpdate: (rating) {
                              editselectedRating=rating.toInt();
                              print(rating);

                            },
                          ),


                        ],
                      ),
                    ),
                    Container(
                      // color: Colors.black54,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child:Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Text("Share more about your experience",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                              ),
                              Visibility(
                                visible: !isEditing,
                                child: InkWell(
                                  onTap: (){
                                    setState(() {
                                      isEditing = true;
                                      reviewController.text = widget.post;
                                      reviewController.selection = TextSelection.fromPosition(
                                          TextPosition(offset: reviewController.text.length));
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.only(right: 12.0),
                                    child: const Row(
                                      children: [
                                        Icon(FontAwesomeIcons.pen,size: 12,color: Colors.indigo,),
                                        SizedBox(width: 4,),
                                        Text("Edit",style: TextStyle(color: Colors.indigo,fontSize: 15.5,fontWeight: FontWeight.bold),)
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
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
                            child:
                            isEditing
                                ? TextField(
                              controller: reviewController,
                              maxLines: null,
                              decoration: const InputDecoration(
                                hintText: 'Share details of your own experience at this restroom',
                                border: InputBorder.none,
                                hintMaxLines: 5,
                                contentPadding: EdgeInsets.symmetric(vertical: 6,),
                              ),
                            )
                                : Text(
                              widget.post,
                              style: const TextStyle(fontSize: 16.0),
                            ),

                          ),

                          //ADD PHOTOS
                          // Center(
                          //   child: Container(
                          //     margin:const  EdgeInsets.only(left: 16,top: 18,right: 16),
                          //     width: MediaQuery.of(context).size.height/4.9,
                          //     child: MaterialButton(
                          //         elevation: 0,
                          //         onPressed: () async{
                          //           // Navigator.push(
                          //           //     context,
                          //           //     MaterialPageRoute(
                          //           //         builder: (context) => RatingPage(uname: widget.name, document: widget.document,)));
                          //
                          //         },
                          //         color: Colors.white,
                          //         textColor: Colors.black,
                          //         padding: const EdgeInsets.all(12),
                          //         shape: RoundedRectangleBorder(
                          //           borderRadius: BorderRadius.circular(30),
                          //           side:const BorderSide(
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
              margin: const EdgeInsets.symmetric(horizontal: 16,vertical: 18),
              width: MediaQuery.of(context).size.height/3,
              child: MaterialButton(
                  elevation: 0,
                  onPressed: () async{
                      try {
                        if(reviewController.text!="" && editselectedRating!=0){
                          print("if");
                          await FirebaseFirestore.instance
                              .collection('restrooms')
                              .doc(widget.document.id)
                              .collection('reviews')
                              .doc(widget.reviewDocument.id)
                              .update({
                            'comment': reviewController.text,
                            'rating':editselectedRating,
                            'editedAt':Timestamp.now(),

                          });

                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Review edited successfully!'),
                          ));
                          Navigator.pop(context);
                        }
                        else if(editselectedRating!=0 && reviewController.text==""){
                          print("else if");
                          await FirebaseFirestore.instance
                              .collection('restrooms')
                              .doc(widget.document.id)
                              .collection('reviews')
                              .doc(widget.reviewDocument.id)
                              .update({
                            'comment': widget.post,
                            'rating':editselectedRating,
                            'editedAt':Timestamp.now(),

                          });

                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Review edited rate successfully!'),
                          ));
                          Navigator.pop(context);
                        }
                        else if(editselectedRating==0 && reviewController.text!=""){
                          print(" new else if");
                          await FirebaseFirestore.instance
                              .collection('restrooms')
                              .doc(widget.document.id)
                              .collection('reviews')
                              .doc(widget.reviewDocument.id)
                              .update({
                            'comment':reviewController.text,
                            'rating':widget.rate,
                            'editedAt':Timestamp.now(),

                          });

                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Review edited rate successfully!'),
                          ));
                          Navigator.pop(context);
                        }
                        else if(reviewController.text!=widget.post && reviewController.text!=""){
                          print("2nd else if");
                          await FirebaseFirestore.instance
                              .collection('restrooms')
                              .doc(widget.document.id)
                              .collection('reviews')
                              .doc(widget.reviewDocument.id)
                              .update({
                            'comment': widget.post,
                            'rating':widget.rate,
                            'editedAt':Timestamp.now(),

                          });

                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Review edited review successfully!'),
                          ));
                          Navigator.pop(context);
                        }
                        else{
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Review has not been edited as no change made or no null value can be given!'),
                          ));
                          Navigator.pop(context);
                        }
                      } catch (error) {

                        print('Error updating review: $error');
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Error editing review: $error'),
                          backgroundColor: Colors.red,
                        ));
                      }


                  },
                  color: Colors.blue[700],
                  textColor: Colors.white,
                  padding: EdgeInsets.all(12),
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
