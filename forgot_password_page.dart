import 'package:flutter/material.dart';
import 'package:projectck/api_result.dart';
import 'package:projectck/helper.dart';
import 'package:projectck/member_repository.dart';

class ForgotPasswordPage extends StatefulWidget {
  final String _title;
  const ForgotPasswordPage({super.key, required this._title});

  @override
  State<StatefulWidget> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  bool _sent = false;
  String? _error;
  String? _info;
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget._title)),
      body: buildFormCard(
        context,
        icon: Icons.lock_reset,
        title: 'Quên mật khẩu',
        subtitle: _sent
            ? 'Nhập mã xác thực và mật khẩu mới'
            : 'Nhập email để nhận mã đặt lại mật khẩu',
        children: [
          TextFormField(
            controller: _emailController,
            enabled: !_sent,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          if (_sent) ...[
            SizedBox(height: 12),
            TextFormField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Mã xác thực',
                prefixIcon: Icon(Icons.pin_outlined),
              ),
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Mật khẩu mới',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _confirmController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Nhập lại mật khẩu mới',
                prefixIcon: Icon(Icons.lock_reset),
              ),
            ),
          ],
          buildMessage(_error, _info),
          SizedBox(height: 16),
          if (!_sent)
            ElevatedButton.icon(
              onPressed: _onSend,
              label: Text('Gửi mã xác thực'),
              icon: Icon(Icons.send),
            )
          else ...[
            ElevatedButton.icon(
              onPressed: _onReset,
              label: Text('Đặt lại mật khẩu'),
              icon: Icon(Icons.check),
            ),
            SizedBox(height: 8),
            TextButton.icon(
              onPressed: _onSend,
              icon: Icon(Icons.refresh),
              label: Text('Gửi lại mã'),
            ),
          ],
        ],
      ),
    );
  }

  void _onSend() async {
    ApiResult result = await MemberRepository.forgotPassword(
      _emailController.text.trim(),
    );
    if (!mounted) return;
    setState(() {
      _sent = _sent || result.success;
      _error = result.success ? null : result.message;
      _info = result.success ? result.message : null;
    });
  }

  void _onReset() async {
    if (_passwordController.text != _confirmController.text) {
      setState(() {
        _error = 'Mật khẩu nhập lại không khớp';
        _info = null;
      });
      return;
    }
    ApiResult result = await MemberRepository.resetPassword(
      _emailController.text.trim(),
      _codeController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) return;
    if (result.success) {
      showMessage(context, result.message);
      Navigator.pop(context, true);
    } else {
      setState(() {
        _error = result.message;
        _info = null;
      });
    }
  }
}
