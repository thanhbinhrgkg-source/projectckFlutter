import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projectck/api_result.dart';
import 'package:projectck/category.dart';
import 'package:projectck/category_repository.dart';
import 'package:projectck/helper.dart';

class CategoryPage extends StatefulWidget {
  final String _title;
  const CategoryPage({super.key, required this._title});

  @override
  State<StatefulWidget> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() async {
    var data = await CategoryRepository.getCategories();
    if (!mounted) return;
    setState(() {
      _categories = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget._title)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _onForm(null),
        icon: Icon(Icons.add),
        label: Text('Thêm danh mục'),
      ),
      body: _categories.isEmpty
          ? buildEmpty(Icons.category_outlined, 'Chưa có danh mục nào')
          : ListView.builder(
              padding: EdgeInsets.fromLTRB(12, 12, 12, 88),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                Category item = _categories[index];
                return Card(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: buildImage(
                            item.imageUrl,
                            width: 72,
                            height: 72,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                item.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                              SizedBox(height: 4),
                              buildTag(
                                '${item.productCount} sản phẩm',
                                Theme.of(context).colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => _onForm(item),
                          tooltip: 'Sửa',
                          icon: Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          onPressed: () => _onDelete(item),
                          tooltip: 'Xóa',
                          icon: Icon(Icons.delete_outline, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _onForm(Category? item) async {
    final nameController = TextEditingController(text: item?.name ?? '');
    final descriptionController = TextEditingController(
      text: item?.description ?? '',
    );
    String? imagePath;
    bool removeImage = false;
    String? error;
    var result = await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            bool hasOld = !removeImage && item?.imageUrl != null;
            return AlertDialog(
              title: Text(item == null ? 'Thêm danh mục' : 'Sửa danh mục'),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          height: 160,
                          child: imagePath != null
                              ? Image.file(File(imagePath!), fit: BoxFit.cover)
                              : hasOld
                              ? buildImage(item!.imageUrl)
                              : buildImage(null),
                        ),
                      ),
                      Wrap(
                        children: [
                          TextButton.icon(
                            onPressed: () async {
                              XFile? file = await ImagePicker().pickImage(
                                source: ImageSource.gallery,
                                maxWidth: 1200,
                              );
                              if (file == null) return;
                              setDialogState(() {
                                imagePath = file.path;
                                removeImage = false;
                              });
                            },
                            icon: Icon(Icons.photo_library_outlined),
                            label: Text('Chọn ảnh'),
                          ),
                          if (imagePath != null || hasOld)
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              onPressed: () {
                                setDialogState(() {
                                  imagePath = null;
                                  removeImage = true;
                                });
                              },
                              icon: Icon(Icons.hide_image_outlined),
                              label: Text('Xóa ảnh'),
                            ),
                        ],
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(labelText: 'Tên danh mục'),
                      ),
                      SizedBox(height: 12),
                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(labelText: 'Mô tả'),
                      ),
                      buildMessage(error, null),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('Hủy'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    ApiResult ret = item == null
                        ? await CategoryRepository.add(
                            nameController.text.trim(),
                            descriptionController.text.trim(),
                            imagePath,
                          )
                        : await CategoryRepository.update(
                            item.id,
                            nameController.text.trim(),
                            descriptionController.text.trim(),
                            imagePath,
                            removeImage,
                          );
                    if (!context.mounted) return;
                    if (ret.success) {
                      Navigator.pop(context, ret.message);
                    } else {
                      setDialogState(() {
                        error = ret.message;
                      });
                    }
                  },
                  icon: Icon(Icons.save),
                  label: Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    );
    if (!mounted) return;
    if (result is String) {
      showMessage(context, result);
      _loadCategories();
    }
  }

  void _onDelete(Category item) async {
    var confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: Icon(Icons.warning_amber, color: Colors.red, size: 40),
          title: Text('Xóa danh mục'),
          content: Text('Bạn có chắc muốn xóa "${item.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: Text('Xóa'),
            ),
          ],
        );
      },
    );
    if (confirm != true) return;
    ApiResult result = await CategoryRepository.delete(item.id);
    if (!mounted) return;
    showMessage(context, result.message);
    if (result.success) _loadCategories();
  }
}
