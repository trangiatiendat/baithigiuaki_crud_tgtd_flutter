import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirestoreService {
  //get conllection of notes
  final CollectionReference sanphams =
      FirebaseFirestore.instance.collection('sanphams');

  final FirebaseStorage storage = FirebaseStorage.instance;

  //Anh

  //Create
  Future<DocumentReference<Object?>> themSanPham(String tensanpham,
      String loaisanpham, int giasanpham, File? imageFile) async {
    String imageUrl = '';

    // Kiểm tra xem có ảnh hay không
    if (imageFile != null) {
      // Tạo tên cho ảnh
      String fileName = imageFile.path.split('/').last;

      // Tải ảnh lên Firebase Storage
      try {
        TaskSnapshot snapshot =
            await storage.ref('products/$fileName').putFile(imageFile);
        imageUrl = await snapshot.ref.getDownloadURL(); // Lấy URL của ảnh
        print('Image uploaded successfully!'); // Thông báo thành công
        print('Image URL: $imageUrl'); // In ra URL
      } catch (e) {
        print('Error uploading image: $e');
        // Có thể ném một lỗi, hoặc quay lại một URL mặc định
        // throw e; // Nếu bạn muốn ném lỗi
        // Hoặc, chỉ cần lưu mà không có hình ảnh
      }
    }

    // Lưu thông tin sản phẩm vào Firestore
    return sanphams.add({
      'tensanpham': tensanpham,
      'loaisanpham': loaisanpham,
      'giasanpham': giasanpham,
      'imageUrl': imageUrl // Lưu URL của ảnh
    });
  }

  //Read
  Stream<QuerySnapshot> laythongtinSanPham() {
    final sanphamSteam = sanphams
        .orderBy('tensanpham', descending: true)
        .orderBy('loaisanpham', descending: true)
        .orderBy('giasanpham', descending: true)
        .orderBy('imageUrl')
        .snapshots();
    return sanphamSteam;
  }

  //Update
  Future<void> capnhatSanPham(String docID, String tensanpham,
      String loaisanpham, int giasanpham, File? newImageFile) async {
    String imageUrl = '';

    // Nếu có ảnh mới, tải lên và cập nhật URL
    if (newImageFile != null) {
      String fileName = newImageFile.path.split('/').last;

      try {
        TaskSnapshot snapshot =
            await storage.ref('products/$fileName').putFile(newImageFile);
        imageUrl = await snapshot.ref.getDownloadURL(); // Lấy URL của ảnh
        print('Image updated successfully!'); // Thông báo thành công
        print('Updated Image URL: $imageUrl'); // In ra URL
      } catch (e) {
        print('Error updating image: $e');
        // Có thể ném một lỗi hoặc để lại imageUrl là rỗng
      }
    } else {
      // Nếu không có hình ảnh mới, giữ lại URL cũ
      imageUrl = await sanphams
          .doc(docID)
          .get()
          .then((doc) => doc['imageUrl'] as String);
    }

    // Cập nhật thông tin sản phẩm vào Firestore
    return sanphams.doc(docID).update({
      'tensanpham': tensanpham,
      'loaisanpham': loaisanpham,
      'giasanpham': giasanpham,
      'imageUrl': imageUrl,
      // Cập nhật với URL hiện tại, hoặc giữ lại nếu không có ảnh mới
    });
  }

  //Delete

  // Xóa sản phẩm
  Future<void> xoaSanPham(String docID) async {
    try {
      // Lấy URL hình ảnh từ Firestore
      String imageUrl = await sanphams.doc(docID).get().then((doc) {
        return doc['imageUrl'] as String;
      });

      // Xóa hình ảnh trong Firebase Storage
      if (imageUrl.isNotEmpty) {
        String fileName = imageUrl.split('/').last; // Lấy tên file từ URL
        try {
          await storage.ref('products/$fileName').delete(); // Xóa file
          print('Hình ảnh đã được xóa thành công!');
        } catch (e) {
          print('Hình ảnh không tồn tại hoặc đã bị xóa trước đó: $e');
        }
      }

      // Xóa sản phẩm trong Firestore
      await sanphams.doc(docID).delete();
      print('Sản phẩm đã được xóa thành công!');
    } catch (e) {
      print('Lỗi khi xóa sản phẩm hoặc hình ảnh: $e');
    }
  }
}
