import 'package:flutter/material.dart';
import 'package:projectck/api_result.dart';
import 'package:projectck/helper.dart';
import 'package:projectck/member_repository.dart';

class VerifyPage extends StatefulWidget {
  final String _title;
  const VerifyPage({super.key, required this._title});

  @override
  State<StatefulWidget> createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage> {
  String _email = '';
  String? _error;
  String? _info;
  final _codeController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _email = ModalRoute.of(context)!.settings.arguments as String? ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget._title)),
      body: buildFormCard(
        context,
        icon: Icons.mark_email_read_outlined,
        title: 'Xác thực email',
        subtitle: 'Nhập mã 6 số đã gửi đến $_email',
        children: [
          TextFormField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, letterSpacing: 8),
            decoration: InputDecoration(labelText: 'Mã xác thực'),
          ),
          buildMessage(_error, _info),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _onVerify,
            label: Text('Xác thực'),
            icon: Icon(Icons.verified),
          ),
          SizedBox(height: 8),
          TextButton.icon(
            onPressed: _onResend,
            icon: Icon(Icons.refresh),
            label: Text('Gửi lại mã'),
          ),
        ],
      ),
    );
  }

  void _onResend() async {
    ApiResult result = await MemberRepository.sendCode(_email);
    if (!mounted) return;
    setState(() {
      _error = result.success ? null : result.message;
      _info = result.success ? result.message : null;
    });
  }

  void _onVerify() async {
    ApiResult result = await MemberRepository.verify(
      _email,
      _codeController.text.trim(),
    );
    if (!mounted) return;
    if (result.success) {
      showMessage(context, '${result.message}. Bạn có thể đăng nhập.');
      Navigator.pop(context, true);
    } else {
      setState(() {
        _error = result.message;
        _info = null;
      });
    }
  }
}
