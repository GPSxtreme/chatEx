import 'package:chat_room/services/cloudStorageService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DatabaseService{
  static Future<String> addNewGroup(String name,String createdBy,String uid)async{
    final _fireStore = FirebaseFirestore.instance;
    String grpId = "";
    final now = DateTime.now();
    String date = DateFormat.yMd().add_jm().format(now);
    await _fireStore.collection("groups").add({
      "groupId":"",
      "groupIcon":"",
      "createdBy":createdBy,
      "name":name,
      "createdDate":date,
      "members":FieldValue.arrayUnion(["${uid}_$createdBy"]),
    }).then((docRef) async {
      grpId = docRef.id;
      await _fireStore.collection("groups").doc(docRef.id).update({
        "groupId":grpId
      });
      await _fireStore.collection("users").doc(uid).update({
        "joinedGroups":FieldValue.arrayUnion([docRef.id])
      });
      }
    );
    return grpId;
  }
  static Future updateGroupDetails(String grpId,String grpField,String value)async{
    final _fireStore = FirebaseFirestore.instance;
    await _fireStore.collection("groups").doc(grpId).update({
      grpField : value
    });
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
      "members":FieldValue.arrayUnion(["${_auth.currentUser?.uid}_${userDetails["userName"]}"])
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
  static Future deleteGroup(String groupId,String groupIconPath)async{
    final _fireStore = FirebaseFirestore.instance;
    final groupDetails = await _fireStore.collection("groups").doc(groupId).get();
      for(var member in groupDetails["members"]){
        String memberUid = member.toString().split("_")[0];
        await _fireStore.collection("users").doc(memberUid).update({
          "joinedGroups": FieldValue.arrayRemove([groupId])
        });
      }
    await CloudStorageService.removeCloudStorageFile(groupIconPath);
    await _fireStore.collection("groups").doc(groupId).delete();
  }
}