import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class pPage extends StatefulWidget {
  const pPage({super.key});

  @override
  State<pPage> createState() => _pPageState();
}

class _pPageState extends State<pPage> {
  String location="press button";
  String address="search";
  Future<Position> determinePosition() async{
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled =await Geolocator.isLocationServiceEnabled();
    if(!serviceEnabled){
      await Geolocator.openLocationSettings();
      return Future.error("Location service are disabled");
    }
    permission=await Geolocator.checkPermission();
    if(permission==LocationPermission.denied){
      permission=await Geolocator.requestPermission();
      if(permission==LocationPermission.denied){
        return Future.error("Location permission are denied");

      }
    }
    if(permission==LocationPermission.deniedForever){
      return Future.error("Location Permission are permanently denie,we cannot request permission");

    }
    return await Geolocator.getCurrentPosition();

  }
Future<void> GetAddressFromLatLong(Position position)async{
    List<Placemark> placemark=await placemarkFromCoordinates(position.latitude, position.longitude);
    print(placemark);
    Placemark place=placemark[0];
    address='${place.name}, ${place.street}, ${place.thoroughfare}, ${place.subLocality}, ${place.postalCode}, ${place.country}';
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Coordinate points"),
            SizedBox(height: 10,),

            Text(location),
            SizedBox(height: 10,),

            Text("ADDRESS "),
            SizedBox(height: 10,),

            Text("${address} "),
            SizedBox(height: 10,),


            ElevatedButton(
                onPressed: ()async{
                  Position pos=await determinePosition();
                  print(pos.latitude);
                  location="Lat :${pos.latitude},Long : ${pos.longitude}";

                  GetAddressFromLatLong(pos);
                  setState(() {


                  });
                },
                child: Text("Get LOcation"),
            )


          ],
        ),
      ),
    );
  }
}
