import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});
  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  TextEditingController search_name = TextEditingController();
  String searchText = '';
  final List<String> helpTopics = [
    "How to search nearby Restroom",

    "How to find restroom for handicap",
    "Can I leave review to a particular then How?",
    "How to report issue about restroom",
    "How to suggest new restroom which is not shown in this app ?",
    // "Is it necessary to login for suggestions about new restroom",

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        automaticallyImplyLeading: false,
        title: RichText(
          text: TextSpan(
              style: const TextStyle(fontSize: 28,
                  fontWeight: FontWeight.bold),
              children: <TextSpan>[
                const TextSpan(text: 'Rest', style: TextStyle(color: Colors.black)),
                TextSpan(
                    text: 'Ez', style: TextStyle(color: Colors.blueAccent[700]))
              ]
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.close,
                color: Colors.black,
              ))
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            height: MediaQuery.of(context).size.height * 0.1,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.only(top: 18, bottom: 18, left: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [

                Container(
                  height: MediaQuery.of(context).size.height * 0.06,
                  width: MediaQuery.of(context).size.width * 0.78,

                  child: const Text("Help Page ",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                ),
                // SizedBox(width: 30,)
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [

                Container(
                  // color: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      helpTopics.length,
                          (index) {
                        if (index == 0) {
                          return helpCard(helpTopics[index], index, First());
                        } else if (index == 1) {
                          return helpCard(helpTopics[index], index, Second());
                        } else if (index == 2) {
                          return helpCard(helpTopics[index], index, Third());
                        }
                        else if (index == 3) {
                          return helpCard(helpTopics[index], index, Forth());
                        }
                        else if (index == 4) {
                          return helpCard(helpTopics[index], index, Fifth());
                        }
                        // else if (index == 5) {
                        //   return helpCard(helpTopics[index], index, Sixth());
                        // }
                        else {
                          return Container();
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget helpCard(String nm, int index,Widget help) {
    // bool isSelected = false;
    List<bool> isSelectedList = List.filled(helpTopics.length, false);
    return InkWell(
      onTap: () {
        setState(() {
          print("object");
          isSelectedList[index] = !isSelectedList[index];
        });
        showModalBottomSheet(context: context,
            backgroundColor: Colors.transparent,
            // isScrollControlled: true,
            // useSafeArea: true,
            builder: (BuildContext context) {
              return Container(
                color: Colors.white,
                height: MediaQuery.of(context).size.height/1.5,
                width: MediaQuery.of(context).size.width,
                child: help
              );
            });
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.menu,
            size: 18,
            color: Colors.grey.shade800,
          ),
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(bottom: 14, top: 9),
              decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.shade400,
                      width: 0.8,
                    ),
                  )),
              child: Text(
                nm,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                  decoration: isSelectedList[index]
                      ? TextDecoration.underline
                      : TextDecoration.none,
                ),
              ),
            ),
          ),
        ],
      ),
      // Divider(indent: 40,color: Colors.grey.shade300,),
    );
    // Divider(indent: 40,color: Colors.grey.shade300,)
  }
}

class First extends StatelessWidget {
  const First({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 15,right:15,top: 20,bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("To search nearby Restroom",style: TextStyle(fontWeight: FontWeight.bold,fontSize:22),),
          // SizedBox(height: 10,),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width/1.6,
              height: MediaQuery.of(context).size.width/1.6,
              child: Lottie.asset("assets/lottie1.json"),
              // Lottie.network("https://lottie.host/b4b53a3f-3af4-415b-8be9-10c6dd8a37b1/tXSCKKEK41.json"),
            ),
          ),
          // SizedBox(height: 10,),
          Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 3),
            width: MediaQuery.of(context).size.width,
              child: const Column(
                children: [
                  Text(
                    "Just allow the location to be accessed when asked.",
                    style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
                  Text("This will automatically display nearby restrooms within 5 km.",
                    style: TextStyle(fontSize: 17,),)
                ],
              )
              )
          )

        ],
      ),
    );
  }
}


class Second extends StatelessWidget {
  const Second({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 15,right:15,top: 20,bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("To find nearby Restroom for handicap or based on Gender",style: TextStyle(fontWeight: FontWeight.bold,fontSize:20),softWrap: true,),
          // SizedBox(height: 10,),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width/2.1,
              height: MediaQuery.of(context).size.width/2.1,
              child:Lottie.asset("assets/lottie2.json"),
              // Lottie.network("https://lottie.host/518b94f4-e01b-488b-89fe-f1a5b28ac3af/Zy6IcXMnnA.json"),
            ),
          ),
          // SizedBox(height: 10,),
          Flexible(
              child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "Step 1: ",
                            style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                          Flexible(
                            child: Container(
                              child: const Text(
                                "Allow the location when asked.",
                                style: TextStyle(fontSize: 16,),overflow: TextOverflow.visible,softWrap: true,),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Step 2 : ",
                            style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                          Flexible(
                            child: Container(
                              child: const Text(
                                "You can filter location based on handicap and gender by using the drop-down present just below the appbar.",
                                style: TextStyle(fontSize: 16,),overflow: TextOverflow.visible,softWrap: true,),
                            ),
                          ),
                        ],
                      ),
                      const Text("This will automatically display nearby restrooms within 5 km.",
                        style: TextStyle(fontSize: 16,),overflow: TextOverflow.visible,softWrap: true,)
                    ],
                  )
              )
          )

        ],
      ),
    );
  }
}

