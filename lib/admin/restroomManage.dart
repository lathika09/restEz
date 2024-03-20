
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geocoding/geocoding.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';

import '../constant/imageString.dart';

class Review {
  final String id;
  final String comment;
  final String name;
  final int rating;
  final Timestamp timestamp;

  Review({
    required this.id,
    required this.comment,
    required this.name,
    required this.rating,
    required this.timestamp,
  });

  factory Review.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Review(
      id: doc.id,
      comment: data['comment'],
      name: data['name'],
      rating: data['rating'],
      timestamp: data['timestamp'],
    );
  }
}
class Report {
  final String id;
  final String user;
  final String desc;
  final String status;
  final Timestamp timestamp;

  Report({
    required this.id,
    required this.user,
    required this.desc,
    required this.status,
    required this.timestamp,
  });

  factory Report.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Report(
      id: doc.id,
      user: data['user'],
      desc: data['desc'],
      status: data['status'],
      timestamp: data['timestamp'],
    );
  }
}

class Restroom {
  final String id;
  final String address;
  final String availabilityHours;
  final List<String> gender;
  final bool handicappedAccessible;
  final String handledBy;
  final GeoPoint location;
  final String name;
  final String? profImg;
  final int ratings;
  final List<Review> reviews;
  final List<Report> reports;
  final int no_of_reviews;
  final int no_of_reports;

  Restroom({
    required this.id,
    required this.address,
    required this.availabilityHours,
    required this.gender,
    required this.handicappedAccessible,
    required this.handledBy,
    required this.location,
    required this.name,
    required this.profImg,
    required this.ratings,
    required this.reviews,
    required this.reports,
    required this.no_of_reviews,
    required this.no_of_reports,
  });

  factory Restroom.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    List<Review> reviews = [];
    List<Report> reports = [];
    int ratingsInt= ( data['ratings'] is int) ?  data['ratings'] : 0;
    int no_of_reviewsInt= ( data['no_of_reviews'] is int) ?  data['no_of_reviews'] : 0;
    int no_of_reportsInt= ( data['no_of_reports'] is int) ?  data['no_of_reports'] : 0;

    if (data['reviews'] != null) {
      reviews = List.from(data['reviews']).map((reviewData) => Review.fromFirestore(reviewData)).toList();
    }
    if (data['reports'] != null) {
      reports = List.from(data['reports']).map((reportData) => Report.fromFirestore(reportData)).toList();
    }
    return Restroom(
      id: doc.id,
      address: data['address'],
      availabilityHours: data['availabilityHours'],
      gender: List<String>.from(data['gender']),
      handicappedAccessible: data['handicappedAccessible'],
      handledBy: data['handledBy'],
      location: data['location'],
      name: data['name'],
      profImg: data['prof_img'],
      ratings: ratingsInt,
      reviews: reviews,
        reports: reports,
        no_of_reviews:no_of_reviewsInt,
        no_of_reports:no_of_reportsInt
    );
  }
}

class ManageRestroom extends StatefulWidget {
  final String adminEmail;

  const ManageRestroom({required this.adminEmail});

  @override
  _ManageRestroomState createState() => _ManageRestroomState(adminEmail);
}

class _ManageRestroomState extends State<ManageRestroom> {
  final String adminEmail;

  _ManageRestroomState(this.adminEmail);



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        title: RichText(
          text: TextSpan(
              style: const TextStyle(fontSize: 28,
                  // fontFamily: 'El Messiri',
                  fontWeight: FontWeight.bold),
              children: <TextSpan>[
                const TextSpan(text: 'Rest', style: TextStyle(color: Colors.black)),
                TextSpan(
                    text: 'Ez', style: TextStyle(color: Colors.blueAccent[700]))
              ]
          ),
        ),
        // actions: [
        //   IconButton(
        //       onPressed: () {
        //         // Navigator.push(context,
        //         //     MaterialPageRoute(builder: (context) => HelpPage()));
        //       },
        //       icon: Icon(
        //         Icons.help,
        //         color: Colors.black,
        //         size: 25,
        //       )),
        //
        //   IconButton(
        //       onPressed: () {
        //         // Navigator.push(
        //         //     context,
        //         //     MaterialPageRoute(
        //         //         builder: (context) => RestroomPageUser()));
        //       },
        //       icon: Icon(
        //         Icons.notifications,
        //         color: Colors.black,
        //         size: 25,
        //       ))
        // ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('restrooms')
            .where('handledBy', isEqualTo: adminEmail)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          List<Restroom> restrooms = snapshot.data!.docs
              .map((doc) => Restroom.fromFirestore(doc))
              .toList();

