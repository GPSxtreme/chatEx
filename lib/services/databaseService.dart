import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DatabaseService{
  static Future addNewGroup(String name,String createdBy,String uid,String grpIcon)async{
    final _fireStore = FirebaseFirestore.instance;
    final now = DateTime.now();
    String date = DateFormat.yMd().add_jm().format(now);
    final newGrp = _fireStore.collection("groups").add({
      "createdBy":createdBy,
      "groupId":"",
      "name":name,
      "createdDate":date,
      "groupId":"",
      "groupIcon":grpIcon,
      "members":FieldValue.arrayUnion([createdBy]),
    }).then((docRef){
      _fireStore.collection("groups").doc(docRef.id).update({
        "groupId":docRef.id
      });
      _fireStore.collection("users").doc(uid).update({
        "joinedGroups":FieldValue.arrayUnion([docRef.id])
      });
      }
    );
  }
  static Future<bool> isUserAlreadyInGrp(String grpId)async{
    final _fireStore = FirebaseFirestore.instance;
    final _auth = FirebaseAuth.instance;
    final userDetails = await _fireStore.collection("users").doc(_auth.currentUser?.uid).get();
    for(var grp in userDetails["joinedGroups"]){
      if(grp == grpId){
        return true;
      }
    }
    return false;
  }
  static void addUserToGroup(String grpId)async{
    final _fireStore = FirebaseFirestore.instance;
    final _auth = FirebaseAuth.instance;
    final userDetails = await _fireStore.collection("users").doc(_auth.currentUser?.uid).get();
    await _fireStore.collection("users").doc(_auth.currentUser?.uid).update({
      "joinedGroups":FieldValue.arrayUnion([grpId])
    });
    await _fireStore.collection("groups").doc(grpId).update({
      "members":FieldValue.arrayUnion([userDetails["userName"]])
    });
  }
  static Future updateUserName(String name)async{
    final _fireStore = FirebaseFirestore.instance;
    final _auth = FirebaseAuth.instance;
    await _fireStore.collection("users").doc(_auth.currentUser?.uid).update({
      "userName":name
    });
  }
  static Future updateUserAbout(String about)async{
    final _fireStore = FirebaseFirestore.instance;
    final _auth = FirebaseAuth.instance;
    await _fireStore.collection("users").doc(_auth.currentUser?.uid).update({
      "about":about
    });
  }
}