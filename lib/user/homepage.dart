import 'dart:async';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
// import 'package:location/location.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();

}

class _UserPageState extends State<UserPage> {
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
    Position cPosition =await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition=cPosition;

    LatLng latLngPosition=LatLng(userCurrentPosition!.latitude,userCurrentPosition!.longitude);
    CameraPosition cameraPosition=CameraPosition(target: latLngPosition,zoom: 15);

    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));


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

        ),
        body: Stack(
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
                  locateUserPosition();
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

      ),
    );
  }
}
