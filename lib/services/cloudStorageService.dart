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

  static Future<String> updateUserProfilePic(dynamic imagePath) async {
    String url = "";
    final _auth = FirebaseAuth.instance;
    Reference ref = FirebaseStorage.instance
        .ref()
        .child("userProfilePictures/${_auth.currentUser?.uid}.jpg");
    await ref.putFile(File(imagePath));
    await ref.getDownloadURL().then((val) {
      url = val;
    });
    return url;
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
}