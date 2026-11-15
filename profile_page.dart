import 'package:flutter/material.dart';
import 'package:projectck/helper.dart';
import 'package:projectck/member.dart';
import 'package:projectck/member_repository.dart';
import 'package:projectck/response.dart';
import 'package:projectck/response_repository.dart';
import 'package:projectck/role.dart';
import 'package:projectck/session_helper.dart';

class ProfilePage extends StatefulWidget {
  final String _title;
  const ProfilePage({super.key, required this._title});

  @override
  State<StatefulWidget> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Member? _member;
  List<Response> _responses = [];
  void _loadMember() async {
    String? memberId = await SessionHelper.memberId;
    if (memberId != null) {
      Member? obj = await MemberRepository.getMemberById(memberId);
      var data = await ResponseRepository.getResponsesByMember(memberId);
      if (!mounted) return;
      setState(() {
        _member = obj;
        _responses = data;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMember();
  }

  @override
  Widget build(BuildContext context) {
    if (_member == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget._title)),
        body: buildEmpty(Icons.person_off, 'Không tìm thấy dữ liệu'),
      );
    }
    ColorScheme color = Theme.of(context).colorScheme;
    Color roleColor = Helper.roleColor(_member!.roleName);
    String fullName = '${_member!.surname} ${_member!.givenName}'.trim();
    return Scaffold(
      appBar: AppBar(title: Text(widget._title)),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: color.primary,
                    child: Text(
                      Helper.initial(_member!.givenName),
                      style: TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    fullName,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _member!.email,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  SizedBox(height: 8),
                  buildTag(Role.label(_member!.roleName), roleColor),
                ],
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green.withValues(alpha: 0.12),
                child: Icon(Icons.task_alt, color: Colors.green),
              ),
              title: Text('Khảo sát đã làm'),
              trailing: Text(
                '${_responses.length}',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Lịch sử khảo sát',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          if (_responses.isEmpty)
            buildEmpty(Icons.history, 'Bạn chưa làm khảo sát nào')
          else
            ..._responses.map((item) {
              return Card(
                child: ListTile(
                  leading: Icon(Icons.check_circle, color: Colors.green),
                  title: Text(item.surveyTitle ?? ''),
                  subtitle: Row(
                    children: [
                      Icon(Icons.schedule, size: 14, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(item.date ?? ''),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
