import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DatabaseService{
  static void addNewGroup(String name,String createdBy,String uid)async{
    final _fireStore = FirebaseFirestore.instance;
    final now = DateTime.now();
    String date = DateFormat.yMd().add_jm().format(now);
    final newGrp = _fireStore.collection("groups").add({
      "createdBy":createdBy,
      "groupId":"",
      "name":name,
      "createdDate":date,
      "groupId":"",
      "groupIcon":"",
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
}