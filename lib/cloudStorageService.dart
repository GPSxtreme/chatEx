import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class CloudStorageService {
  static Future<String> addGrpImageGetLink(String fileNameWithPath,dynamic imagePath)async{
    String url = "";
    Reference ref = FirebaseStorage.instance.ref().child(fileNameWithPath);
    await ref.putFile(File(imagePath));
    await ref.getDownloadURL().then(
            (val){
          url = val;
        }
    );
    return url;
  }
}