import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:rest_ez_app/admin/restroomManage.dart';

class EditRestroomData extends StatefulWidget {
  EditRestroomData({super.key, required this.adminEmail, required this.rest_id,
    required this.rest_name, required this.address, required this.res_hours,required this.rest_gender, required this.isHandicap});
  final String adminEmail;
  final String rest_id;
  final String rest_name;
  final String address;
  final String res_hours;
  List<String> rest_gender;
  final bool isHandicap;

  @override
  State<EditRestroomData> createState() => _EditRestroomDataState();
}

class _EditRestroomDataState extends State<EditRestroomData> {
  String? selectedFilter;
  final List<String> _filterOptions = ['true','false'];


  List<String> selectedGender = [];
  List<MultiSelectItem<String>> genderItems = [
    MultiSelectItem<String>('Female', 'Female'),
    MultiSelectItem<String>('Male', 'Male'),];

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
      print('Error converting address to coordinates: $e');
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
                        _showSuccessDialog(context, 'Restroom updated successfully!');
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
  Future<void> updateRestroomData(String docId, String name, String address, List gender, bool handicapped, String hours, String admin) async {
    CollectionReference restroom = FirebaseFirestore.instance.collection('restrooms');

    Map<String, dynamic> coordinates = await convertAddressToCoordinates(address);
    GeoPoint location = GeoPoint(coordinates['latitude'], coordinates['longitude']);

    DocumentReference docRef = restroom.doc(docId);

    //
    await docRef.update({
      'name': name,
      'address': address,
      'location': location,
      'gender': gender,
      'handicappedAccessible': handicapped,
      'availabilityHours': hours,
      'handledBy': admin,
    });

    print('Document updated with ID: $docId');
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Updated'),
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
