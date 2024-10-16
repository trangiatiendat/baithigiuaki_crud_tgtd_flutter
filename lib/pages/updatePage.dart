import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:baithigiuaki_tgtd/services/firestore.dart';

class UpdatePage extends StatefulWidget {
  final String docID;
  final String currentName;
  final String currentType;
  final int currentPrice;
  final String currentImageUrl;

  const UpdatePage({
    super.key,
    required this.docID,
    required this.currentName,
    required this.currentType,
    required this.currentPrice,
    required this.currentImageUrl,
  });

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  final FirestoreService firestoreService = FirestoreService();
  TextEditingController tenSanPham = TextEditingController();
  TextEditingController loaiSanPham = TextEditingController();
  TextEditingController giaSanPham = TextEditingController();
  File? _image;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    tenSanPham.text = widget.currentName;
    loaiSanPham.text = widget.currentType;
    giaSanPham.text = widget.currentPrice.toString();
  }

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
          "Cập Nhật Sản Phẩm",
          style: TextStyle(color: Colors.purple, fontSize: 25, fontWeight: FontWeight.bold),
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
                labelText: 'Tên Sản Phẩm',
                labelStyle: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 30.0),
            TextField(
              controller: loaiSanPham,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Loại Sản Phẩm',
                labelStyle: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 30.0),
            TextField(
              controller: giaSanPham,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Giá',
                labelStyle: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: () async {
                int price = int.tryParse(giaSanPham.text) ?? 0;

                // Gọi hàm cập nhật sản phẩm với các thông tin
                await firestoreService.capnhatSanPham(
                  widget.docID,
                  tenSanPham.text,
                  loaiSanPham.text,
                  price,
                  _image, // Truyền File cho ảnh mới
                );

                // Quay lại trang trước sau khi cập nhật
                Navigator.pop(context);
                // Hiển thị thông báo cập nhật thành công
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Sản phẩm đã được cập nhật thành công!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              child: Text(
                'Cập nhật sản phẩm',
                style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
