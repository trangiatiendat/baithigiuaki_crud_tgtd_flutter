import 'package:baithigiuaki_tgtd/pages/updatePage.dart';
import 'package:flutter/material.dart';
import 'package:baithigiuaki_tgtd/services/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:baithigiuaki_tgtd/pages/addPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Add()));
        },
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Danh Sách Sản Phẩm",
              style: TextStyle(
                  color: Colors.purple,
                  fontSize: 25,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.laythongtinSanPham(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List sanphamList = snapshot.data!.docs;

            return ListView.builder(
              itemCount: sanphamList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = sanphamList[index];

                Map<String, dynamic> data =
                document.data() as Map<String, dynamic>;
                String tensanpham =
                    data['tensanpham'] ?? 'Không có tên sản phẩm';
                String loaisanpham =
                    data['loaisanpham'] ?? 'Không có loại sản phẩm';
                int giasanpham = data['giasanpham'] ?? 0;
                String imageUrl = data['imageUrl'] ?? ''; // Lấy URL hình ảnh

                return Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Tên Sản Phẩm: $tensanpham",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Loại Sản Phẩm: $loaisanpham",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Giá Sản Phẩm: $giasanpham VND",
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        // Hiển thị hình ảnh
                        imageUrl.isNotEmpty
                            ? Center(
                          // Thêm Center widget để căn giữa hình ảnh
                          child: Image.network(
                            imageUrl,
                            height: 250, // Chiều cao tùy chỉnh
                            width: 250, // Chiều rộng tùy chỉnh
                            fit: BoxFit.cover, // Điều chỉnh hình ảnh
                          ),
                        )
                            : Center(
                          // Căn giữa thông báo không có hình ảnh
                          child: Text('Không có hình ảnh'),
                        ),
                        SizedBox(height: 10),
                        // Sử dụng Row để căn chỉnh các nút
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UpdatePage(
                                      docID: document.id, // ID của sản phẩm
                                      currentName: tensanpham, // Tên sản phẩm hiện tại
                                      currentType: loaisanpham, // Loại sản phẩm hiện tại
                                      currentPrice: giasanpham, // Giá sản phẩm hiện tại
                                      currentImageUrl: imageUrl, // URL hình ảnh hiện tại
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                // Hiển thị hộp thoại xác nhận trước khi xóa
                                bool? confirmDelete = await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('Xác nhận xóa'),
                                      content: Text('Bạn có chắc chắn muốn xóa sản phẩm này không?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          child: Text('Không'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(true),
                                          child: Text('Có'),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (confirmDelete == true) {
                                  // Gọi hàm xóa sản phẩm mà không cần truyền imageUrl
                                  await firestoreService.xoaSanPham(document.id);

                                  // Cập nhật giao diện
                                  setState(() {});
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return const Text("No Result...");
          }
        },
      ),
    );
  }
}
