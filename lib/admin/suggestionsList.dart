import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rest_ez_app/admin/addVerified.dart';


class SuggestionStatus extends StatefulWidget {
  const SuggestionStatus({super.key, required this.adminEmail});
  final String adminEmail;

  @override
  State<SuggestionStatus> createState() => _SuggestionStatusState();
}

enum FilterStatus {Pending,Verified,Cancel}

class _SuggestionStatusState extends State<SuggestionStatus> {
  FilterStatus status = FilterStatus.Pending;
  Alignment _alignment = Alignment.centerLeft;
  bool isAdded=false;

  List<dynamic> suggests = [];
  final CollectionReference newRestroomCollection = FirebaseFirestore.instance.collection('newRestrooom');

  Future<void> getSuggestionsForAdmin(String adminEmail) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('newRestroom')
          .where('sendTo', isEqualTo: 'admin@gmail.com : Chembur')
          .get();
print(querySnapshot.docs);
      for (DocumentSnapshot doc in querySnapshot.docs) {
        String address = doc['address'];
        GeoPoint location = doc['location'];
        int noOfSuggestion = doc['no_of_suggestion'];
        String sendTo = doc['sendTo'];
        String status = doc['status'];
        List<dynamic> suggestedBy = doc['suggestedBy'];
        Timestamp timestamp = doc['timestamp'];
        String suggestedByFormatted = suggestedBy.map((e) => e.toString()).join('\n');



        FilterStatus filterStatus = FilterStatus.values
            .firstWhere((e) => e.toString() == 'FilterStatus.' + status,
            orElse: () => FilterStatus.Pending);

        suggests.add({
          'address': address,
          'location': location,
          'no_of_suggestion': noOfSuggestion,
          'sendTo': sendTo,
          'status': filterStatus,
          'suggestedBy': suggestedByFormatted,
          'timestamp': timestamp,
        });
        print(suggests);
      }
      print(suggests);
      print("DONE IN GET");

