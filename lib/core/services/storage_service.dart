import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  Future<String?> uploadImage(File imageFile, String studentId) async {
    try {
      // Benzersiz bir dosya adı oluştur
      final String fileName = 'images/$studentId/${_uuid.v4()}.jpg';
      final ref = _storage.ref().child(fileName);

      // Dosyayı yükle
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;

      // İndirme URL'sini al
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      //print('Error uploading image: $e');
      return null;
    }
  }

  Future<String?> uploadAudio(String audioPath, String studentId) async {
     try {
      File audioFile = File(audioPath);
      if (!await audioFile.exists()) {
        //print('Audio file does not exist at path: $audioPath');
        return null;
      }
      
      // Benzersiz bir dosya adı oluştur
      final String fileName = 'audio/$studentId/${_uuid.v4()}.m4a';
      final ref = _storage.ref().child(fileName);

      // Dosyayı yükle
      UploadTask uploadTask = ref.putFile(audioFile, SettableMetadata(contentType: 'audio/m4a'));
      TaskSnapshot snapshot = await uploadTask;

      // İndirme URL'sini al
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      //print('Error uploading audio: $e');
      return null;
    }
  }
}
