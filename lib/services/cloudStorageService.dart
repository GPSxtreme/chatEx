import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class CloudStorageService {
  static Future<String> addGrpImageGetLink(
      String fileNameWithPath, dynamic imagePath) async {
    String url = "";
    Reference ref = FirebaseStorage.instance.ref().child(fileNameWithPath);
    await ref.putFile(File(imagePath));
    await ref.getDownloadURL().then((val) {
      url = val;
    });
    return url;
  }

  static Future updateUserProfilePic(dynamic imagePath) async {
    final _auth = FirebaseAuth.instance;
    Reference ref = FirebaseStorage.instance
        .ref()
        .child("userProfilePictures/${_auth.currentUser?.uid}.jpg");
    await ref.putFile(File(imagePath));
  }
  static Future<String> downloadLocalImg(String imgName,String filePath,String cloudStorageDir)async{
    late String result;
    try{
      final storageRef = FirebaseStorage.instance.ref();
      Reference imgRef = storageRef.child("$cloudStorageDir/$imgName");
      final file = File(filePath);
      final downloadTask = await imgRef.writeToFile(file);
      switch (downloadTask.state) {
        case TaskState.success:
          result = filePath;
          break;
        case TaskState.canceled:
          result = "error";
          break;
        case TaskState.error:
          result = "error";
          break;
        default:
          result = "error";
          break;
      }
    } catch(e){
      print(e);
      result = "error";
    }
    return result;
  }
  static Future<String> reDownloadUserProfilePicture()async{
    final _auth = FirebaseAuth.instance;
    final _fireStore = FirebaseFirestore.instance;
    String userName = "";
    await _fireStore.collection("users").doc(_auth.currentUser!.uid).get().then((value){
      userName = value["userName"];
    });
    final appDocDir = await getExternalStorageDirectory();
    String imgName = "${_auth.currentUser!.uid}_${userName}.jpg";
    String filePath = "${appDocDir?.path}/userData/$imgName";
    String cloudImgName = "${_auth.currentUser!.uid}.jpg";
    await CloudStorageService.downloadLocalImg(cloudImgName,filePath,"userProfilePictures");
    return filePath;
  }
}