import 'dart:async';
import 'dart:math';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rest_ez_app/user/helpPage.dart';
import 'package:rest_ez_app/user/restroomDetails.dart';
import 'package:rest_ez_app/user/notification.dart';
import 'package:rest_ez_app/user/shared.dart';

import 'LoginUser.dart';
import 'Profile.dart';
// import 'package:location/location.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key,});


  @override
  State<UserPage> createState() => _UserPageState();

}

class _UserPageState extends State<UserPage> {


  String? selectedFilter;
  List<String> _filterOptions = ['All', 'Female', 'Male', 'Others','Handicapped'];


  LatLng? pickLocation;
  loc.Location location=loc.Location();
  String? _address;

  final Completer<GoogleMapController> _controller =
  Completer<GoogleMapController>();
  GoogleMapController? newGoogleMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  GlobalKey<ScaffoldState> _scaffoldState=GlobalKey<ScaffoldState>();
  double searchLocationContainerHeight=220;
  double waitingResponse=0;
  double assigned=0;

  Position? userCurrentPosition;
  var geoLocation=Geolocator();

  LocationPermission? _locationPermission;
  double bottomPaddingOfMap=0;

  List<LatLng> pLineCoordinatedList=[];
  Set<Polyline> polylineSet={};

  Set<Marker> markersSet={};
  Set<Circle> circlesSet={};

  String userName="";
  String email="";

  bool openNavigationDrawer=true;

  bool activeNearbyDriverKeysLoaded=false;

  BitmapDescriptor? activeNearbyIcon;



