import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:rest_ez_app/admin/restroomManage.dart';

class EditRestroomData extends StatefulWidget {
  EditRestroomData({super.key, required this.adminEmail, required this.rest_id,
    required this.rest_name, required this.address, required this.res_hours,required this.rest_gender, required this.isHandicap, required this.images});
  final String adminEmail;
  final String rest_id;
  final String rest_name;
  final String address;
  final String res_hours;
  List<String> rest_gender;
  final bool isHandicap;
final List<dynamic> images;
  @override
  State<EditRestroomData> createState() => _EditRestroomDataState();
}

class _EditRestroomDataState extends State<EditRestroomData> {
  String? selectedFilter;
  final List<String> _filterOptions = ['true','false'];


  List<String> selectedGender = [];
  List<MultiSelectItem<String>> genderItems = [
    MultiSelectItem<String>('Female', 'Female'),
    MultiSelectItem<String>('Male', 'Male'),
    MultiSelectItem<String>('Others', 'Others'),
  ];

  String selectedHours="";
  List<String> availableItems = ['Open 24 Hours', 'Closed'];


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
      log('Error converting address to coordinates: $e');
      throw Exception('Failed to convert address to coordinates.');
    }
  }
  @override
  void initState() {
    super.initState();
    nameController.text=widget.rest_name;
    addressController.text = widget.address;
    selectedGender = widget.rest_gender;
    selectedHours = widget.res_hours;
    selectedFilter = widget.isHandicap ? 'true' : 'false';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            elevation: 3,
            title: const Text("Edit Restroom Data", style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),)
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
                                  margin: const EdgeInsets.symmetric(vertical: 10,horizontal:3),
                                  padding:const EdgeInsets.symmetric(vertical: 15,horizontal: 20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Name ',
                                        style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.symmetric(vertical: 5.0),
                                        padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 0),
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
                                          itemsTextStyle:const TextStyle(fontSize: 16),
                                          selectedColor: Colors.indigo[500],
                                          selectedItemsTextStyle: const TextStyle(color: Colors.black,fontSize: 16),
                                          initialValue:selectedGender,
                                          listType: MultiSelectListType.CHIP,
                                          onConfirm: (values) {
                                            setState(() {
                                              selectedGender = values.toList();
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
                                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
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
                                                child:Text(valueItem,style:const TextStyle(
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
                                        margin: const EdgeInsets.symmetric(vertical: 5.0),
                                        padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 0),
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
                                            enabled: false,
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
                                      const SizedBox(height: 16.0),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Photos ',
                                            style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),
                                          ),
                                          // const SizedBox(height: 10.0),
                                          Container(
                                            // margin: EdgeInsets.symmetric(horizontal: 16,vertical: 5),
                                            width: MediaQuery.of(context).size.width/2.9,
                                            child: MaterialButton(
                                                elevation: 0,
                                                onPressed: () async{
                                                  final ImagePicker picker = ImagePicker();

                                                  // Pick image
                                                  final XFile? image = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
                                                  if (image != null) {
                                                    log(" data : ${widget.images}");
                                                    log('Image Path: ${image.path}');
                                                    await sendImage(widget.rest_id, widget.images, File(image.path));
                                                  }
                                                },
                                                color: Colors.indigo[100],//800
                                                textColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(30),
                                                  side: BorderSide(
                                                    color:  Colors.indigo.shade100,
                                                    width: 1.0,
                                                  ),
                                                ),
                                                child:const Text("Add Photos ",style: TextStyle(color:Colors.black,fontSize: 15,fontWeight: FontWeight.bold
                                                ),)
                                            ),
                                          ),
                                        ],
                                      ),

                                      StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                                       stream: FirebaseFirestore.instance
                                           .collection('restrooms')
                                           .doc(widget.rest_id)
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
                                         return widget.images.length!=0?
                                         Container(
                                           margin: const EdgeInsets.only(top: 5,bottom: 10),
                                           padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 12),
                                           decoration: BoxDecoration(

                                             borderRadius: BorderRadius.circular(10),
                                             color: Colors.indigo[50],
                                             // border: Border.all(color: Colors.indigo.shade100,
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
                                                           crossAxisCount: 2, // You can adjust the number of columns here
                                                           crossAxisSpacing: 0,
                                                           mainAxisSpacing: 0,
                                                         ),
                                                         itemCount: imageUrls.length,
                                                         itemBuilder: (context, index) {
                                                           return InkWell(
                                                             onTap: () {
                                                               print(imageUrls );
                                                               showPhotos(context, "${imageUrls[index]}",widget.rest_id);
                                                             },
                                                             child: Container(
                                                               margin: const EdgeInsets.all(5),
                                                               child: Image.network(
                                                                 "${imageUrls [index]}",
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
                                             margin: const EdgeInsets.only(top: 5,bottom: 10),
                                             padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 12),
                                             decoration: BoxDecoration(
                                               color: Colors.indigo[50],
                                               border: Border.all(color: Colors.indigo.shade100),
                                               borderRadius: BorderRadius.circular(10),
                                             ),
                                             width: double.infinity,
                                             child: const Text(
                                               'No Photos added ',
                                               style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500),
                                             )
                                         );
                                       },
                                     ),

                                      const SizedBox(height: 16.0),

                                    ],
                                  ),
                                ),]
                          )
                      )
                  )
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16,vertical: 8),
                width: MediaQuery.of(context).size.width/2,
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
                        _showErrorDialog(context, 'Please select whether handicappedAccesible dropdown');
                      }
                      else if(selectedHours == null){
                        _showErrorDialog(context, 'Select option for availability hours.');
                      }
                      else {
                        if(selectedFilter=='true'){
                          updateRestroomData(
                            widget.rest_id,
                            nameController.text,
                            addressController.text,
                            selectedGender,
                            true,
                            selectedHours,
                            widget.adminEmail,
                          );
                        }
                        else{
                          updateRestroomData(
                            widget.rest_id,
                            nameController.text,
                            addressController.text,
                            selectedGender,
                            false,
                            selectedHours,
                            widget.adminEmail,
                          );
                        }

                      }
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
                    child:const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.home_work_sharp,size: 25,),
                        Icon(Icons.edit,size: 25,),
                        SizedBox(width: 10,),
                        Text("UPDATE",style: TextStyle(color:Colors.white,fontSize: 18,fontWeight: FontWeight.bold
                        ),),
                      ],
                    )
                ),
              ),
            ]
        )
    );
  }
  Future<void> sendImage(String restId, List<dynamic> urlsList, File file) async {
    final ext = file.path.split('.').last;
    try{
      final Reference ref = FirebaseStorage.instance.ref().child(
          'images/$restId/${DateTime.now().millisecondsSinceEpoch}.$ext');

      final UploadTask uploadTask = ref.putFile(file);

      await uploadTask.whenComplete(() async {
        final imageUrl = await ref.getDownloadURL();
        log('Image uploaded to Firebase Storage: $imageUrl');
        List<dynamic> imagesList =urlsList??[];
        imagesList.add(imageUrl);

        await FirebaseFirestore.instance
            .collection('restrooms')
            .doc(widget.rest_id)
            .update({'images': imagesList});
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Updated'),
              content: const Text("Photo is successfully added"),
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

        log('Image URL saved in Firestore.');
      });
    }
    catch (e, stackTrace) {
      log('Error uploading image: $e');
      log('Stack trace: $stackTrace');
      _showErrorDialog(context, 'Error uploading image: $e');
    }
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
                                  content: const Text("Are you sure you want to delete this photo?"),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("No"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // Delete photo if user confirms
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
                          child: Icon(Icons.delete, size: 30, color: Colors.blue[900]),
                        ),
                      ),
                      ),
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

      // Show success message
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


  Future<void> updateRestroomData(String docId, String name, String address, List gender, bool handicapped, String hours, String admin) async {
    CollectionReference restroom = FirebaseFirestore.instance.collection('restrooms');

    Map<String, dynamic> coordinates = await convertAddressToCoordinates(address);
    GeoPoint location = GeoPoint(coordinates['latitude'], coordinates['longitude']);
    // QuerySnapshot querySnapshot = await restroom.where('location', isEqualTo: location)
    //     .get();
    //
    // if (querySnapshot.docs.isNotEmpty) {
    //   _showErrorDialog(context, 'Cannot update. Another restroom with the same location already exists.');
    // } else {
    //   DocumentReference docRef = restroom.doc(docId);
    //
    //   await docRef.update({
    //     'name': name,
    //     'address': address,
    //     'location': location,
    //     'gender': gender,
    //     'handicappedAccessible': handicapped,
    //     'availabilityHours': hours,
    //     'handledBy': admin,
    //   });
    //   _showSuccessDialog(context, 'Restroom updated successfully!');
    //
    //   print('Document updated with ID: $docId');
    // }
    DocumentReference docRef = restroom.doc(docId);
    await docRef.update({
      'name': name,
      'address': address,
      'location': location,
      'gender': gender,
      'handicappedAccessible': handicapped,
      'availabilityHours': hours,
      'handledBy': admin,
    });
    _showSuccessDialog(context, 'Restroom updated successfully!');

    print('Document updated with ID: $docId');
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Updated'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
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
          title: const Text('Error'),
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
}
