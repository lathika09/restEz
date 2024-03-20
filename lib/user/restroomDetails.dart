import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rest_ez_app/user/RatingsPage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'Profile.dart';

class RestroomPageUser extends StatefulWidget {
  const RestroomPageUser({Key? key,
    required this.document,required this.dist,required this.pos,required this.restroomloc,required this.name
  });

  final DocumentSnapshot document;
  final String dist;
  final Position pos;
  final LatLng restroomloc;
  final String name;

  @override
  State<RestroomPageUser> createState() => _RestroomPageUserState();
}

class _RestroomPageUserState extends State<RestroomPageUser> {
  bool isLiked=false;
  bool expanded = false;
  bool isFav=false;
  bool isAdded=false;
  bool isDeleted=false;


  void navigateToRestroom(Position userPosition, LatLng restroomLocation) async {
    String googleMapsUrl = 'https://www.google.com/maps/dir/?api=1&destination=${restroomLocation.latitude},${restroomLocation.longitude}';
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      // Handle error: unable to launch the URL
    }
  }
  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
        length: 3,//4
        child: Scaffold(
        appBar: CustomAppBar(
          appTitle: "Restroom Details",
          icon: FaIcon(Icons.arrow_back_ios),
          actions: [
            IconButton(
              onPressed: (){
                setState(() {
                  isFav=!isFav;
                });
              },
              icon: FaIcon(
                isFav ? Icons.favorite_rounded:Icons.favorite_outline,
                color: Colors.red,
              ),),
          ],

        ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.document['name'],style: TextStyle(fontWeight: FontWeight.bold,fontSize: 24),),
              Row(
                children: [
                  Text("${widget.document['ratings']}.0 ",style: TextStyle(fontSize: 16)),
                  RatingBar.builder(
                    initialRating: double.parse(widget.document['ratings'].toString()),
                    itemSize: 20,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    ignoreGestures: true,
                    // itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) =>  Icon(
                      Icons.star,
                      color: Colors.amber,
                      // size: 10, // Adjust the size of the stars as needed
                    ),
                    onRatingUpdate: (rating) {
                      print(rating);
                      // You can update the rating here if needed
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  Text("Public Restroom ",style: TextStyle(fontSize: 16)),
                  SizedBox(width: 10,),
                  Icon(Icons.social_distance),
                  Text('  ${widget.dist} km ',style: TextStyle(fontSize: 16))
                ],
              ),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  MaterialButton(
                      elevation: 0,
                      onPressed: () {
                        navigateToRestroom(widget.pos, widget.restroomloc);
                      },
                      color: Colors.blue[700],
                      textColor: Colors.white,
                      padding: EdgeInsets.all(8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(
                          color: Color(0xFFebf1fa),
                          width: 1.0,
                        ),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6,vertical: 4),
                        child: Row(
                          children: [
                            Icon(Icons.directions,color: Colors.white,),
                            Text(
                              "Directions",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )
                  ),
                  MaterialButton(
                      elevation: 0,
                      onPressed: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => GetJobRef_ConPage(),
                        //   ),
                        // );
                      },
                      color: Colors.white,
                      textColor: Colors.blue[700],
                      padding: EdgeInsets.all(8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1.0,
                        ),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6,vertical: 4),
                        child: Row(
                          children: [
                            Icon(Icons.bookmark_border,color: Colors.blue[700],),
                            Text(
                              "Save",
                              style: TextStyle(
                                  color: Colors.blue[700],
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )
                  ),
                  MaterialButton(
                      elevation: 0,
                      onPressed: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => GetJobRef_ConPage(),
                        //   ),
                        // );
                      },
                      color: Colors.white,
                      textColor: Colors.blue[700],
                      padding: EdgeInsets.all(8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1.0,
                        ),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6,vertical: 4),
                        child: Row(
                          children: [
                            Icon(Icons.share,color: Colors.blue[700],),
                            Text(
                              "Share",
                              style: TextStyle(
                                  color: Colors.blue[700],
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )
                  )
                ],
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                height: 1,
                color: Colors.grey[300],),
              TabBar(
                  indicatorColor: Colors.blue[800],
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorWeight: 2,
                  unselectedLabelStyle: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w400,
                      fontSize: 18),
                  labelStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 16),
                  tabs: [
                    Tab(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "About",
                          style: TextStyle(),
                        ),
                      ),
                    ),
                    Tab(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Reviews",
                          style: TextStyle(),
                        ),
                      ),
                    ),
                    Tab(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Photos",
                          style: TextStyle(),
                        ),
                      ),
                    ),
                  ]),
              Expanded(
                child: TabBarView(
                  children: [
                    // About Tab Content
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left:12,right:10,bottom:8,top: 15.0),
                            child: Row(
                              children: [
                                Icon(Icons.location_on_outlined,color: Colors.blue[900],),
                                Expanded(
                                  child: Container(
                                    width: MediaQuery.of(context).size.width/1.5,
                                    padding: const EdgeInsets.only(left: 20.0,right:10,),
                                    child: Text(
                                      widget.document['address'],
                                      style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400,height: 1.5)
                                      ,overflow: TextOverflow.visible,softWrap: true,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.content_copy),
                                  onPressed: () {
                                    copyToClipboard(widget.document['address']);
                                  },
                                ),
                              ],
                            ),
                          ),
                          Divider(),
                          Padding(
                            padding: const EdgeInsets.only(left:12,right:10,bottom:8,top: 15.0),
                            child: Row(
                              children: [
                                Icon(Icons.groups,color: Colors.blue[900],),
                                Expanded(
                                  child: Container(
                                    width: MediaQuery.of(context).size.width/1.5,
                                    padding: const EdgeInsets.only(left: 20.0,right:10),
                                    child: Row(
                                      children: [
                                        widget.document['handicappedAccessible']
                                            ?Text(
                                          'Female , Male, Handicapped',
                                          style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400,)
                                          ,overflow: TextOverflow.visible,softWrap: true,
                                        )
                                        :
                                        Text(
                                          'Female , Male',
                                          style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400,)
                                          ,overflow: TextOverflow.visible,softWrap: true,
                                        ),
                      
                                      ],
                                    ),
                                  ),
                                ),
                      
                      
                              ],
                            ),
                          ),
                          Divider(),
                          Padding(
                            padding: const EdgeInsets.only(left:12,right:10,bottom:8,top: 15.0),
                            child: Row(
                              children: [
                                Icon(Icons.access_alarm,color: Colors.blue[900],),
                                Expanded(
                                  child: Container(
                                    width: MediaQuery.of(context).size.width/1.5,
                                    padding: const EdgeInsets.only(left: 20.0,right:10),
                                    child: Row(
                                      children: [
                                        Text(
                                          widget.document['availabilityHours'],
                                          style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400,color: Colors.green[800])
                                          ,overflow: TextOverflow.visible,softWrap: true,
                                        ),
                                        Icon(Icons.arrow_drop_down_sharp,color: Colors.grey,)
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(),
                          Padding(
                            padding: const EdgeInsets.only(left:12,right:10,bottom:8,top: 15.0),
                            child: Row(
                              children: [
                                Icon(Icons.report,color: Colors.blue[900],),
                                Expanded(
                                  child: Container(
                                    width: MediaQuery.of(context).size.width/1.5,
                                    padding: const EdgeInsets.only(left: 20.0,right:10),
                                    child: Row(
                                      children: [
                      
                                        Text(
                                          'Report Issue',
                                          style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400,)
                                          ,overflow: TextOverflow.visible,softWrap: true,
                                        ),
                      
                                      ],
                                    ),
                                  ),
                                ),
                      
                      
                              ],
                            ),
                          ),
                          Divider(),
                      
                        ],
                      ),
                    ),
                    // Reviews Tab Content
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.only(left: 12,right: 12,bottom: 10,top:18),
                            child: Row(
                              children: [
                                Column(
                                  children: [
                                    Text('${widget.document['ratings']}.0',style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
                                    RatingBar.builder(
                                      initialRating: double.parse(widget.document['ratings'].toString()),
                                      itemSize: 15,
                                      minRating: 0,
                                      direction: Axis.horizontal,
                                      allowHalfRating: true,
                                      itemCount: 5,
                                      ignoreGestures: true,
                                      // itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                                      itemBuilder: (context, _) =>  Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        // size: 10, // Adjust the size of the stars as needed
                                      ),
                                      onRatingUpdate: (rating) {
                                        print(rating);
                                        // You can update the rating here if needed
                                      },
                                    ),
                                    Text('(${widget.document['no_of_reviews']})',style: TextStyle(),)
                                  ],
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      RatingProgress(text: "5", value: 0.1),
                                      RatingProgress(text: "4", value: 0.1),
                                      RatingProgress(text: "3", value: 0.2),
                                      RatingProgress(text: "2", value: 0.0),
                                      RatingProgress(text: "1", value: 0.0),
                                    ],
                                  ),
                                ),
                      
                      
                              ],
                            ),
                          ),
                          Divider(),
                          Container(
                            // color: Colors.black54,
                            padding: EdgeInsets.only(left: 12,right: 12,bottom: 10,top:8),
                            child: Column(
                              crossAxisAlignment:CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text("Rate and Review",style: TextStyle(fontSize: 19,fontWeight: FontWeight.bold),),
                                Text("Share your experience to help others",style: TextStyle(fontSize: 14,color: Colors.black54),),
                                SizedBox(height: 8,),
                                InkWell(
                                  onTap: (){
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => RatingPage(uname: widget.name, document: widget.document,)));
                      
                                  },
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.red[900],
                                        radius: 26,
                                        child: Text(
                                          Utils.getInitials(widget.name),
                                          style: TextStyle(
                                              fontSize: 22, color: Colors.white,fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      SizedBox(width: 20,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children:
                                        List.generate(5, (index) {
                                          int starIndex = index + 1;
                                          return Icon(
                                            Icons.star_border_outlined,
                                            size: 40,
                                            color:Colors.black54,
                                          );
                                        }),

                                      ),
                                    ],
                                  ),
                                ),
                                Center(
                                  child: Container(
                                    margin: EdgeInsets.only(left: 16,top: 8,right: 16),
                                    width: MediaQuery.of(context).size.height/5,
                                    child: MaterialButton(
                                        elevation: 0,
                                        onPressed: () async{
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => RatingPage(uname: widget.name, document: widget.document,)));

                                        },
                                        color: Colors.white,
                                        textColor: Colors.black,
                                        padding: EdgeInsets.all(8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                          side: BorderSide(
                                            color: Color(0xFF979393FF), // Set the border color
                                            width: 1.0,         // Set the border width
                                          ),
                                        ),
                                        child:Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Icon(Icons.edit_note_outlined,color: Colors.blue[800],),
                                            Text("Write a review",style: TextStyle(color:Colors.black,fontSize: 15,),),
                                          ],
                                        )
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(),
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 12.0),
                                  child: Text("Reviews",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                                ),
                                StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('restrooms')
                                      .doc(widget.document.id)
                                      .collection('reviews')
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    }
                                    if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    }
                                    if (!snapshot.hasData ||
                                        snapshot.data!.docs.isEmpty) {
                                      return Text('No reviews available.');
                                    }
                                    // Display the reviews

                                    return Column(
                                      children: snapshot.data!.docs.map((reviewDoc) {
                                        int likesCount = reviewDoc['likeCounts'];
                                        List<dynamic> likedBy = reviewDoc['likedBy'] ?? [];

                                        return Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 15),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: Colors.grey, // Choose your border color
                                                width: 1.0, // Adjust the border width as needed
                                              ),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  CircleAvatar(
                                                    backgroundColor: Colors.blue[800],
                                                    radius: 23,
                                                    child: Text(
                                                      Utils.getInitials(reviewDoc['name']),
                                                      style: TextStyle(
                                                          fontSize: 16, color: Colors.white,fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(left:14.0,right: 14),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text("${reviewDoc['name']}",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                                                        Text("",style: TextStyle(color: Colors.black54,fontSize: 14)),
                                                      ],
                                                    ),
                                                  ),
                                                  Spacer(),
                                                  Icon(FontAwesomeIcons.ellipsisVertical)
                                                ],
                                              ),
                                              SizedBox(height: 10,),
                                              Row(
                                                children: [
                                                   RatingBar.builder(
                                                    initialRating: double.parse('${reviewDoc['rating']}'),
                                                    itemSize: 15,
                                                    minRating: 0,
                                                    direction: Axis.horizontal,
                                                    allowHalfRating: true,
                                                    itemCount: 5,
                                                    // itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                                                    itemBuilder: (context, _) =>  Icon(
                                                      Icons.star,
                                                      color: Colors.amber,
                                                      // size: 10, // Adjust the size of the stars as needed
                                                    ),
                                                    ignoreGestures: true,
                                                    onRatingUpdate: (rating) {
                                                      // rating=rrating;
                                                      // rrating=rating;
                                                      print(rating);
                                                      // You can update the rating here if needed
                                                    },
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 12.0),
                                                    child: Text(getTimeAgo(reviewDoc['timestamp']),style: TextStyle(color: Colors.black54,fontSize: 12),),
                                                  ),

                                                ],
                                              ),
                                              SizedBox(height: 5,),

                                              Container(
                                                  width: MediaQuery.of(context).size.width,
                                                  // height:MediaQuery.of(context).size.height/2,
                                                  child:
                                                  EllipsisText(
                                                    text: "${reviewDoc['comment']}",
                                                    style: TextStyle(fontSize: 15),
                                                  ),

                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(top: 8.0),
                                                child: Row(

                                                  children: [
                                                    IconButton(
                                                      onPressed: (){
                                                        setState(() {
                                                          isLiked=!isLiked;
                                                          if(isLiked & !reviewDoc['likedBy'].contains(widget.name)){
                                                            likedBy.add(widget.name);
                                                            likesCount += 1;
                                                          }
                                                          else{
                                                            likedBy.remove(widget.name);
                                                            if( likesCount == 0){
                                                              likesCount = 0;
                                                            }
                                                            else{
                                                              likesCount -= 1;
                                                            }
                                                          }
                                                        });
                                                        FirebaseFirestore.instance
                                                            .collection('restrooms')
                                                            .doc(widget.document.id)
                                                            .collection('reviews')
                                                            .doc(reviewDoc.id) // Assuming reviewDoc.id is the document ID of the review
                                                            .update({
                                                          'likedBy': likedBy,
                                                          'likeCounts': likesCount});
                                                      },
                                                      icon:reviewDoc['likedBy'].contains(widget.name)
                                                          ?Icon(Icons.thumb_up,color: Colors.blue[800],)
                                                      :
                                                      Icon(Icons.thumb_up_alt_outlined,color: Colors.black54,)

                                                    ),
                                                    // SizedBox(width: 5,),
                                                    Text('${reviewDoc['likeCounts']}'),
                                                    SizedBox(width: 8,),
                                                    Text("Like",style: TextStyle(fontWeight: FontWeight.bold),)
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    );
                                  },
                                ),
                              ],
                            ),
                          )
                      
                      
                          // Add more widgets as needed
                        ],
                      ),
                    ),
                    // Photos Tab Content
                    Column(
                      children: [
                        Text('Photos Tab Content'),
                        // Add more widgets as needed
                      ],
                    ),

                  ],
                ),
              ),


            ],

          ),
        ),

      ),)



    );
  }
  String getTimeAgo(Timestamp timestamp) {
    final now = DateTime.now();
    final createdAt = timestamp.toDate(); // Convert Firestore Timestamp to DateTime
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays >= 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'just now';
    }
  }
}
class EllipsisText extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const EllipsisText({
    Key? key,
    required this.text,
    this.style,
  }) : super(key: key);

  @override
  _EllipsisTextState createState() => _EllipsisTextState();
}

