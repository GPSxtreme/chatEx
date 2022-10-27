import 'package:auto_size_text/auto_size_text.dart';
import 'package:chat_room/pages/profileUserShow.dart';
import 'package:chat_room/pages/welcomeScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chat_room/consts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:ionicons/ionicons.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:intl/intl.dart';

final _fireStore = FirebaseFirestore.instance;
late User loggedUser;
late String grpId;

class chatScreen extends StatefulWidget {
  chatScreen({Key? key}) : super(key: key);
  static String id = 'chat_screen';
  @override
  State<chatScreen> createState() => _chatScreenState();
}

class _chatScreenState extends State<chatScreen> {
  Map data = {};
  final msgTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String msgTxt = '';
  dynamic userDetails = {};
  bool _isLoading = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser ()async {
    try{
      final user =  _auth.currentUser;
      if(user!=null){
        loggedUser = user;
      }
      userDetails = await _fireStore.collection('users').doc(loggedUser.uid).get();
      setState(() {
        _isLoading = false;
      });
    }
    catch(e){
      print(e);
    }
  }

 superUserDelAllMsg () async {
    final messages = await _fireStore.collection('messages').get();
    final docs = messages.docs;
    for(var doc in docs){
      _fireStore.collection('messages').doc(doc.id).delete();
    }
    Navigator.of(context).pop();
}
popOutOfContext(){
  Navigator.of(context).pop();
}
userLogOut(){
  _auth.signOut();
  Navigator.popAndPushNamed(context, welcomeScreen.id);
}

    @override
  Widget build(BuildContext context) {
      data = data.isNotEmpty? data: ModalRoute.of(context)?.settings.arguments as Map;
      grpId = data['groupId'];
      return _isLoading ? ModalProgressHUD(inAsyncCall: true, child:Container(color: Colors.black,) ) :Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        title: Text(data["groupName"],style: GoogleFonts.poppins(),),
        backgroundColor: Colors.white24,
        elevation: 5,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 5,horizontal: 5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Colors.black26
            ),
            child:  Row(
                children:[
                  if(userDetails["userName"] == data["createdBy"]) ...[
                    TextButton(onPressed: () {
                      showDialogBox(
                        context,
                        'DELETE ALL MESSAGES?',
                        "This process is permanent and cannot be undone",
                        Colors.red,
                        superUserDelAllMsg,
                        popOutOfContext,
                      );
                    }, child: const Icon(Ionicons.trash_bin,color: Colors.red,size: 25,)),
                  ],
                  TextButton(onPressed: (){
                    showDialogBox(
                        context,
                        'Log Out?',
                        "You can login again by entering your credentials.",
                        Colors.red,
                        userLogOut,
                        popOutOfContext
                    );
                  }, child: const Icon(Ionicons.log_out_outline,color: Colors.red,size: 25,)),
                  TextButton(onPressed: (){
                    showSnackBar(context, 'Coming soon under progress :)', 2200);
                  },
                    child: const Icon(Ionicons.settings_outline,color: Colors.red,size: 25,),
                  )
                ]
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 20,),
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
                const SizedBox(width: 10,),
                Expanded(
                  child: buildTextField(context),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }



  //TextField chat screen
  TextField buildTextField(BuildContext context) {
    return TextField(
    controller: msgTextController,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      decoration: kMsgInputContainerDecoration.copyWith(
          suffixIcon: IconButton(onPressed: (){
            final now = DateTime.now();
            String formatter = DateFormat.yMd().add_jm().format(now);
            final sortTime = Timestamp.now();
            if(msgTxt.isNotEmpty){
              msgTextController.clear();
              _fireStore.collection("groups").doc(data["groupId"]).collection("messages").add({
                'text':msgTxt,
                'senderUid':loggedUser.uid,
                'senderEmail':loggedUser.email,
                'senderUserName':userDetails['userName'],
                'createdAt': formatter,
                'timeSort':sortTime
              });
            }
            else{
              showSnackBar(context,'Please fill in a message',1100);
            }
          }, icon: const Icon(Icons.send,color: Colors.blue,size: 30,)
          )
      ),
    onChanged: (value){
      msgTxt = value;
    },
  );
  }
}
//message fetching service
class MessageStream extends StatelessWidget {
  const MessageStream({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _fireStore.collection("groups").doc(grpId).collection("messages").orderBy('timeSort').snapshots(),
        builder: (context,snapshot){
          if(snapshot.hasData){
            final messages = snapshot.data?.docs.reversed;
            List<MessageBubble> messageWidgets = [];
            for(var message in messages!){
              final msgSenderUid = message.get('senderUid');
              final msgSenderUserName = message.get('senderUserName');
              final msgTxt = message.get('text');
              final msgTime = message.get('createdAt');
              messageWidgets.add(MessageBubble(senderUid: msgSenderUid,senderUserName: msgSenderUserName ,text: msgTxt,isMe:msgSenderUid == loggedUser.uid,time: msgTime,msgId: message.id,));
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

//message bubble
class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.senderUid,required this.senderUserName, required this.text,required this.isMe,required this.time,required this.msgId});
  final String senderUid;
  final String senderUserName;
  final String text;
  final bool isMe;
  final String time;
  final String msgId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end:MainAxisAlignment.start,
        children: [
          if(isMe) ...[
            TextButton(onPressed: (){
              _fireStore.collection("groups").doc(grpId).collection("messages").doc(msgId).delete();
            },
                child: const Icon(Ionicons.trash_bin,size: 25,color: Colors.red,)
            )
          ],
          Column(
            mainAxisAlignment: isMe ? MainAxisAlignment.end:MainAxisAlignment.start,
            children: [
              Material(
                borderRadius: isMe ? const BorderRadius.only(topLeft: Radius.circular(10),bottomLeft:Radius.circular(10),bottomRight: Radius.circular(10)): const BorderRadius.only(topRight: Radius.circular(10),bottomLeft:Radius.circular(10),bottomRight: Radius.circular(10)) ,
                elevation: 5.0,
                color: Colors.white24,
                child: Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width*0.75),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0,horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if(!isMe) ...[
                          GestureDetector(
                            onTap: (){
                              Navigator.pushReplacementNamed(context, profileUserShow.id,arguments: {"senderUid":senderUid});
                            },
                              child: Text(senderUserName,style:  GoogleFonts.poppins(color: Colors.amber,fontSize: 17,decoration: TextDecoration.underline),)
                          ),
                          const SizedBox(height: 5,),
                        ],
                        Text(
                          text,
                          style:GoogleFonts.poppins(
                            fontSize: 17,
                            color: Colors.white
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ),
              const SizedBox(height: 4,),
              Text(time.substring(11),style: const TextStyle(color: Colors.white,fontSize: 12,fontStyle: FontStyle.italic),),
            ],
          ),
        ],
      ),
    );
  }
}
