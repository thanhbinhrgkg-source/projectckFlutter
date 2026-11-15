import 'package:flutter/material.dart';
import 'package:projectck/cart.dart';
import 'package:projectck/cart_repository.dart';
import 'package:projectck/helper.dart';
import 'package:projectck/page_result.dart';
import 'package:projectck/product.dart';
import 'package:projectck/product_card.dart';
import 'package:projectck/product_repository.dart';
import 'package:projectck/session_helper.dart';

class ProductDetailPage extends StatefulWidget {
  final String _title;
  const ProductDetailPage({super.key, required this._title});

  @override
  State<StatefulWidget> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int? _id;
  Product? _product;
  PageResult<Product> _related = PageResult.empty();
  int _relatedPage = 1;
  int _quantity = 1;
  bool _loaded = false;
  bool _loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _id = ModalRoute.of(context)!.settings.arguments as int;
      _loadData();
    }
  }

  void _loadData() async {
    Product? obj = await ProductRepository.getProductById(_id!);
    if (!mounted) return;
    setState(() {
      _product = obj;
      _loading = false;
    });
    _loadRelated();
  }

  void _loadRelated() async {
    var data = await ProductRepository.getRelated(
      _id!,
      page: _relatedPage,
      pageSize: 4,
    );
    if (!mounted) return;
    setState(() {
      _related = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget._title),
        actions: [
          ValueListenableBuilder<int>(
            valueListenable: CartRepository.count,
            builder: (context, count, child) {
              return IconButton(
                onPressed: () => Navigator.pushNamed(context, '/cart'),
                icon: Badge(
                  isLabelVisible: count > 0,
                  label: Text('$count'),
                  child: Icon(Icons.shopping_cart_outlined),
                ),
              );
            },
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _product == null
          ? buildEmpty(Icons.search_off, 'Không tìm thấy sản phẩm')
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    ColorScheme color = Theme.of(context).colorScheme;
    Product p = _product!;
    return ListView(
      children: [
        AspectRatio(aspectRatio: 3 / 2, child: buildImage(p.imageUrl)),
        Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTag(p.categoryName ?? '', color.primary),
              SizedBox(height: 8),
              Text(
                p.name,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                Helper.money(p.price),
                style: TextStyle(
                  fontSize: 22,
                  color: color.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.how_to_vote_outlined, color: Colors.grey),
                  SizedBox(width: 6),
                  Expanded(child: Text('Bao gồm ${p.quota} phiếu khảo sát')),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'Mô tả',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(p.description, style: TextStyle(height: 1.4)),
              SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        'Số lượng',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Spacer(),
                      IconButton(
                        onPressed: _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                        icon: Icon(Icons.remove_circle_outline),
                      ),
                      Text(
                        '$_quantity',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _quantity++),
                        icon: Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 52),
                ),
                onPressed: () => _onAddToCart(p, _quantity),
                label: Text('Thêm vào giỏ hàng'),
                icon: Icon(Icons.add_shopping_cart),
              ),
              SizedBox(height: 24),
              Text(
                'Sản phẩm liên quan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              if (_related.items.isEmpty)
                Text(
                  'Không có sản phẩm liên quan',
                  style: TextStyle(color: Colors.grey.shade600),
                )
              else ...[
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: productGridDelegate(),
                  itemCount: _related.items.length,
                  itemBuilder: (context, index) {
                    Product item = _related.items[index];
                    return ProductCard(
                      product: item,
                      onTap: () => _onDetails(item.id!),
                      onAddToCart: () => _onAddToCart(item, 1),
                    );
                  },
                ),
                buildPager(_related.page, _related.totalPages, (val) {
                  _relatedPage = val;
                  _loadRelated();
                }),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _onDetails(int id) async {
    await Navigator.pushNamed(context, '/product', arguments: id);
  }

  void _onAddToCart(Product item, int quantity) async {
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
        quantity: quantity,
      ),
    );
    if (!mounted) return;
    showMessage(context, 'Đã thêm $quantity "${item.name}" vào giỏ hàng');
  }
}
