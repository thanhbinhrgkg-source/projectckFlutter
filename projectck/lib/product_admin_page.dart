import 'package:flutter/material.dart';
import 'package:projectck/api_result.dart';
import 'package:projectck/category.dart';
import 'package:projectck/category_repository.dart';
import 'package:projectck/helper.dart';
import 'package:projectck/page_result.dart';
import 'package:projectck/product.dart';
import 'package:projectck/product_repository.dart';

class ProductAdminPage extends StatefulWidget {
  final String _title;
  const ProductAdminPage({super.key, required this._title});

  @override
  State<StatefulWidget> createState() => _ProductAdminPageState();
}

class _ProductAdminPageState extends State<ProductAdminPage> {
  List<Category> _categories = [];
  PageResult<Product> _result = PageResult.empty();
  int? _categoryId;
  int _page = 1;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadProducts();
  }

  void _loadCategories() async {
    var data = await CategoryRepository.getCategories();
    if (!mounted) return;
    setState(() {
      _categories = data;
    });
  }

  void _loadProducts() async {
    var data = await ProductRepository.getProducts(
      categoryId: _categoryId,
      keyword: _searchController.text.trim(),
      page: _page,
      pageSize: 8,
    );
    if (!mounted) return;
    setState(() {
      _result = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget._title)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _onForm(null),
        icon: Icon(Icons.add),
        label: Text('Thêm sản phẩm'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm sản phẩm...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (val) {
                    _page = 1;
                    _loadProducts();
                  },
                ),
                SizedBox(height: 8),
                InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Danh mục',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int?>(
                      isExpanded: true,
                      isDense: true,
                      value: _categoryId,
                      items: [
                        DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Tất cả danh mục'),
                        ),
                        ..._categories.map((p) {
                          return DropdownMenuItem<int?>(
                            value: p.id,
                            child: Text('${p.name} (${p.productCount})'),
                          );
                        }),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _categoryId = val;
                          _page = 1;
                        });
                        _loadProducts();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Tổng số: ${_result.total} sản phẩm',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          Expanded(
            child: _result.items.isEmpty
                ? buildEmpty(Icons.inventory_2_outlined, 'Không có sản phẩm')
                : ListView.builder(
                    padding: EdgeInsets.fromLTRB(12, 4, 12, 8),
                    itemCount: _result.items.length,
                    itemBuilder: (context, index) =>
                        _buildItem(_result.items[index]),
                  ),
          ),
          buildPager(_result.page, _result.totalPages, (val) {
            _page = val;
            _loadProducts();
          }),
          SizedBox(height: 72),
        ],
      ),
    );
  }

  Widget _buildItem(Product item) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: buildImage(item.imageUrl, width: 84, height: 64),
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
                    item.categoryName ?? '',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  Text(
                    '${Helper.money(item.price)} • ${item.quota} phiếu',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _onForm(item.id),
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
  }

  void _onForm(int? id) async {
    var result = await Navigator.pushNamed(
      context,
      '/product_form',
      arguments: id,
    );
    if (result == true) {
      _loadCategories();
      _loadProducts();
    }
  }

  void _onDelete(Product item) async {
    var confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: Icon(Icons.warning_amber, color: Colors.red, size: 40),
          title: Text('Xóa sản phẩm'),
          content: Text(
            'Bạn có chắc muốn xóa "${item.name}"? Hình ảnh của sản phẩm cũng sẽ bị xóa.',
          ),
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
    ApiResult result = await ProductRepository.delete(item.id!);
    if (!mounted) return;
    showMessage(context, result.message);
    if (result.success) {
      _loadCategories();
      _loadProducts();
    }
  }
}
