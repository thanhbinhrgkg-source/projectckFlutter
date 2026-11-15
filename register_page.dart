import 'package:flutter/material.dart';
import 'package:projectck/api_result.dart';
import 'package:projectck/helper.dart';
import 'package:projectck/member_repository.dart';

class RegisterPage extends StatefulWidget {
  final String _title;
  const RegisterPage({super.key, required this._title});

  @override
  State<StatefulWidget> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String? _error;
  bool _obscure = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _givenNameController = TextEditingController();
  final _surnameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget._title)),
      body: buildFormCard(
        context,
        icon: Icons.person_add_alt_1,
        title: 'Tạo tài khoản',
        subtitle: 'Mã xác thực sẽ được gửi về email của bạn',
        children: [
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _surnameController,
                  decoration: InputDecoration(
                    labelText: 'Họ',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: _givenNameController,
                  decoration: InputDecoration(labelText: 'Tên'),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
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
              labelText: 'Mật khẩu (ít nhất 6 ký tự)',
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
          ),
          SizedBox(height: 12),
          TextFormField(
            obscureText: _obscure,
            controller: _confirmController,
            decoration: InputDecoration(
              labelText: 'Nhập lại mật khẩu',
              prefixIcon: Icon(Icons.lock_reset),
            ),
          ),
          buildMessage(_error, null),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _onRegister,
            label: Text('Đăng ký'),
            icon: Icon(Icons.person_add),
          ),
          SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _onCancel,
            label: Text('Quay lại'),
            icon: Icon(Icons.arrow_back),
          ),
        ],
      ),
    );
  }

  void _onCancel() async {
    Navigator.pop(context, false);
  }

  void _onRegister() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    if (password != _confirmController.text.trim()) {
      setState(() {
        _error = "Mật khẩu nhập lại không khớp";
      });
      return;
    }
    ApiResult result = await MemberRepository.register(
      email,
      password,
      _givenNameController.text.trim(),
      _surnameController.text.trim(),
    );
    if (!mounted) return;
    if (result.success) {
      showMessage(context, result.message);
      await Navigator.pushReplacementNamed(
        context,
        '/verify',
        arguments: email,
        result: false,
      );
    } else {
      setState(() {
        _error = result.message;
      });
    }
  }
}