  locateUserPosition() async{
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied){
      print("PERMISSION DENIED");
    }
    else if (permission == LocationPermission.deniedForever) {
      print("PERMISSION DENIED forever");
    }
    else{
      Position cPosition =await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      userCurrentPosition=cPosition;

      LatLng latLngPosition=LatLng(userCurrentPosition!.latitude,userCurrentPosition!.longitude);
      CameraPosition cameraPosition=CameraPosition(target: latLngPosition,zoom: 15);

      newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      fetchNearbyRestrooms(cPosition);


    }

  }
  // Function to calculate the distance between two points (in kilometers)
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double radiusEarth = 6371; // Earth's radius in kilometers
    double dLat = (lat2 - lat1) * pi / 180;
    double dLon = (lon2 - lon1) * pi / 180;
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) * cos(lat2 * pi / 180) *
            sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return radiusEarth * c;
  }

  Future<void> fetchNearbyRestrooms(Position userPosition) async {
    double radius = 5; // 5 kilometers radius
    // Perform the query
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('restrooms')
        .get();
    // Filter documents within the radius
    querySnapshot.docs.forEach((DocumentSnapshot document) {
      GeoPoint? restroomLocation = (document.data() as Map<String, dynamic>)['location'];
      List<String>? genderArray = List<String>.from(document['gender']);
      bool handicappedAccessible = document['handicappedAccessible'];
      print(genderArray);

      if (restroomLocation != null) {
        double distance = calculateDistance(
          userPosition.latitude,
          userPosition.longitude,
          restroomLocation.latitude,
          restroomLocation.longitude,
        );
        bool shouldAddMarker = false;
        print(selectedFilter);

        if (distance <= radius) {
          if (selectedFilter == null || selectedFilter!.toLowerCase() == 'all') {
            shouldAddMarker = true;
          } else if (selectedFilter!.toLowerCase() == 'female' && genderArray != null && genderArray.contains('Female')) {
            shouldAddMarker = true;
          } else if (selectedFilter!.toLowerCase() == 'male' && genderArray != null && genderArray.contains('Male')) {
            shouldAddMarker = true;
          }
          else if (selectedFilter!.toLowerCase() == 'others' && genderArray != null && genderArray.contains('Others')) {
            shouldAddMarker = true;
          }else if (selectedFilter!.toLowerCase() == 'handicapped' && handicappedAccessible) {
            shouldAddMarker = true;
            print("only handicappped $handicappedAccessible ");
          }
        }

        if (shouldAddMarker) {
          LatLng latLng = LatLng(restroomLocation.latitude, restroomLocation.longitude);
          addMarker(latLng,document);
        }
      }
    });
    print("markersSet DONE ===============");
    print(markersSet);
  }

  void addMarker(LatLng latLng,DocumentSnapshot document) async{
  Position cPosition =await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  GeoPoint? restroomLocation = (document.data() as Map<String, dynamic>)['location'];

  double distance = calculateDistance(
  cPosition.latitude,
  cPosition.longitude,
  restroomLocation!.latitude,
  restroomLocation.longitude,
  );
  double distanceInOneDecimalPoint = double.parse(distance.toStringAsFixed(1));
    setState(() {
      markersSet.add(Marker(
        markerId: MarkerId(latLng.toString()),
        position: latLng,
        icon: BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(
          title: '${document['name']} :\t ${distance.toStringAsFixed(1)} km ',
          snippet: 'Ratings : ${document['ratings']}',
          onTap: () async{
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        RestroomPageUser(document: document,
                          dist: distance.toStringAsFixed(1),
                          pos: cPosition,
                          restroomloc: latLng,
                        )));
          },
        ),
      ));

    });
  }
  bool _isSignedIn = false;
  String uEmail="";
  getUserLoggedInStatus() async {
    await SharedPreference.getUserLoggedInStatus().then((value) {
      if (value != null) {
        setState(() {
          _isSignedIn = value;
        });
      }
    });
  }

  getUserLoggedInEmail() async {
    await SharedPreference.getUserEmailFromSF().then((value) {
      if (value != null) {
        setState(() {
          uEmail = value;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    locateUserPosition();
    getUserLoggedInStatus();
    getUserLoggedInEmail();
    print(uEmail);
  }
  @override
  void didChangeDependencies() {
    getUserLoggedInStatus();
    getUserLoggedInEmail();
    print(uEmail);


  }



  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          // backgroundColor: Colors.black,
          title: RichText(
            text: TextSpan(
                style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                children: <TextSpan>[
                  const TextSpan(text: 'Rest', style: TextStyle(color: Colors.black)),
                  TextSpan(
                      text: 'Ez', style: TextStyle(color: Colors.blueAccent[700]))
                ]
            ),
          ),
          actions: [
            IconButton(
                onPressed: () async{
                  Position cPosition =await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
                  DocumentSnapshot<Map<String, dynamic>> restroomDoc = await FirebaseFirestore.instance.collection('restrooms').doc('0o1xX1rv4BLWMhbgwy9r').get(); //ztQP5fpjvZtUNGiduAAz
                  GeoPoint? restroomLocation = (restroomDoc.data() as Map<String, dynamic>)['location'];

                  double distance = calculateDistance(
                    cPosition.latitude,
                    cPosition.longitude,
                    restroomLocation!.latitude,
                    restroomLocation.longitude,
                  );
                  LatLng latLng = LatLng(restroomLocation.latitude, restroomLocation.longitude);
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => RestroomPageUser(
                  //           document: restroomDoc,
                  //           dist:distance.toStringAsFixed(1),
                  //           pos: cPosition, restroomloc: latLng,
                  //
                  //         )
                  //     ));

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HelpPage(),
                      ));
                },
                icon: const Icon(
                  Icons.help,
                  color: Colors.black,
                  size: 25,
                )),

            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NotificationScreen(),
                      ));
                },
                icon: const Icon(
                  Icons.notifications,
                  color: Colors.black,
                  size: 25,
                ))
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(55),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
                  child: Container(
                    height: 45,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(
                            color: const Color.fromARGB(255, 216, 214, 214)),
                        borderRadius: BorderRadius.circular(10)),
                    child: DropdownButton(
                      elevation: 0,
                      menuMaxHeight: 300,
                      hint: const Text("Filter Restrooms "),
                      dropdownColor: Colors.blue.shade50,
                      icon: const Icon(Icons.arrow_drop_down),
                      iconSize: 30,
                      isExpanded: true,
                      style:const TextStyle(
                        color: Colors.black,
                        fontSize: 19,
                      ),
                      value:selectedFilter,
                      onChanged: (newValue)async{
                        setState(() {
                          selectedFilter = newValue as String;
                          markersSet.clear();
                        });
                        Position cPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
                        fetchNearbyRestrooms(cPosition);
                      },


                      items: _filterOptions.map((valueItem){
                        return DropdownMenuItem(

                            value:valueItem,
                            child:Text(valueItem,style:const TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                            ),),


                        );
                      }).toList(),
                      underline: Container(),
                    ),
                  ),
                ),

              ],
            ),
          ),

        ),
        body:
        Stack(
          children: [
            GoogleMap(
                mapType: MapType.normal,
                myLocationButtonEnabled: true,
                zoomGesturesEnabled: true,
                zoomControlsEnabled: true,
                initialCameraPosition:_kGooglePlex,
              polylines: polylineSet,
              markers: markersSet,
              circles: circlesSet,
              onMapCreated: (GoogleMapController controller){
                  _controller.complete(controller);
                  newGoogleMapController=controller;

                  setState(() {

                  });
                  // locateUserPosition();
              },
              onCameraMove: (CameraPosition? position){
                  if(pickLocation!=position!.target){
                    setState(() {
                      pickLocation=position.target;
                    });
                  }
              },
              onCameraIdle: (){
                  // getAddressFromLatLng();
              },
            )
          ],
        ),
        bottomNavigationBar: CustomBottomNavigationBar(
          index: 0,
        ),

      ),
    );
  }
}


