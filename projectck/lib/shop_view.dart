import 'package:flutter/material.dart';
import 'package:projectck/cart.dart';
import 'package:projectck/cart_repository.dart';
import 'package:projectck/category.dart';
import 'package:projectck/category_repository.dart';
import 'package:projectck/helper.dart';
import 'package:projectck/page_result.dart';
import 'package:projectck/product.dart';
import 'package:projectck/product_card.dart';
import 'package:projectck/product_repository.dart';
import 'package:projectck/session_helper.dart';

class ShopView extends StatefulWidget {
  final String? email;
  const ShopView({super.key, required this.email});

  @override
  State<StatefulWidget> createState() => _ShopViewState();
}

class _ShopViewState extends State<ShopView> {
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
      pageSize: 6,
    );
    if (!mounted) return;
    setState(() {
      _result = data;
    });
  }

  String get _heading {
    String keyword = _searchController.text.trim();
    if (keyword.isNotEmpty) return 'Kết quả tìm "$keyword"';
    if (_categoryId != null) {
      return _categories
          .firstWhere(
            (p) => p.id == _categoryId,
            orElse: () => _categories.first,
          )
          .name;
    }
    return 'Gói dịch vụ mới nhất';
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.only(bottom: 24),
      children: [
        buildSearchHeader(
          context,
          title: widget.email != null
              ? 'Xin chào, ${widget.email}'
              : 'Xin chào!',
          subtitle: 'Chọn gói dịch vụ khảo sát phù hợp cho doanh nghiệp',
          controller: _searchController,
          hint: 'Tìm gói dịch vụ...',
          onChanged: (val) {
            _page = 1;
            _loadProducts();
          },
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Danh mục',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 104,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 8),
            children: [
              _buildCategory('Tất cả', null, _categoryId == null, () {
                _onCategory(null);
              }),
              ..._categories.map((p) {
                return _buildCategory(
                  p.name,
                  p.imageUrl,
                  _categoryId == p.id,
                  () => _onCategory(p.id),
                );
              }),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _heading,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                '${_result.total} gói',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        if (_result.items.isEmpty)
          buildEmpty(Icons.search_off, 'Không có gói dịch vụ nào')
        else
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: productGridDelegate(),
              itemCount: _result.items.length,
              itemBuilder: (context, index) {
                Product item = _result.items[index];
                return ProductCard(
                  product: item,
                  onTap: () => _onDetails(item.id!),
                  onAddToCart: () => _onAddToCart(item),
                );
              },
            ),
          ),
        SizedBox(height: 8),
        buildPager(_result.page, _result.totalPages, (val) {
          _page = val;
          _loadProducts();
        }),
      ],
    );
  }

  Widget _buildCategory(
    String name,
    String? image,
    bool selected,
    VoidCallback onTap,
  ) {
    ColorScheme color = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 84,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? color.primary : Colors.transparent,
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: image == null
                      ? Container(
                          color: color.primaryContainer,
                          child: Icon(Icons.apps, color: color.primary),
                        )
                      : buildImage(image, width: 56, height: 56),
                ),
              ),
            ),
            SizedBox(height: 4),
            Text(
              name,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? color.primary : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onCategory(int? id) {
    setState(() {
      _categoryId = id;
      _page = 1;
    });
    _loadProducts();
  }

  void _onDetails(int id) async {
    await Navigator.pushNamed(context, '/product', arguments: id);
  }

  void _onAddToCart(Product item) async {
    String? memberId = await SessionHelper.memberId;
    if (!mounted) return;
    if (memberId == null) {
      showMessage(context, 'Vui lòng đăng nhập để thêm vào giỏ hàng');
      return;
    }
    await CartRepository.add(
      Cart(
        id: null,
        memberId: memberId,
        productId: item.id!,
        name: item.name,
        price: item.price,
        imageUrl: item.imageUrl,
        quantity: 1,
      ),
    );
    if (!mounted) return;
    showMessage(context, 'Đã thêm "${item.name}" vào giỏ hàng');
  }
}
