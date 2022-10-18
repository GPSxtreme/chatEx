import 'package:auto_size_text/auto_size_text.dart';
import 'package:chat_room/pages/welcomeScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chat_room/consts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:intl/intl.dart';

final _fireStore = FirebaseFirestore.instance;
late User loggedUser;

class chatScreen extends StatefulWidget {
  chatScreen({Key? key}) : super(key: key);
  static String id = 'chat_screen';
  @override
  State<chatScreen> createState() => _chatScreenState();
}

class _chatScreenState extends State<chatScreen> {
  final msgTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String msgTxt = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser (){
    try{
      final user =  _auth.currentUser;
      if(user!=null){
        loggedUser = user;
      }
    }
    catch(e){
      print(e);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        title: Text('Chat Room',style: GoogleFonts.poppins(),),
        centerTitle: true,
        backgroundColor: Colors.white24,
        elevation: 5,
        actions: [
          TextButton(onPressed: (){
            _auth.signOut();
            Navigator.pop(context);
          }, child: const Icon(Ionicons.log_out_outline,color: Colors.red,size: 40,))
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: 20,),
            Expanded(
                child: Column(
                  children: const [
                    MessageStream()
                ]
                ),
              ),
            // Expanded(child: Container()),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 10,),
                Expanded(
                    child: TextField(
                      controller: msgTextController,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                        ),
                      decoration: kMsgInputContainerDecoration,
                      onChanged: (value){
                        msgTxt = value;
                      }
                    )
                ),
                IconButton(onPressed: (){
                    final now = DateTime.now();
                    String formatter = DateFormat.yMd().add_jm().format(now);
                    final sortTime = Timestamp.now();
                  if(msgTxt.isNotEmpty){
                    msgTextController.clear();
                    _fireStore.collection("messages").add({
                      'text':msgTxt,
                      'sender':loggedUser.email,
                      'createdAt': formatter,
                      'timeSort':sortTime
                    });
                  }
                  else{
                    showSnackBar(context,'Please fill in a message',1100);
                  }
                }, icon: const Icon(Icons.send,color: Colors.white,size: 30,))
              ],
            )
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  const MessageStream({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _fireStore.collection('messages').orderBy('timeSort').snapshots(),
        builder: (context,snapshot){
          if(snapshot.hasData){
            final messages = snapshot.data?.docs.reversed;
            List<MessageBubble> messageWidgets = [];
            for(var message in messages!){
              final msgSender = message.get('sender');
              final msgTxt = message.get('text');
              final msgTime = message.get('createdAt');
              messageWidgets.add(MessageBubble(sender: msgSender, text: msgTxt,isMe:msgSender == loggedUser.email,time: msgTime,));
            }
            return Expanded(
              child: ListView(
                reverse: true,
                children: messageWidgets,
              ),
            );
          }else{
            return const Center(
              child: CircularProgressIndicator(color: Colors.amberAccent,),
            );
          }
        }
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.sender,required this.text,required this.isMe,required this.time});
  final String sender;
  final String text;
  final bool isMe;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end:CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 5,),
          Material(
            // borderRadius: BorderRadius.circular(4.0),
            borderRadius: isMe ? const BorderRadius.only(topLeft: Radius.circular(10),bottomLeft:Radius.circular(10),bottomRight: Radius.circular(10)): const BorderRadius.only(topRight: Radius.circular(10),bottomLeft:Radius.circular(10),bottomRight: Radius.circular(10)) ,
            elevation: 5.0,
            color: Colors.white24,
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width*0.7),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0,horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sender.split('@')[0],style:  TextStyle(color: isMe ? Colors.lightBlue:Colors.amberAccent,fontSize: 13,decoration: TextDecoration.underline),),
                    SizedBox(height: 5,),
                    Text(
                      text,
                      style: const TextStyle(color: Colors.white,fontSize: 15),
                    ),
                  ],
                ),
              ),
            )
          ),
          SizedBox(height: 4,),
          Text(time,style: const TextStyle(color: Colors.white,fontSize: 10,fontStyle: FontStyle.italic),),

        ],
      ),
    );
  }
}