class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar({
    super.key,
    required this.index,

  });

  final int index;


  @override
  State<CustomBottomNavigationBar> createState() => _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  bool _isSignedIn = false;
  String uEmail="";
  getUserLoggedInStatus() async {
    await SharedPreference.getUserLoggedInStatus().then((value) {
      if (value != null) {
        setState(() {
          _isSignedIn = value;
        });
      }
    });
  }

  getUserLoggedInEmail() async {
    await SharedPreference.getUserEmailFromSF().then((value) {
      if (value != null) {
        setState(() {
          uEmail = value;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();

    getUserLoggedInStatus();
    getUserLoggedInEmail();
    print(uEmail);
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
          border: Border(
              top: BorderSide(color: Color.fromARGB(255, 209, 208, 208)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => UserPage()));
            },
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                  border: Border(
                    top: widget.index == 0
                        ? const BorderSide(
                        color: Color.fromRGBO(66, 130, 200, 1), width: 2)
                        : const BorderSide(width: 2, color: Colors.white),
                  )),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map,
                    color: widget.index == 0 ? Colors.blue[700] : Colors.grey[500],
                    size: 26,
                  ),
                  Text(
                    "Home",
                    style: TextStyle(
                        color:
                        widget.index == 0 ? Colors.blue[700] : Colors.grey[500],
                        fontSize: 12,
                        fontWeight: FontWeight.w400),
                  )
                ],
              ),
            ),
          ),

          GestureDetector(
            onTap: ()async {
              if(_isSignedIn){
                String? name = await getNameByEmail(uEmail);
                if (name != null) {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => UserProfile(uname: name, uemail:uEmail,)));
                }
                else{}

              }
              else{
                showDialog(context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("You need to Login first"),
                      content: const Text(
                          "Click on login button if you want to save"),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("Leave"),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        UserLoginPage()
                                  //         SignupPageUser
                                ));
                          },
                          child: const Text("Login"),
                        ),
                      ],
                    );
                  },);
              }
            },
            child: Container(
              height: 60,
              //color: Color.fromRGBO(66, 130, 200, 1), width: 2)
              //                         : BorderSide(width: 2, color: Colors.white),
              decoration: BoxDecoration(
                  border: Border(
                    top: widget.index == 1
                        ? const BorderSide(
                        color: Color.fromRGBO(66, 130, 200, 1), width: 2)
                        : const BorderSide(width: 2, color: Colors.white),
                  )),
              child: _isSignedIn?
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  FutureBuilder<String?>(
                    future: getNameByEmail(uEmail),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Icon(Icons.person,size: 16,color: Colors.white,); // Placeholder while loading
                      } else if (snapshot.hasError) {
                        return const Icon(Icons.person,size: 16,color: Colors.black,);
                      } else {
                        if (snapshot.data != null) {
                          // Data retrieved successfully
                          return CircleAvatar(
                            backgroundColor: Colors.blue[800],
                            radius: 12,
                            child: Text(
                              Utils.getInitials("${snapshot.data}"),
                              style: const TextStyle(fontSize: 10, color: Colors.white),
                            ),
                          );
                        } else {
                          // No user found
                          return CircleAvatar(
                              backgroundColor: Colors.blue[800],
                              radius: 12,
                              child: const Icon(Icons.person,size: 16,color: Colors.white,)
                          );
                        }
                      }
                    },
                  ),

                  Text(
                    "Profile",
                    style: TextStyle(
                        color:
                        widget.index == 1 ? Colors.blue[700] : Colors.grey[500],
                        fontSize: 13,
                        fontWeight: FontWeight.w400),
                  )
                ],
              ):
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                      backgroundColor: Colors.blue[800],
                      radius: 12,
                      child: const Icon(Icons.person,size: 16,color: Colors.white,)
                  ),

                  Text(
                    "Profile",
                    style: TextStyle(
                        color:
                        widget.index == 1 ? Colors.blue[700] : Colors.grey[500],
                        fontSize: 13,
                        fontWeight: FontWeight.w400),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Future<String?> getNameByEmail(String email) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first['name'];
      } else {
        print('No user found with email: $email');
        return null;
      }
    } catch (error) {
      print('Error fetching user data: $error');
      return null;
    }
  }
}