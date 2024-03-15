import 'dart:async';
import 'dart:math';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:location/location.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();

}

class _UserPageState extends State<UserPage> {
  String? selectedFilter;
  List<String> _filterOptions = ['All', 'Female', 'Male', 'Handicapped'];


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
      if (restroomLocation != null) {
        double distance = calculateDistance(
          userPosition.latitude,
          userPosition.longitude,
          restroomLocation.latitude,
          restroomLocation.longitude,
        );
        if (distance <= radius) {
          LatLng latLng = LatLng(restroomLocation.latitude, restroomLocation.longitude);
          addMarker(latLng);
        }
      }
    });
    print("markersSet DONE ===============");
    print(markersSet);
  }

  void addMarker(LatLng latLng) {
    setState(() {
      markersSet.add(Marker(
        markerId: MarkerId(latLng.toString()),
        position: latLng,
        icon: BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(
          title: 'Restroom Information',
          snippet: 'Add your snippet here...',
          onTap: () {
            // Handle marker tap
            // You can use the 'document' variable here to access the document data
            // and display it in a dialog or any other way you prefer.
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Restroom Information'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Add your information here...'),
                      // You can display the data from the document here
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Close'),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ));

    });
  }


  @override
  void initState() {
    super.initState();
    locateUserPosition();
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
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                children: <TextSpan>[
                  TextSpan(text: 'Rest', style: TextStyle(color: Colors.black)),
                  TextSpan(
                      text: 'Ez', style: TextStyle(color: Colors.blueAccent[700]))
                ]
            ),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  // Navigator.push(context,
                  //     MaterialPageRoute(builder: (context) => HelpPage()));
                },
                icon: Icon(
                  Icons.help,
                  color: Colors.black,
                  size: 25,
                )),

            IconButton(
                onPressed: () {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => NotificationScreen()));
                },
                icon: Icon(
                  Icons.notifications,
                  color: Colors.black,
                  size: 25,
                ))
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(55),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20,vertical: 15),
                  child: Container(
                    height: 45,
                    padding: EdgeInsets.symmetric(
                        horizontal: 10),
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(
                            color: Color.fromARGB(255, 216, 214, 214)),
                        borderRadius: BorderRadius.circular(10)),
                    child: DropdownButton(
                      elevation: 0,
                      menuMaxHeight: 300,
                      hint: Text("Filter Restrooms "),
                      dropdownColor: Colors.blue.shade50,
                      icon: Icon(Icons.arrow_drop_down),
                      iconSize: 30,
                      isExpanded: true,
                      style:TextStyle(
                        color: Colors.black,
                        fontSize: 19,
                      ),
                      value:selectedFilter,
                      onChanged: (newValue){
                        setState(() {
                          selectedFilter=newValue as String;;
                        });
                      },


                      items: _filterOptions.map((valueItem){
                        return DropdownMenuItem(

                            value:valueItem,
                            child:Text(valueItem,style:TextStyle(
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


class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({
    super.key,
    required this.index,
  });

  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
          border: Border(
              top: BorderSide(color: Color.fromARGB(255, 209, 208, 208)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => UserPage()));
            },
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                  border: Border(
                    top: index == 0
                        ? BorderSide(
                        color: Color.fromRGBO(66, 130, 200, 1), width: 2)
                        : BorderSide(width: 2, color: Colors.white),
                  )),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.card_giftcard,
                    color: index == 0 ? Colors.blue[700] : Colors.grey[500],
                    size: 26,
                  ),
                  Text(
                    "Home",
                    style: TextStyle(
                        color:
                        index == 0 ? Colors.blue[700] : Colors.grey[500],
                        fontSize: 12,
                        fontWeight: FontWeight.w400),
                  )
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              // Navigator.push(context,
              //     MaterialPageRoute(builder: (context) => ApplicationScreen()));
            },
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                  border: Border(
                    top: index == 1
                        ? BorderSide(
                        color: Color.fromRGBO(66, 130, 200, 1), width: 2)
                        : BorderSide(width: 2, color: Colors.white),
                  )),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.insert_drive_file_rounded,
                    color: index == 1 ? Colors.blue[700] : Colors.grey[500],
                    size: 26,
                  ),
                  Text(
                    "Community",
                    style: TextStyle(
                        color:
                        index == 1 ? Colors.blue[700] : Colors.grey[500],
                        fontSize: 12,
                        fontWeight: FontWeight.w400),
                  )
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              // Navigator.push(
              //     context, MaterialPageRoute(builder: (context) => Profile()));
            },
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                  border: Border(
                    top: index == 3
                        ? BorderSide(
                        color: Color.fromRGBO(66, 130, 200, 1), width: 2)
                        : BorderSide(width: 2, color: Colors.white),
                  )),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue,
                    radius: 12,
                    child: Text(
                      'LK',
                      style: TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                  Text(
                    "Profile",
                    style: TextStyle(
                        color:
                        index == 3 ? Colors.blue[700] : Colors.grey[500],
                        fontSize: 12,
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
}