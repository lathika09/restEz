import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../widgets/widget.dart';

class ReportIssues extends StatefulWidget {
  const ReportIssues({super.key, required this.rest_id, required this.uname, required this.adminEmail, required this.restAddress, required this.restName,});
  final String uname;
  final String rest_id;
  final String adminEmail;
  final String restAddress;
  final String restName;

  @override
  State<ReportIssues> createState() => _ReportIssuesState();
}

class _ReportIssuesState extends State<ReportIssues> {
  TextEditingController reportController = TextEditingController();

  Future<DocumentSnapshot?> getRestroomById(String docId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('restrooms')
          .doc(docId)
          .get();
      if (snapshot.exists) {
        return snapshot;
      } else {
        print('Restroom document with ID $docId does not exist.');
        return null;
      }
    } catch (e) {
      print('Error fetching restroom: $e');
      return null;
    }
  }


  Future<Map<String, dynamic>?> getAdminDataByEmail(String adminEmail) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('admins')
          .where('email', isEqualTo: adminEmail)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Assuming the document contains 'name' and 'location' fields
        DocumentSnapshot adminDoc = querySnapshot.docs.first;
        return {
          'name': adminDoc['name'],
          'location': adminDoc['location'],
        };
      } else {
        print('Admin with email $adminEmail not found.');
        return null;
      }
    } catch (e) {
      print('Error fetching admin data: $e');
      return null;
    }
  }

  Map<String, dynamic> restRoomData = {};
  Future<void> fetchRestroomById(String id) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance.collection('restrooms').doc(id).get();
      if (snapshot.exists) {
        restRoomData = snapshot.data()!;

      } else {
        restRoomData = {};
      }
    } catch (error) {
      print('Error fetching restroom data: $error');
      restRoomData = {};
    }
  }


  @override
  void initState() {
    super.initState();
    fetchRestroomById(widget.rest_id);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        appTitle: "Report Issue",
        icon: FaIcon(Icons.arrow_back_ios),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child:
          Container(
            width: double.infinity,
            padding:EdgeInsets.symmetric(horizontal: 20,vertical: 18),
            decoration:BoxDecoration(
              // borderRadius:BorderRadius.circular(30),
              color: Colors.indigo[50],
            ),

            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Send to  ",
                    style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),
                  ),
                  Container(
                      margin: EdgeInsets.only(top: 3),
                      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              width: 1,
                              color: Colors.black12
                          )
                      ),
                      child: StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance.collection('admins').doc(restRoomData['handledBy']).snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator()); // Placeholder while loading
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (!snapshot.hasData || !snapshot.data!.exists) {
                            return Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.indigo[900],
                                  child: Icon(Icons.person, color: Colors.white),
                                ),
                                Text('${restRoomData['handledBy']}'),
                              ],
                            );
                          } else {
                            String adminName = snapshot.data!['name'];
                            String adminLocation = snapshot.data!['location'];

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.indigo[900],
                                  child: Icon(Icons.person, color: Colors.white),
                                ),
                                SizedBox(width: 15),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('$adminName',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                    Text('$adminLocation',
                                      style: TextStyle(fontWeight: FontWeight.w400, color: Colors.black54, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }
                        },
                      )

                  ),
                  SizedBox(height: 10,),
                  Text("Report Issue  ",
                    style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),
                  ),
                  Container(
                    // color: Colors.black54,
                    width:MediaQuery.of(context).size.width ,
                    margin: EdgeInsets.only(top: 3),
                    padding: EdgeInsets.only(top: 3,left: 12,right: 12,bottom: 40),
                    height: 200,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.grey.shade50,
                        border: Border.all(
                          width: 1,
                          color: Colors.black12,
                        )
                    ),
                    child: TextField(
                      controller: reportController,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Write Issue regarding this Restroom',
                        border: InputBorder.none,
                        hintMaxLines: 5,
                        contentPadding: EdgeInsets.symmetric(vertical: 6,),
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ),
          ),
          Center(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16,vertical: 18),
              width: MediaQuery.of(context).size.height/3,
              // color: Colors.black12,
              child: MaterialButton(
                  elevation: 0,
                  onPressed: () async{
                    if (reportController.text.isEmpty) {
                      _showErrorDialog(context, "Give description About your report");
                    }

                    else{

                        // (String user emailname,String admin email,String com)
                        String? email = await getEmailFromName(widget.uname);
                        if (email != null) {

                          postReport(email, widget.adminEmail, reportController.text,widget.restAddress,widget.restName);
                          updateNumberOfReports(email);

                          print('Email for Hari Kumar: $email');
                        } else {
                          _showErrorDialog(context, "Report is not sent");
                          print('No email found for Hari Kumar');
                        }
                        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                            .collection('restrooms')
                            .doc(widget.rest_id)
                            .collection('reports')
                            .get();

                        int reportsLength = querySnapshot.docs.length;
                        print('Number of reports: $reportsLength');
                        FirebaseFirestore.instance
                            .collection('restrooms')
                            .doc(widget.rest_id).set({
                          'no_of_reports':reportsLength ,
                        }, SetOptions(merge: true));





                        _showSuccessDialog(context, "The report was sent successfully!");
                        reportController.clear();
                        // Navigator.of(context).pop();
                        // Navigator.of(context).pop();





                    }
                  },
                  color: Colors.blue[800],
                  textColor: Colors.white,
                  padding: EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: BorderSide(
                      color: Color(0xFFebf1fa), // Set the border color
                      width: 1.0,         // Set the border width
                    ),
                  ),
                  child:Text("SEND ",style: TextStyle(color:Colors.white,fontSize: 20,fontWeight: FontWeight.bold
                  ),)
              ),
            ),
          ),
        ],
      ),

    );
  }


  void postReport(String uname,String aemail,String com,String add,String rname) async {
    if (com.isEmpty) {
      _showErrorDialog(context, "Give Description about your Issue regarding this restroom");
    }

    try {
      // await FirebaseFirestore.instance.collection('restrooms').doc(widget.rest_id).collection('reports').add({
      //   'description': com,
      //   'reportedBy': uname,
      //   'sendTo': aemail,
      //   'timestamp': Timestamp.now(),
      //   'status':"Pending",
      // });

      DocumentReference newReportRef = await FirebaseFirestore.instance
          .collection('admins')
          .doc(aemail)
          .collection('reports')
          .add({
        'description': com,
        'reportedBy': uname,
        'sendTo': aemail,
        'timestamp': Timestamp.now(),
        'status': "Pending",
        'address': add,
        'restroomName': rname
      });



      CollectionReference reports = FirebaseFirestore.instance.collection('restrooms').doc(widget.rest_id).collection('reports');

      String newReportId = newReportRef.id;
      DocumentReference docRef = reports.doc(newReportId);

      await docRef.set({
        'description': com,
        'reportedBy': uname,
        'sendTo': aemail,
        'timestamp': Timestamp.now(),
        'status':"Pending",
      });
      //


    } catch (e) {
      print('Error posting review: $e');
      _showErrorDialog(context, "Error: ${e.toString()}");

    }
  }


  Future<String?> getEmailFromName(String name) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await FirebaseFirestore.instance
          .collection('users')
          .where('name', isEqualTo: name)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first['email'];
      } else {
        return null;
      }
    } catch (error) {
      print('Error retrieving email from name: $error');
      return null;
    }
  }
  Future<void> updateNumberOfReports(String email) async {
    try {
      DocumentReference userRef =
      FirebaseFirestore.instance.collection('users').doc(email);

      await userRef.set({
        'no_of_reports': FieldValue.increment(1),
      }, SetOptions(merge: true));

      print('no. of reports in user incremented.');
    } catch (error) {
      print('Error updating number of reviews: $error');
    }
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Can\'t report' ),
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
          title: Text('Successfully Reported'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                // Navigator.pushReplacement(
                //   context,
                //   MaterialPageRoute(builder: (context) => RestroomP()),
                // );
              },
            ),
          ],
        );
      },
    );
  }
}
