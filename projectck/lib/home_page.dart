import 'package:flutter/material.dart';
import 'package:projectck/cart_repository.dart';
import 'package:projectck/helper.dart';
import 'package:projectck/member_repository.dart';
import 'package:projectck/role.dart';
import 'package:projectck/session_helper.dart';
import 'package:projectck/shop_view.dart';
import 'package:projectck/survey_view.dart';

class HomePage extends StatefulWidget {
  final String _title;

  const HomePage({super.key, required this._title});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tab = 0;
  int _version = 0;
  String? _memberId;
  String? _email;
  String? _role;
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    var mId = await SessionHelper.memberId;
    var eml = await SessionHelper.email;
    var rl = await SessionHelper.role;
    await CartRepository.refreshCount();
    if (!mounted) return;
    setState(() {
      _memberId = mId;
      _email = eml;
      _role = rl;
    });
  }

  bool get _isLogin => _memberId != null && _memberId!.isNotEmpty;

  bool get _isManager => _role == 'manager' || _role == 'admin';

  bool get _isAdmin => _role == 'admin';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.poll_rounded),
            SizedBox(width: 8),
            Flexible(
              child: Text(widget._title, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        actions: [
          ValueListenableBuilder<int>(
            valueListenable: CartRepository.count,
            builder: (context, count, child) {
              return IconButton(
                onPressed: _onCart,
                tooltip: 'Giỏ hàng',
                icon: Badge(
                  isLabelVisible: count > 0,
                  label: Text('$count'),
                  child: Icon(Icons.shopping_cart_outlined),
                ),
              );
            },
          ),
          Builder(
            builder: (context) {
              return IconButton(
                onPressed: () => Scaffold.of(context).openEndDrawer(),
                icon: Icon(Icons.menu),
              );
            },
          ),
        ],
      ),
      endDrawer: _buildDrawer(),
      floatingActionButton: _tab == 1 && _isManager
          ? FloatingActionButton.extended(
              onPressed: _onNewSurvey,
              icon: Icon(Icons.add),
              label: Text('Tạo khảo sát'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (val) {
          setState(() {
            _tab = val;
          });
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Cửa hàng',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Khảo sát',
          ),
        ],
      ),
      body: _tab == 0
          ? ShopView(key: ValueKey('shop$_version'), email: _email)
          : SurveyView(key: ValueKey('survey$_version')),
    );
  }

  Widget _buildDrawer() {
    Color primary = Theme.of(context).colorScheme.primary;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: primary),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                Helper.initial(_email),
                style: TextStyle(
                  fontSize: 28,
                  color: primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            accountName: Text(
              _isLogin ? Role.label(_role) : 'Khách',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              _email ?? 'Đăng nhập để mua gói và làm khảo sát',
            ),
          ),
          if (!_isLogin) ...[
            _buildItem(Icons.login, 'Đăng nhập', _onLogin),
            _buildItem(Icons.person_add, 'Đăng ký', _onRegister),
          ] else ...[
            _buildItem(Icons.person, 'Hồ sơ', () => _onOpen('/profile')),
            _buildItem(
              Icons.receipt_long,
              'Đơn hàng của tôi',
              () => _onOpen('/orders'),
            ),
            _buildItem(
              Icons.password,
              'Đổi mật khẩu',
              () => _onOpen('/change_password'),
            ),
            if (_isManager) ...[
              Divider(),
              _buildHeader('Khảo sát'),
              _buildItem(Icons.add_box, 'Tạo khảo sát', _onNewSurvey),
              _buildItem(
                Icons.list_alt,
                'Khảo sát của tôi',
                () => _onOpen('/my_survey'),
              ),
            ],
            if (_isAdmin) ...[
              Divider(),
              _buildHeader('Quản trị'),
              _buildItem(
                Icons.category,
                'Quản lý danh mục',
                () => _onOpen('/categories'),
              ),
              _buildItem(
                Icons.inventory_2,
                'Quản lý sản phẩm',
                () => _onOpen('/admin_products'),
              ),
              _buildItem(
                Icons.local_shipping,
                'Quản lý đơn hàng',
                () => _onOpen('/admin_orders'),
              ),
              _buildItem(Icons.group, 'Thành viên', () => _onOpen('/member')),
              _buildItem(
                Icons.admin_panel_settings,
                'Vai trò',
                () => _onOpen('/roles'),
              ),
            ],
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Đăng xuất', style: TextStyle(color: Colors.red)),
              onTap: () => _onDrawer(_onLogout),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(String text) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () => _onDrawer(onTap),
    );
  }

  void _onDrawer(VoidCallback action) {
    Navigator.pop(context);
    action();
  }

  void _onOpen(String route) async {
    await Navigator.pushNamed(context, route);
    if (!mounted) return;
    setState(() {
      _version++;
    });
    await CartRepository.refreshCount();
  }

  void _onCart() async {
    if (!_isLogin) {
      showMessage(context, 'Vui lòng đăng nhập để xem giỏ hàng');
      return;
    }
    await Navigator.pushNamed(context, '/cart');
  }

  void _onRegister() async {
    await Navigator.pushNamed(context, '/register');
  }

  void _onLogin() async {
    var result = await Navigator.pushNamed(context, '/login');
    if (result == true) {
      await _loadData();
    }
  }

  void _onNewSurvey() async {
    await Navigator.pushNamed(context, '/survey');
    if (!mounted) return;
    setState(() {
      _version++;
    });
  }

  void _onLogout() async {
    await MemberRepository.logout();
    if (!mounted) return;
    showMessage(context, 'Đã đăng xuất');
    setState(() {
      _email = null;
      _memberId = null;
      _role = null;
    });
  }
}
