import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