class _EllipsisTextState extends State<EllipsisText> {
  bool get shouldExpand => widget.text.length > 50;

  @override
  Widget build(BuildContext context) {
    return Text(
      widget.text,
      style: widget.style,
      maxLines: shouldExpand ? null : 1,
      overflow: shouldExpand ? TextOverflow.visible : TextOverflow.ellipsis,
    );
  }
}
//Ratings
class RatingProgress extends StatelessWidget {
  const RatingProgress({super.key,required this.text,required this.value});

  final String text;
  final double value;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: [
          Expanded(

              flex:1,
              child: SizedBox()),
          Expanded(
            flex: 1,
              child: Text(text,style: TextStyle(fontSize: 12),)
          ),
          Expanded(
              flex: 11,
              child: SizedBox(
                width: MediaQuery.of(context).size.width/5,
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  backgroundColor: Colors.grey[500],
                  borderRadius: BorderRadius.circular(7),
                  valueColor: AlwaysStoppedAnimation(Colors.amber),
                ),

          ))
        ],
      ),
    );
  }
}



//CUSTOM APP BAR
class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  CustomAppBar({Key? key,this.appTitle,this.route,this.icon,this.actions}) : super(key: key);

  @override

  Size get preferredSize=>const Size.fromHeight(60);
  final String? appTitle;
  final String? route;
  final FaIcon?icon;
  final List<Widget>? actions;

  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: true,
      backgroundColor: Colors.blue[800],
      elevation:2,
      title: Text(widget.appTitle!,style: TextStyle(fontSize: 24,color: Colors.white,fontWeight: FontWeight.bold),),
      leading: widget.icon!=null ? Container(
        margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 10,),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color:Colors.blue[800],
        ),
        child: IconButton(
          onPressed: (){
            if(widget.route!=null){
              Navigator.of(context).pushNamed(widget.route!);
            }
            else{
              Navigator.of(context).pop();
            }
          },
          icon: widget.icon!,
          iconSize: 16,
          color: Colors.white,
        ),
      )
          : null,
      actions: widget.actions ?? null,
    );
  }
}