          return ListView.builder(
            itemCount: restrooms.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => MainChat(
                  //           receiverNm: widget.receiver_nm,
                  //         )));
                },
                child: Column(
                  children: [
                    Card(
                      // margin: EdgeInsets.symmetric(horizontal: 4,vertical: 4),
                      //   padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        // height: MediaQuery.of(context).size.height*0.06,
                        color: Colors.blue[50],
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                          child: Row(
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                //margin: const EdgeInsets.symmetric(vertical: 40),
                                width: MediaQuery.of(context).size.width/6,
                                height: MediaQuery.of(context).size.height/8,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(image: AssetImage(restroom),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  // color: Colors.white,
                                  padding: EdgeInsets.only(left: 10,bottom:5,top: 5),
                                  margin: const EdgeInsets.only(left: 10),
                                  // width: MediaQuery.of(context).size.height*0.,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 3.0),
                                        child: RichText(
                                          text: TextSpan(
                                              style: const TextStyle(fontSize: 15, ),
                                              children: <TextSpan>[
                                                TextSpan(text: 'Name : ', style: TextStyle(color: Colors.indigo[900],fontWeight: FontWeight.w500)),
                                                TextSpan(
                                                    text: restrooms[index].name, style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold))
                                              ]),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 3.0),
                                        child: RichText(
                                          text: TextSpan(
                                              style: const TextStyle(fontSize: 15, ),
                                              children: <TextSpan>[
                                                TextSpan(text: 'Location : ', style: TextStyle(color: Colors.indigo[900],fontWeight: FontWeight.w500)),
                                                TextSpan(
                                                    text: restrooms[index].address, style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold))
                                              ]),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 3.0),
                                        child: Row(
                                          children: [
                                            Text("${restrooms[index].ratings}.0 ",style: const TextStyle(fontSize: 15,fontWeight: FontWeight.w600)),
                                            RatingBar.builder(
                                              initialRating: double.parse(restrooms[index].ratings.toString()),
                                              itemSize: 16,
                                              minRating: 0,
                                              direction: Axis.horizontal,
                                              allowHalfRating: true,
                                              itemCount: 5,
                                              ignoreGestures: true,
                                              // itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                                              itemBuilder: (context, _) =>  const Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                                // size: 10, // Adjust the size of the stars as needed
                                              ),
                                              onRatingUpdate: (rating) {
                                                print(rating);
                                                // You can update the rating here if needed
                                              },
                                            ),
                                            Text("(${restrooms[index].no_of_reviews}) ",style: const TextStyle(fontSize: 15)),
                                          ],
                                        ),
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 3.0),
                                        child:
                                        Text("Issues : ${restrooms[index].no_of_reports} ",style: const TextStyle(fontSize: 15,fontWeight: FontWeight.w600)),

                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        )

                    ),
                    const SizedBox(height: 5,)
                  ],
                ),
              );
              //   ListTile(
              //   title: Text(restrooms[index].name),
              //   subtitle: Text(restrooms[index].address),
              //   // You can display more information about the restroom here
              // );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue.shade900,
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => AddRestroomData(adminEmail: widget.adminEmail,)));
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
          // weight: 4,
          size: 30,
        ),
      ),
    );
  }
}

class AddRestroomData extends StatefulWidget {
  const AddRestroomData({super.key,required this.adminEmail});
  final String adminEmail;

  @override
  State<AddRestroomData> createState() => _AddRestroomDataState();
}

class _AddRestroomDataState extends State<AddRestroomData> {
  String? selectedFilter;
  final List<String> _filterOptions = ['true','false'];


  List<String> selectedGender = [];
  List<MultiSelectItem<String>> genderItems = [
    MultiSelectItem<String>('Female', 'Female'),
    MultiSelectItem<String>('Male', 'Male'),];

