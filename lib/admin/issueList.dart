import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReportedIssueList extends StatefulWidget {
  const ReportedIssueList({super.key, required this.adminEmail});
final String adminEmail;
  @override
  State<ReportedIssueList> createState() => _ReportedIssueListState();
}

class _ReportedIssueListState extends State<ReportedIssueList> {
  Future<List<DocumentSnapshot<Map<String, dynamic>>>> getReportsByAdminEmail(String adminEmail) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('admins')
          .doc(adminEmail)
          .collection('reports')
          .get();

      return querySnapshot.docs;
    } catch (error) {
      print('Error fetching reports: $error');
      return [];
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 3,
          backgroundColor: Colors.indigo[700],
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        title: Text('Reported Issues List',style:  TextStyle(fontSize: 20,color: Colors.white,
            fontWeight: FontWeight.bold),)
      ),
      body: FutureBuilder<List<DocumentSnapshot<Map<String, dynamic>>>>(
        future: getReportsByAdminEmail(widget.adminEmail),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            List<DocumentSnapshot<Map<String, dynamic>>> reports = snapshot.data ?? [];

            // Build your UI using the reports list
            return ListView.builder(
              itemCount: reports.length,
              itemBuilder: (context, index) {
                // Access report fields using reports[index]['field_name']
                return Card(
                  color: Colors.blue[50],
                  elevation: 8,
                  margin: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                  shape: RoundedRectangleBorder(
                    // side: BorderSide(color: Colors.indigoAccent, width: 0.5), // Set border color and width here
                    borderRadius: BorderRadius.circular(15), // Set border radius here
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),

                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Restroom  :  ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                            Flexible(
                                child: Text('${reports[index]['restroomName']}',style: TextStyle(fontSize: 16,),)),

                          ],
                        ),
                        SizedBox(height: 3,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Address  :  ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                            Flexible(
                                child: Text('${reports[index]['address']}',style: TextStyle(fontSize: 15,),)),

                          ],
                        ),
                        SizedBox(height: 3,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Reported By  :  ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                            Flexible(
                                child: Text('${reports[index]['reportedBy']}',style: TextStyle(fontSize: 15,),)),

                          ],
                        ),
                        SizedBox(height: 5,),
                        Text("Report  :  ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          padding: EdgeInsets.all(15),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20)
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${reports[index]['description']}",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                              SizedBox(height: 6,),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Status :  ",style: TextStyle(fontSize: 15,color: Colors.indigo,fontWeight: FontWeight.bold),),
                                  Flexible(
                                      child: Text('${reports[index]['status']}',style: TextStyle(fontSize: 15,color: Colors.indigo,),)),

                                ],
                              ),
                            ],
                          ),
                        ),

                        reports[index]['status']=="Pending"?
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: OutlinedButton(
                              onPressed: ()  {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('Issue Solved'),
                                      content: Text('Are you sure you want to change status?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('No'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                            setReportStatus(reports[index].id,"Solved",reports[index]['address']);
                                          },
                                          child: Text('Yes'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.indigo[700],
                                elevation: 5,

                              ),
                              child: Text(
                                'Solved',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize:17,color: Colors.white),
                              ),
                            ),
                          ),
                        )
                            :
                            Container(),

                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
  Future<void> setReportStatus(String reportId, String status,String address) async {
    try {
      await FirebaseFirestore.instance
          .collection('admins')
          .doc(widget.adminEmail)
          .collection('reports')
          .doc(reportId)
          .update({'status': status});
      print('Report status updated successfully.');

      QuerySnapshot reportsSnapshot = await FirebaseFirestore.instance
          .collection('restrooms')
          .where('address', isEqualTo: address)
          .get();

      if (reportsSnapshot.docs.isNotEmpty) {
        DocumentSnapshot restroomDoc = reportsSnapshot.docs.first;

        CollectionReference reportsCollectionRef = restroomDoc.reference
            .collection('reports');
        await reportsCollectionRef.doc(reportId).update({'status': status});
      } else {
        print('No restroom found with the specified address.');
      }


    } catch (error) {
      print('Error updating report status: $error');
    }
  }



}
