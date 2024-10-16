import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:baithigiuaki_tgtd/services/firestore.dart';

class Add extends StatefulWidget {
  const Add({super.key});

  @override
  State<Add> createState() => _AddState();
}

class _AddState extends State<Add> {
  final FirestoreService firestoreService = FirestoreService();
  TextEditingController tenSanPham = TextEditingController();
  TextEditingController loaiSanPham = TextEditingController();
  TextEditingController giaSanPham = TextEditingController();
  File? _image;
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Thêm Sản Phẩm",
          style: TextStyle(
              color: Colors.purple, fontSize: 25, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            TextField(
              controller: tenSanPham,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Tên Sản Phẩm.',
                labelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 30.0),
            TextField(
              controller: loaiSanPham,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Loại Sản Phẩm.',
                labelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 30.0),
            TextField(
              controller: giaSanPham,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Giá.',
                labelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 30.0),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    _image != null ? 'Ảnh đã chọn' : 'Chọn Ảnh Sản Phẩm',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: () async {
                int price = int.tryParse(giaSanPham.text) ?? 0;
                // Gọi hàm thêm sản phẩm với các thông tin và ảnh
                await firestoreService.themSanPham(
                    tenSanPham.text, loaiSanPham.text, price, _image);

                // Xóa nội dung sau khi thêm
                tenSanPham.clear();
                loaiSanPham.clear();
                giaSanPham.clear();
                setState(() {
                  _image = null;
                });
                // Có thể thêm thông báo cho người dùng về việc thêm sản phẩm thành công
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Sản phẩm đã được thêm thành công!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              child: Text(
                'Thêm sản phẩm.',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
