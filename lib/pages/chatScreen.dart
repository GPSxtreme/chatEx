import 'package:chat_room/pages/groupInfoScreen.dart';
import 'package:chat_room/pages/profileUserShow.dart';
import 'package:chat_room/services/themeDataService.dart';
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
  bool showLoader = false;
  bool isAdmin = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedUser = user;
      }
      userDetails =
          await _fireStore.collection('users').doc(loggedUser.uid).get();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    data = data.isNotEmpty
        ? data
        : ModalRoute.of(context)?.settings.arguments as Map;
    grpId = data['groupId'];
    if(userDetails["userName"] == data["createdBy"]){
      isAdmin = true;
    }
    return _isLoading
        ? ModalProgressHUD(
            inAsyncCall: true,
            child: Container(
              color: MainScreenTheme.mainScreenBg,
            ))
        : ModalProgressHUD(
      inAsyncCall: showLoader,
          child: Scaffold(
              backgroundColor: MainScreenTheme.mainScreenBg,
              appBar: AppBar(
                title: Text(
                  data["groupName"],
                  style: GoogleFonts.poppins(),
                ),
                backgroundColor: Colors.black12,
                elevation: 0,
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, GroupInfoScreen.id,arguments:{"groupId":data["groupId"],"groupImgPath":data["groupImgPath"],"groupName":data["groupName"],"isAdmin":isAdmin} );
                    },
                    child: const Icon(
                      Icons.info_outline,
                      color: Colors.white,
                      size: 25,
                    ),
                  )
                ],
              ),
              body: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: Column(children: const [MessageStream()]),
                  ),
                  Center(
                    child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 15,vertical: 7),
                        child: buildTextField(context)
                    ),
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
      cursorColor: Colors.white,
      decoration: kMsgInputContainerDecoration.copyWith(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15,vertical: 15),
          suffixIcon: IconButton(
              onPressed: () {
                if (msgTxt.isNotEmpty) {
                  final dateTime = DateTime.now();
                  String sentTime = DateFormat('h:mm a').format(dateTime);
                  String sentDay = DateFormat('EEEE, d MMM, yyyy').format(dateTime);
                  final sortTime = Timestamp.now();
                  msgTextController.clear();
                  _fireStore
                      .collection("groups")
                      .doc(data["groupId"])
                      .collection("messages")
                      .add({
                    'text': msgTxt,
                    'senderUid': loggedUser.uid,
                    'senderEmail': loggedUser.email,
                    'senderUserName': userDetails['userName'],
                    'sentTime': sentTime,
                    'sentDay': sentDay,
                    'timeSort': sortTime
                  });
                  msgTxt = "";
                } else {
                  showSnackBar(context, 'Please fill in a message', 800,
                      bgColor: Colors.indigo);
                }
              },
              icon: const Icon(
                Icons.send,
                color: Colors.white,
                size: 30,
              ))),
      onChanged: (value) {
        msgTxt = value;
      },
    );
  }
}

//message fetching service
class MessageStream extends StatefulWidget {
  const MessageStream({Key? key}) : super(key: key);
  static String groupDate = "";
  @override
  State<MessageStream> createState() => _MessageStreamState();
}

class _MessageStreamState extends State<MessageStream> {
  static ScrollController controller = ScrollController();
  static void scrollDown(){
    //animate scroll
    controller.animateTo(
      controller.position.maxScrollExtent,
      duration: const Duration(seconds: 2),
      curve: Curves.fastOutSlowIn,
    );
    //no animate scroll
    // controller.jumpTo(controller.position.maxScrollExtent);
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // scrollDown();
    MessageStream.groupDate = "";
  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _fireStore
            .collection("groups")
            .doc(grpId)
            .collection("messages")
            .orderBy('timeSort')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final messages = snapshot.data?.docs;
            if(messages!.isNotEmpty){
              List<MessageBubble> messageWidgets = [];
              for (var message in messages) {
                final msgSenderUid = message.get('senderUid');
                final msgSenderUserName = message.get('senderUserName');
                final msgTxt = message.get('text');
                final msgTime = message.get('sentTime');
                final msgDay = message.get("sentDay");
                bool show = false;
                if(MessageStream.groupDate != msgDay){
                  MessageStream.groupDate = msgDay;
                  show = true;
                }
                messageWidgets.add(MessageBubble(
                    senderUid: msgSenderUid,
                    senderUserName: msgSenderUserName,
                    text: msgTxt,
                    isMe: msgSenderUid == loggedUser.uid,
                    time: msgTime,
                    msgId: message.id,
                    day: msgDay,
                    show:show
                ));
              }
              return Expanded(
                child: ScrollConfiguration(
                  behavior: const ScrollBehavior(),
                  child: GlowingOverscrollIndicator(
                    axisDirection: AxisDirection.down,
                    color: MainScreenTheme.mainScreenBg,
                    child: ListView(
                      controller: controller,
                      reverse: false,
                      children: messageWidgets,
                    ),
                  ),
                ),
              );
            }else{
              return Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children:  [
                    const Icon(Ionicons.server_outline,size:90,color: Colors.white12,),
                    const SizedBox(height: 10,),
                    Text("Wow so empty..\nStart texting",style: GoogleFonts.poppins(color: Colors.white12,fontSize: 18),textAlign: TextAlign.center,),
                  ],
                ),
              );
            }
          } else {
            return const Expanded(
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            );
          }
        });
  }
}


