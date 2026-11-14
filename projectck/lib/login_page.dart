import 'package:flutter/material.dart';
import 'package:projectck/authen_result.dart';
import 'package:projectck/helper.dart';
import 'package:projectck/member_repository.dart';

class LoginPage extends StatefulWidget {
  final String _title;
  const LoginPage({super.key, required this._title});
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? _error;
  bool _obscure = true;
  bool _needVerify = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget._title)),
      body: buildFormCard(
        context,
        icon: Icons.lock_outline,
        title: 'Chào mừng trở lại',
        subtitle: 'Đăng nhập để tiếp tục',
        children: [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          SizedBox(height: 12),
          TextFormField(
            obscureText: _obscure,
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Mật khẩu',
              prefixIcon: Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscure = !_obscure;
                  });
                },
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            onFieldSubmitted: (val) => _onLogin(),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _onForgot,
              child: Text('Quên mật khẩu?'),
            ),
          ),
          buildMessage(_error, null),
          if (_needVerify)
            TextButton.icon(
              onPressed: _onVerify,
              icon: Icon(Icons.mark_email_read_outlined),
              label: Text('Xác thực email ngay'),
            ),
          SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _onLogin,
            label: Text('Đăng nhập'),
            icon: Icon(Icons.login),
          ),
          SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _onCancel,
            label: Text('Quay lại'),
            icon: Icon(Icons.arrow_back),
          ),
          SizedBox(height: 8),
          TextButton(
            onPressed: _onRegister,
            child: Text('Chưa có tài khoản? Đăng ký ngay'),
          ),
        ],
      ),
    );
  }

  void _onCancel() async {
    Navigator.pop(context, false);
  }

  void _onRegister() async {
    await Navigator.pushNamed(context, '/register');
  }

  void _onForgot() async {
    await Navigator.pushNamed(context, '/forgot_password');
  }

  void _onVerify() async {
    String email = _emailController.text.trim();
    var result = await MemberRepository.sendCode(email);
    if (!mounted) return;
    showMessage(context, result.message);
    var verified = await Navigator.pushNamed(
      context,
      '/verify',
      arguments: email,
    );
    if (verified == true) {
      setState(() {
        _needVerify = false;
        _error = null;
      });
      _onLogin();
    }
  }

  void _onLogin() async {
    AuthenResult result = await MemberRepository.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    if (!mounted) return;
    if (result.success) {
      Navigator.pop(context, true);
      showMessage(context, result.message);
    } else {
      setState(() {
        _error = result.message;
        _needVerify = result.needVerify;
      });
    }
  }
}
