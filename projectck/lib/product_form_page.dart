import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projectck/api_result.dart';
import 'package:projectck/category.dart';
import 'package:projectck/category_repository.dart';
import 'package:projectck/helper.dart';
import 'package:projectck/product.dart';
import 'package:projectck/product_repository.dart';

class ProductFormPage extends StatefulWidget {
  final String _title;
  const ProductFormPage({super.key, required this._title});

  @override
  State<StatefulWidget> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  int? _id;
  Product? _product;
  List<Category> _categories = [];
  int? _categoryId;
  String? _imagePath;
  String? _error;
  bool _saving = false;
  bool _loaded = false;
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _quotaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _id = ModalRoute.of(context)!.settings.arguments as int?;
      _loadData();
    }
  }

  void _loadCategories() async {
    var data = await CategoryRepository.getCategories();
    if (!mounted) return;
    setState(() {
      _categories = data;
    });
  }

  void _loadData() async {
    if (_id == null) return;
    Product? obj = await ProductRepository.getProductById(_id!);
    if (!mounted || obj == null) return;
    setState(() {
      _product = obj;
      _categoryId = obj.categoryId;
      _nameController.text = obj.name;
      _descriptionController.text = obj.description;
      _priceController.text = obj.price.round().toString();
      _quotaController.text = obj.quota.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _id == null ? 'Thêm ${widget._title}' : 'Sửa ${widget._title}',
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    InkWell(
                      onTap: _onPickImage,
                      borderRadius: BorderRadius.circular(12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(height: 200, child: _buildPreview()),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _onPickImage,
                      icon: Icon(Icons.photo_library_outlined),
                      label: Text(
                        _imagePath == null && _product == null
                            ? 'Chọn hình ảnh'
                            : 'Đổi hình ảnh khác',
                      ),
                    ),
                    if (_product != null && _imagePath != null)
                      Text(
                        'Ảnh cũ sẽ được xóa khỏi máy chủ khi lưu',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    SizedBox(height: 12),
                    InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Danh mục',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          isDense: true,
                          value: _categoryId,
                          hint: Text('Chọn danh mục'),
                          items: _categories.map((p) {
                            return DropdownMenuItem(
                              value: p.id,
                              child: Text(p.name),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _categoryId = val;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Tên gói dịch vụ',
                        prefixIcon: Icon(Icons.inventory_2_outlined),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Mô tả',
                        alignLabelWithHint: true,
                        prefixIcon: Icon(Icons.notes),
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      spacing: 12,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Giá (đ)',
                              prefixIcon: Icon(Icons.sell_outlined),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _quotaController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Số phiếu',
                              prefixIcon: Icon(Icons.how_to_vote_outlined),
                            ),
                          ),
                        ),
                      ],
                    ),
                    buildMessage(_error, null),
                    SizedBox(height: 16),
                    Row(
                      spacing: 12,
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pop(context, false),
                            icon: Icon(Icons.close),
                            label: Text('Hủy'),
                          ),
                        ),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _saving ? null : _onSave,
                            icon: Icon(Icons.save),
                            label: Text('Lưu'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreview() {
    if (_imagePath != null) {
      return Image.file(File(_imagePath!), fit: BoxFit.cover);
    }
    if (_product != null) {
      return buildImage(_product!.imageUrl);
    }
    return Container(
      color: Colors.grey.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 48,
            color: Colors.grey,
          ),
          SizedBox(height: 8),
          Text('Bấm để chọn hình ảnh sản phẩm'),
        ],
      ),
    );
  }

  void _onPickImage() async {
    XFile? file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
    );
    if (file == null) return;
    setState(() {
      _imagePath = file.path;
    });
  }

  void _onSave() async {
    double? price = double.tryParse(_priceController.text.trim());
    int? quota = int.tryParse(_quotaController.text.trim());
    if (_categoryId == null) {
      setState(() => _error = 'Vui lòng chọn danh mục');
      return;
    }
    if (price == null || quota == null) {
      setState(() => _error = 'Giá và số phiếu phải là số');
      return;
    }
    if (_id == null && _imagePath == null) {
      setState(() => _error = 'Vui lòng chọn hình ảnh sản phẩm');
      return;
    }
    Product obj = Product(
      id: _id,
      categoryId: _categoryId!,
      categoryName: null,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: price,
      quota: quota,
      imageUrl: '',
      createdDate: null,
    );
    setState(() {
      _saving = true;
    });
    ApiResult result = _id == null
        ? await ProductRepository.add(obj, _imagePath)
        : await ProductRepository.update(obj, _imagePath);
    if (!mounted) return;
    if (result.success) {
      showMessage(context, result.message);
      Navigator.pop(context, true);
    } else {
      setState(() {
        _saving = false;
        _error = result.message;
      });
    }
  }
}
