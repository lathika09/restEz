import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MakeSuggestion extends StatefulWidget {
  const MakeSuggestion({super.key});

  @override
  State<MakeSuggestion> createState() => _MakeSuggestionState();
}

class _MakeSuggestionState extends State<MakeSuggestion> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            elevation: 3,
            title: const Text("Suggest Restroom", style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),)
        ),
        body:Column(
          children: [
            Expanded(
              child: Container(
                color: Colors.blue[100],
                padding:EdgeInsets.symmetric(horizontal: 17,vertical: 20),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(

                      width: double.infinity,
                        padding:EdgeInsets.symmetric(horizontal: 15,vertical: 18),
                    decoration:BoxDecoration(borderRadius:BorderRadius.circular(30),color: Colors.white,),

                      child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("dmi"),
                            Text("dmi"),
                          ],
                        ),)
                    ],
                  ),
                ),

              ),
            ),
            Center(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16,vertical: 18),
                width: MediaQuery.of(context).size.height/3,
                child: MaterialButton(
                    elevation: 0,
                    onPressed: () async{
                    },
                    color: Colors.blue[700],
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

}