class Third extends StatelessWidget {
  const Third({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 15,right:15,top: 20,bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("To give a review",style: TextStyle(fontWeight: FontWeight.bold,fontSize:22),),
          // SizedBox(height: 10,),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width/1.7,
              height: MediaQuery.of(context).size.width/1.7,
              child: Lottie.asset("assets/lottie3.json"),
              // Lottie.network("https://lottie.host/389acb2e-215c-4637-a85f-fac86b023856/1bmDxKMwx6.json"),
            ),
          ),
          // SizedBox(height: 10,),
          Flexible(
              child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3),

                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Step 1: ",
                            style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                          Flexible(
                            child: Container(
                              child: const Text(
                                "Select the restroom you want to rate.",
                                style: TextStyle(fontSize: 16,),overflow: TextOverflow.visible,softWrap: true,),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Step 2 : ",
                            style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                          Flexible(
                            child: Container(
                              child: const Text(
                                "You have to log in first before giving reviews or ratings.",
                                style: TextStyle(fontSize: 16,),overflow: TextOverflow.visible,softWrap: true,),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Step 3 : ",
                            style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                          Flexible(
                            child: Container(
                              child: const Text(
                                "Click on the Write a Review button in the Review tab.",
                                style: TextStyle(fontSize: 16,),overflow: TextOverflow.visible,softWrap: true,),
                            ),
                          ),
                        ],
                      ),

                    ],
                  )
              )
          )

        ],
      ),
    );
  }
}

class Forth extends StatelessWidget {
  const Forth({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:const EdgeInsets.only(left: 15,right:15,top: 20,bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("To report an issue about the restroom",style: TextStyle(fontWeight: FontWeight.bold,fontSize:22),),
          // SizedBox(height: 10,),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width/2,
              height: MediaQuery.of(context).size.width/2,
              child: Lottie.asset("assets/lottie4.json"),
              // Lottie.network("https://lottie.host/15983367-0991-47e7-91f3-0fdbc2bd4443/GOCgxHaUx4.json"),
            ),
          ),
          // SizedBox(height: 10,),
          Flexible(
              child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3),

                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Step 1: ",
                            style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                          Flexible(
                            child: Container(
                              child: const Text(
                                "Select the restroom you want to report an issue about.",
                                style: TextStyle(fontSize: 16,),overflow: TextOverflow.visible,softWrap: true,),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Step 2 : ",
                            style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                          Flexible(
                            child: Container(
                              child: const Text(
                                "You have to log in first before issuing a report",
                                style: TextStyle(fontSize: 16,),overflow: TextOverflow.visible,softWrap: true,),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Step 3 : ",
                            style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                          Flexible(
                            child: Container(
                              child: const Text(
                                "Click on the \'Report Issue\' button in the About tab.",
                                style: TextStyle(fontSize: 16,),overflow: TextOverflow.visible,softWrap: true,),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
              )
          )

        ],
      ),
    );
  }
}

class Fifth extends StatelessWidget {
  const Fifth({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 15,right:15,top: 20,bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("To suggest a new restroom",style: TextStyle(fontWeight: FontWeight.bold,fontSize:22),),
          // SizedBox(height: 10,),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width/2.2,
              height: MediaQuery.of(context).size.width/2.2,
              child:Lottie.asset("assets/lottie5.json"),
              // Lottie.network("https://lottie.host/6b9985f6-7641-4a95-851d-a7d399ea95b4/YSrd7THJ7E.json"),
            ),
          ),
          // SizedBox(height: 10,),
          Flexible(
              child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Step 1: ",
                            style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                          Flexible(
                            child: Container(
                              child: const Text(
                                "You have to log in first before suggesting a restroom.",
                                style: TextStyle(fontSize: 16,),overflow: TextOverflow.visible,softWrap: true,),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Step 2 : ",
                            style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                          Flexible(
                            child: Container(
                              child: const Text(
                                "Go to the profile page.",
                                style: TextStyle(fontSize: 16,),overflow: TextOverflow.visible,softWrap: true,),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Step 3 : ",
                            style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                          Flexible(
                            child: Container(
                              child: const Text(
                                "Click on the \'Suggest Resroom\' button.",
                                style: TextStyle(fontSize: 16,),overflow: TextOverflow.visible,softWrap: true,),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10,),
                      const Text("You can add addresses by your current location, so you need to be in that restroom currently to suggest one to the admin.",
                        style: TextStyle(fontSize: 16,),overflow: TextOverflow.visible,softWrap: true,)
                    ],
                  )
              )
          )

        ],
      ),
    );
  }
}

