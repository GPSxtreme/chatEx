import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class roundedBtn extends StatelessWidget {
  roundedBtn({required this.title,required this.onPressed});
  final String title;
  final void Function() onPressed;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            )
        ),
        child: Text(title,style: GoogleFonts.poppins(color: Colors.black,fontSize: 20,
          fontWeight: FontWeight.w400,),),
      ),
    );
  }
}
