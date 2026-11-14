import 'package:flutter/material.dart';
import 'package:projectck/api_result.dart';
import 'package:projectck/helper.dart';
import 'package:projectck/member_repository.dart';
import 'package:projectck/session_helper.dart';

class ChangePasswordPage extends StatefulWidget {
  final String _title;
  const ChangePasswordPage({super.key, required this._title});

  @override
  State<StatefulWidget> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  String? _error;
  bool _obscure = true;
  final _oldController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget._title)),
      body: buildFormCard(
        context,
        icon: Icons.password,
        title: 'Đổi mật khẩu',
        subtitle: 'Mật khẩu mới phải có ít nhất 6 ký tự',
        children: [
          TextFormField(
            controller: _oldController,
            obscureText: _obscure,
            decoration: InputDecoration(
              labelText: 'Mật khẩu hiện tại',
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
            controller: _newController,
            obscureText: _obscure,
            decoration: InputDecoration(
              labelText: 'Mật khẩu mới',
              prefixIcon: Icon(Icons.lock_open),
            ),
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: _confirmController,
            obscureText: _obscure,
            decoration: InputDecoration(
              labelText: 'Nhập lại mật khẩu mới',
              prefixIcon: Icon(Icons.lock_reset),
            ),
          ),
          buildMessage(_error, null),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _onSave,
            label: Text('Lưu mật khẩu'),
            icon: Icon(Icons.save),
          ),
        ],
      ),
    );
  }

  void _onSave() async {
    if (_newController.text != _confirmController.text) {
      setState(() {
        _error = 'Mật khẩu nhập lại không khớp';
      });
      return;
    }
    String? memberId = await SessionHelper.memberId;
    if (memberId == null) return;
    ApiResult result = await MemberRepository.changePassword(
      memberId,
      _oldController.text,
      _newController.text,
    );
    if (!mounted) return;
    if (result.success) {
      showMessage(context, result.message);
      Navigator.pop(context, true);
    } else {
      setState(() {
        _error = result.message;
      });
    }
  }
}