class MessageBubble extends StatefulWidget {
  const MessageBubble(
      {Key? key,
      required this.senderUid,
      required this.senderUserName,
      required this.text,
      required this.isMe,
      required this.time,
      required this.msgId, required this.day, required this.show
      })
      : super(key: key);
  final String senderUid;
  final String senderUserName;
  final String text;
  final bool isMe;
  final String time;
  final String msgId;
  final String day;
  final bool show;
  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool isSelected = false;
  deleteMsg(){
    _fireStore
        .collection("groups")
        .doc(grpId)
        .collection("messages")
        .doc(widget.msgId)
        .delete();
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        if (widget.isMe) {
          setState(() {
            isSelected = true;
          });
        }
      },
      onLongPressCancel: () {
        if (isSelected) {
          setState(() {
            isSelected = false;
          });
        }
      },
      child: Column(
        children: [
          if(widget.show)
            Column(
            children: [
              const SizedBox(height: 20,),
              Center(
                child: Text("${widget.day.split(',')[0]}\n${widget.day.split(',')[1]}${widget.day.split(',')[2]}",style: GoogleFonts.poppins(color: Colors.white),textAlign: TextAlign.center,),
              ),
              const SizedBox(height: 10,),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? Colors.red : Colors.transparent,
            ),
            child: Row(
              mainAxisAlignment:
                  widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                if (widget.isMe && isSelected) ...[
                  Column(
                    children: [
                      TextButton(
                          onPressed:deleteMsg,
                          child: const Icon(
                            Icons.delete,
                            size: 35,
                            color: Colors.black54,
                          )),
                      const SizedBox(
                        height: 15,
                      ),
                    ],
                  )
                ],
                if(!widget.isMe)
                const SizedBox(width: 7,),
                Column(
                  crossAxisAlignment: widget.isMe ?  CrossAxisAlignment.end:CrossAxisAlignment.start,
                  children: [
                    Material(
                        borderRadius: widget.isMe
                            ? const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10))
                            : const BorderRadius.only(
                                topRight: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10)),
                        color: MainScreenTheme.mainScreenBg == Colors.black ? HexColor("222222"):Colors.black26,
                        child: Container(
                          constraints: BoxConstraints(
                              minWidth:MediaQuery.of(context).size.width * 0.20,
                              maxWidth: MediaQuery.of(context).size.width * 0.75
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 15.0, horizontal: 15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!widget.isMe) ...[
                                  GestureDetector(
                                      onTap: () {
                                        Navigator.pushReplacementNamed(
                                            context, profileUserShow.id,
                                            arguments: {
                                              "senderUid": widget.senderUid,
                                              "isMe": false
                                            });
                                      },
                                      child: Text(
                                        widget.senderUserName,
                                        style: GoogleFonts.poppins(
                                            color: Colors.blue,
                                            fontSize: 17,
                                            decoration: TextDecoration.underline),
                                      )),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                ],
                                SelectableText(
                                  widget.text,
                                  style: GoogleFonts.poppins(
                                      fontSize: 17, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        )
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        if(!widget.isMe)
                        const SizedBox(width: 5,),
                        Text(
                          widget.time,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                        if(widget.isMe)
                          const SizedBox(width: 15,)
                      ],
                    ),
                  ],
                ),
                if(widget.isMe)
                  const SizedBox(width: 17,),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
