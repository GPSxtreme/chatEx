import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'components/groupCreatePopUp.dart';


const kTextFieldInputDecoration = InputDecoration(
    hintText: '',
    labelText: '',
    labelStyle: TextStyle(color: Colors.white,fontSize: null),
    hintStyle: TextStyle(color: Colors.white),
    contentPadding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 20),
    border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: Colors.white,width: 2.0),
    ),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: Colors.white,width: 2.0),
    ),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: Colors.orangeAccent,width: 2.0),
    ),
);
InputDecoration kMsgInputContainerDecoration = InputDecoration(
    filled: true,
    fillColor: HexColor("2e2e2e"),
    hintText: 'Type your message here...',
    hintStyle: GoogleFonts.poppins(color: Colors.white70,fontWeight: FontWeight.w400),
    border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(28)),
        borderSide: BorderSide(color: Colors.white30,width: 2.0),
    ),
    enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(28)),
        borderSide: BorderSide(color: Colors.white30,width: 2.0),
    ),
    focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(28)),
        borderSide: BorderSide(color: Colors.white30,width: 2.0),
    ),
);

void showSnackBar(BuildContext buildContext ,String txt, int duration){
    ScaffoldMessenger.of(buildContext).showSnackBar(
        SnackBar(
            content: SizedBox(
                width: MediaQuery.of(buildContext).size.width*0.80,
                child: AutoSizeText(txt,
                    style:GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                    ),
                    maxLines: 2,
                ),
            ),
            backgroundColor: Colors.red,
            shape: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            duration: Duration(milliseconds: duration),
        ));
}

//alertBox
Future showDialogBox(BuildContext context, title,String msg,Color titleColor,void Function()? yes,void Function()? no){
    return showDialog(context: context,
        builder: (BuildContext context){
            return AlertDialog(
                elevation: 5,
                backgroundColor: HexColor("#3f434a"),
                title: Text(title,style: TextStyle(color: titleColor,fontWeight: FontWeight.bold,),),
                content: SingleChildScrollView(
                    child: ListBody(
                        children:  [
                            Text(msg,style: const TextStyle(color: Colors.white))
                        ],
                    ),
                ),
                actions: [
                    TextButton(onPressed: yes,
                        child: const Text('Yes',style: TextStyle(color: Colors.white),)),
                    TextButton(onPressed: no,
                        child: const Text('No',style: TextStyle(color: Colors.white),)),
                ],
            );
        }
    );
}
class HelperFunctions{
    //contains helper functions
    static popUpGrpCreateDialog(BuildContext context,String userName,String userUid){
        showDialog(
            barrierColor: Colors.black54,
            barrierDismissible: false,
            context: context,
            builder: (context){
                return GroupCreatePopUp(userName: userName,userUid: userUid);
            }
        );
    }
}