      setState(() {});
    } catch (error) {

      print('Error fetching suggestions for admin: $error');
    }
  }


  Future<void> updateNewRestroomStatus(String adminEmail,String restroomId,String newStatus) async {
    try {

       final DocumentReference suggestRef =FirebaseFirestore.instance.collection('newRestroom').doc(restroomId);
       print("runnind $suggestRef");

       await suggestRef.update({
         'status': newStatus,
       });

       DocumentSnapshot updatedDoc = await suggestRef.get();
       print(updatedDoc.data());

       print('Status updated successfully.');
      suggests.clear();
      await getSuggestionsForAdmin(adminEmail);

    } catch (e) {
      print('Error updating appointment status: $e');
    }
  }

  Future<void> deleteNewRestroomByAddress(String adminEmail,String address) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('newRestroom')
          .where('address', isEqualTo: address)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        for (DocumentSnapshot docSnapshot in querySnapshot.docs) {
          await docSnapshot.reference.delete();
          print('Document with address $address deleted successfully.');
          suggests.clear();
          await getSuggestionsForAdmin(adminEmail);
        }
      } else {
        print('Document with address $address does not exist.');
      }
    } catch (error) {
      print('Error deleting document: $error');
    }
  }


  @override
  void initState() {
    super.initState();


    getSuggestionsForAdmin("admin@gmail.com");
    print("print : }");
  }

  @override
  Widget build(BuildContext context) {

    List<dynamic> filteredSuggestions = suggests.where((var suggest) {
      return suggest['status'] == status;
    }).toList();
    print("nka:$filteredSuggestions");


    return Scaffold(
      appBar: AppBar(
          backgroundColor:Colors.white,
          iconTheme: IconThemeData(
            color: Colors.indigo[900],
          ),
          elevation: 5,
          title:Text(
            'Suggested New RestRooms',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,color: Colors.indigo[900]),
          ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 40,

                    decoration: BoxDecoration(
                      color: Colors.indigo[50],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (FilterStatus filterStatus in FilterStatus.values)
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  status = filterStatus;
                                  if (filterStatus.name =="Pending") {
                                    _alignment = Alignment.centerLeft;
                                  } else if (filterStatus.name ==
                                      "Verified") {
                                    _alignment = Alignment.center;
                                  } else if (filterStatus.name =="Cancel") {
                                    _alignment = Alignment.centerRight;
                                  }
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                                child: Text(filterStatus.name,style: TextStyle(fontSize: 16),textAlign: filterStatus.name == "Request"
                                    ? TextAlign.left
                                    : filterStatus.name == "Cancel"
                                    ? TextAlign.right
                                    : TextAlign.center,),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  AnimatedAlign(
                    alignment: _alignment,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: 110,
                      height: 40,
                      decoration: BoxDecoration(
                          color: Colors.indigo.shade700,
                          borderRadius: BorderRadius.circular(20)),
                      child: Center(
                        child: Text(
                          status.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredSuggestions.length,
                  itemBuilder: ((context, index) {
                    print("nisi ; $filteredSuggestions");
                    var _suggest = filteredSuggestions[index];
                    bool isLastElement = filteredSuggestions.length + 1 == index;

                    FilterStatus suggestStatus = _suggest['status'];
                    return Card(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                          color: Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      margin: !isLastElement
                          ? EdgeInsets.only(bottom: 20)
                          : EdgeInsets.zero,
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.blue[900],
                                  child: Icon(Icons.add_location_alt_sharp,size: 28,color: Colors.white,),
                                  // backgroundImage:NetworkImage("https://static.thenounproject.com/png/5034901-200.png"),
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Flexible(
                                  child: Text(
                                    '${_suggest['address']}',
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18
                                    ),
                                  ),
                                ),

                              ],
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const Text("No. of Suggestions :  ",style: TextStyle(fontSize: 15,),),
                                      Text("${_suggest['no_of_suggestion']}",style: const TextStyle(fontSize: 16,fontWeight: FontWeight.w500),)
                                    ],
                                  ),
                                  const SizedBox(height: 15,),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("Suggested By :  ",style: TextStyle(fontSize: 15,),),
                                      Text("${_suggest['suggestedBy']}",style: const TextStyle(fontSize: 16,fontWeight: FontWeight.w500),)
                                    ],
                                  ),
                                  const SizedBox(height: 15,),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("Status :  ",style: TextStyle(fontSize: 15,),),

                                      _suggest['status']==FilterStatus.Pending
                                          ?
                                      const Text("Pending",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),)
                                      :_suggest['status'] == FilterStatus.Verified
                                      ?const Text("Verified",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),)
                                          :
                                      const Text("Cancel",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),)
                                    ],
                                  ),


                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (suggestStatus == FilterStatus.Pending)
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: ()  {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text('Cancel Suggestion'),
                                              content: const Text('Are you sure you want to cancel this location suggestion?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    // Close the dialog
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text('No'),
                                                ),
                                                TextButton(
                                                  onPressed: () async {

                                                    String sendTo=_suggest['sendTo'];
                                                    List<String> parts = sendTo.split(':');

                                                    String email = parts[0].trim();
                                                    // g adminEmail,String restroomId,, String newStatus,String sendTo,
                                                    await updateNewRestroomStatus(
                                                      widget.adminEmail,
                                                      _suggest['address'],
                                                      "Cancel",

                                                    );
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text('Yes'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(color: Colors.white,fontSize: 16),
                                      ),
                                    ),
                                  ),
                                if (suggestStatus == FilterStatus.Pending)
                                  SizedBox(width: 20),
                                if (suggestStatus == FilterStatus.Pending)
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: (){
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text('Verified Location'),
                                              content: Text('Are you sure you want to approve it ?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text('Cancel'),
                                                ),

                                                TextButton(
                                                  onPressed: () async {

                                                    String sendTo=_suggest['sendTo'];
                                                    List<String> parts = sendTo.split(':');

                                                    String email = parts[0].trim();
                                                    // g adminEmail,String restroomId,, String newStatus,String sendTo,
                                                    await updateNewRestroomStatus(
                                                      widget.adminEmail,
                                                      _suggest['address'],
                                                      "Verified",

                                                    );
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text('Verified'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: Colors.green,),
                                      child: Text(
                                        'Verified',
                                        style: TextStyle(color: Colors.white,fontSize: 16),
                                      ),
                                    ),
                                  ),
                                //
                                if (suggestStatus == FilterStatus.Verified)
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: ()  {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text('Cancel Suggestion'),
                                              content: const Text('Are you sure you want to cancel this location suggestion?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text('No'),
                                                ),
                                                TextButton(
                                                  onPressed: () async {

                                                    String sendTo=_suggest['sendTo'];
                                                    List<String> parts = sendTo.split(':');

                                                    String email = parts[0].trim();
                                                    // g adminEmail,String restroomId,, String newStatus,String sendTo,
                                                    await updateNewRestroomStatus(
                                                      widget.adminEmail,
                                                      _suggest['address'],
                                                      "Cancel",

                                                    );
                                                    Navigator.of(context).pop();
                                                  },
                                                  child:const Text('Yes'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: const Text(
                                        'Cancel',
                                        style: TextStyle(color: Colors.white,fontSize: 16),
                                      ),
                                    ),
                                  ),
                                if (suggestStatus == FilterStatus.Verified)
                                  const SizedBox(width: 20),
                                if (suggestStatus == FilterStatus.Verified)
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: (){
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text('Add Restroom'),
                                              content: const Text('Are you sure you want to add this restroom?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () async {

                                                    String sendTo=_suggest['sendTo'];
                                                    List<String> parts = sendTo.split(':');

                                                    String email = parts[0].trim();
                                                    // g adminEmail,String restroomId,, String newStatus,String sendTo,

                                                    Navigator.of(context).pop();
                                                    Navigator.push(
                                                          context,
                                                          MaterialPageRoute(builder: (context) => AddVerifiedRestroom(adminEmail: widget.adminEmail,address: _suggest['address'],)),
                                                        );
                                                  },
                                                  child: const Text('Add'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        elevation: 10,
                                        backgroundColor: Colors.green,),
                                      child: const Text(
                                        'Add Restroom',
                                        style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 17),
                                      ),
                                    ),
                                  ),

                                if (suggestStatus == FilterStatus.Cancel)
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: (){
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text('Delete Suggestion'),
                                              content: const Text('Are you sure you want to delete this suggestion?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    Navigator.of(context).pop();
                                                    deleteNewRestroomByAddress(widget.adminEmail,_suggest['address']);

                                                  },
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        elevation: 10,
                                        backgroundColor: Colors.green,),
                                      child: const Text(
                                        'Delete Data',
                                        style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 17),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