  String? selectedHours;
  List<String> availableItems = ['Open for 24 Hours', 'Closed'];


  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  bool isEditing = false;

  Future<Map<String, dynamic>> convertAddressToCoordinates(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);

      if (locations.isNotEmpty) {
        Location firstLocation = locations.first;
        double latitude = firstLocation.latitude;
        double longitude = firstLocation.longitude;
        Map<String, dynamic> coordinates = {
          'latitude': latitude,
          'longitude': longitude,
        };
        return coordinates;
      }

      else {
        throw Exception('No location found for the address.');
      }
    }
    catch (e) {
      print('Error converting address to coordinates: $e');
      throw Exception('Failed to convert address to coordinates.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 3,
          title: const Text("Add Restroom", style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),)
        ),
        body:Column(
            children: [
              Expanded(
                  child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.indigo[100],
                      padding: const EdgeInsets.all(15.0),
                      child: SingleChildScrollView(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 10,right:10),
                                  child: Text("Restroom Details",
                                    style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6.0),
                                  ),
                                  margin: EdgeInsets.symmetric(vertical: 10,horizontal:3),
                                  padding: EdgeInsets.symmetric(vertical: 15,horizontal: 20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Name ',
                                        style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),
                                      ),
                                      Container(
                                        margin: EdgeInsets.symmetric(vertical: 5.0),
                                        padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 0),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(6.0),
                                          color: Colors.indigo[50],
                                          border: Border.all(color: Colors.indigo.shade100,
                                          ),
                                        ),
                                        child: SizedBox(
                                          height: 40,
                                          child: TextField(
                                            controller: nameController,
                                            decoration: const InputDecoration(
                                                labelStyle:TextStyle(fontSize: 16),
                                                hintText: 'ABC ',
                                                border: InputBorder.none, //
                                                contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                                                hintStyle: TextStyle(color: Colors.black54,fontWeight: FontWeight.w500)
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16.0),
                                      const Text(
                                        'Gender Accessible',
                                        style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),
                                      ),
                                      const SizedBox(height: 5,),
                                      AbsorbPointer(
                                        absorbing: false,//used to eanable editing
                                        child: MultiSelectDialogField(
                                          items: genderItems,
                                          itemsTextStyle:TextStyle(fontSize: 16),
                                          selectedColor: Colors.indigo[500],
                                          selectedItemsTextStyle: TextStyle(color: Colors.black,fontSize: 16),
                                          initialValue:selectedGender,
                                          listType: MultiSelectListType.CHIP,
                                          onConfirm: (values) {
                                            setState(() {
                                              selectedGender = values.toList();
                                              // Convert selected weekday strings to integers
                                              // selectedWeekdayIntegers = selectedSlot.map((weekday) => dayNameToValue[weekday]!).toList();
                                            });
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 16.0),
                                      const Text(
                                        'Handicapped Accessible',
                                        style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),
                                      ),
                                      const SizedBox(height: 5,),
                                      SizedBox(
                                        height: 40,
                                        child:Container(
                                          padding: EdgeInsets.symmetric(horizontal: 12.0),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(6.0),
                                            color: Colors.indigo[50],
                                            border: Border.all(color: Colors.indigo.shade100),
                                          ),
                                          child: DropdownButton<String>(
                                            isExpanded: true,
                                            hint: Text('Select an Option'),
                                            underline: Container(
                                              height: 0,
                                              color: Colors.transparent,
                                            ),
                                            value:selectedFilter,
                                            onChanged: (newValue) async {
                                              setState(() {
                                                selectedFilter = newValue as String;
                                              });
                                              if(selectedFilter=='true'){
                                                print(selectedFilter);
                                              }
                                              else{
                                                print("false selected");
                                              }
                                            },
                                            items: _filterOptions.map((valueItem){
                                              return DropdownMenuItem(
                                                value:valueItem,
                                                child:Text(valueItem,style:TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16.0),
                                      const Text(
                                        'Address',
                                        style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),
                                      ),
                                      Container(
                                        margin: EdgeInsets.symmetric(vertical: 5.0),
                                        padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 0),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(6.0),
                                          color: Colors.indigo[50],
                                          border: Border.all(color: Colors.indigo.shade100),
                                        ),
                                        child: SizedBox(
                                          // height: 40,
                                          child: TextField(
                                            controller: addressController,
                                            maxLines: 3,

                                            decoration: const InputDecoration(
                                              contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                                              hintText: 'Enter Location Address',
                                              labelStyle: TextStyle(fontSize: 16),
                                              border: InputBorder.none, //
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16.0),
                                      const Text(
                                        'Availability Hours',
                                        style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),
                                      ),
                                      SizedBox(
                                        height: 40,
                                        child:Container(
                                          padding: EdgeInsets.symmetric(horizontal: 12.0),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(6.0),
                                            color: Colors.indigo[50],
                                            border: Border.all(color: Colors.indigo.shade100),
                                          ),
                                          child: DropdownButton<String>(
                                            isExpanded: true,
                                            hint: const Text('Select an Option'),
                                            underline: Container(
                                              height: 0,
                                              color: Colors.transparent,
                                            ),
                                            value:selectedHours,
                                            onChanged: (newValue) async {
                                              setState(() {
                                                selectedHours = newValue as String;
                                              });
                                            },
                                            items: availableItems.map((valueItem){
                                              return DropdownMenuItem(
                                                value:valueItem,
                                                child:Text(valueItem,style:const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 15,),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8.0),

                                    ],
                                  ),
                                ),]
                          )
                      )
                  )
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16,vertical: 8),
                width: MediaQuery.of(context).size.height/5,
                child: MaterialButton(
                    elevation: 0,
                    onPressed: (){

                      if (nameController.text.isEmpty ){
                        _showErrorDialog(context, 'Please fill Name field.');
                      }
                      else if(addressController.text.isEmpty)
                      {
                        _showErrorDialog(context, 'Please select Gender who can access.');
                      }
                      else if(selectedGender.isEmpty){
                        _showErrorDialog(context, 'Select option for whether it is accessible for handicap.');
                      }
                      else if(selectedFilter == null){
                        _showErrorDialog(context, 'Please fill address fields.');
                      }
                      else if(selectedHours == null){
                        _showErrorDialog(context, 'Select option for availability hours.');
                      }
                      else {
                        if(selectedFilter=='true'){
                          addRestroomToFirestore(
                            nameController.text,
                            addressController.text,
                            selectedGender,
                            true,
                            selectedHours!,
                            widget.adminEmail,
                          );
                        }
                        else{
                          addRestroomToFirestore(
                            nameController.text,
                            addressController.text,
                            selectedGender,
                            false,
                            selectedHours!,
                            widget.adminEmail,
                          );
                        }
                        _showSuccessDialog(context, 'Restroom added successfully!');
                      }
                    },
                    color: Colors.indigo[900],
                    textColor: Colors.white,
                    padding: EdgeInsets.all(12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(
                        color: Color(0xFFebf1fa), // Set the border color
                        width: 1.0,         // Set the border width
                      ),
                    ),
                    child:Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.home_work_sharp,size: 30,),
                        Icon(Icons.add,size: 20,),
                        Text("ADD",style: TextStyle(color:Colors.white,fontSize: 20,fontWeight: FontWeight.bold
                        ),),
                      ],
                    )
                ),
              ),
            ]
        )
    );
  }

  Future<void> addRestroomToFirestore(String name, String address, List gender,bool handicapped,String hours,String admin) async {
    CollectionReference restroom= FirebaseFirestore.instance.collection('restrooms');
    Map<String, dynamic> coordinates = await convertAddressToCoordinates(address);
    GeoPoint location = GeoPoint(coordinates['latitude'], coordinates['longitude']);

    DocumentReference docRef =await restroom.add({
      'name': name,
      'address': address,
      'location': location,
      'gender': gender,
      'handicappedAccessible': handicapped,
      'availabilityHours': hours,
      'handledBy':admin,
      'no_of_ratings':0,
      'no_of_reports':0,
      'ratings':0,

    });
    print('Document added with ID: ${docRef.id}');


  }
  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ManageRestroom(adminEmail: widget.adminEmail)),
                );
              },
            ),
          ],
        );
      },
    );
  }
  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
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
}
