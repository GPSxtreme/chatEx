import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';


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
