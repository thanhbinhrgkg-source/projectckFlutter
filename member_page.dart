import 'package:flutter/material.dart';
import 'package:projectck/helper.dart';
import 'package:projectck/member.dart';
import 'package:projectck/member_repository.dart';
import 'package:projectck/role.dart';
import 'package:projectck/role_repository.dart';

class MemberPage extends StatefulWidget {
  final String _title;
  const MemberPage({super.key, required this._title});

  @override
  State<StatefulWidget> createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage> {
  List<Member> _members = [];
  List<Role> _roles = [];
  String? _memberId;
  int? _roleId;

  @override
  void initState() {
    super.initState();
    _loadMembers();
    _loadRoles();
  }

  void _loadRoles() async {
    var data = await RoleRepository.getRoles();
    if (!mounted) return;
    setState(() {
      _roles = data;
    });
  }

  void _loadMembers() async {
    var data = await MemberRepository.getMembersWithRole();
    if (!mounted) return;
    setState(() {
      _members = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget._title)),
      body: _members.isEmpty
          ? buildEmpty(Icons.group_off, 'Chưa có thành viên')
          : ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: _members.length,
              itemBuilder: (context, index) {
                Member member = _members[index];
                Color color = Helper.roleColor(member.roleName);
                return Card(
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: color.withValues(alpha: 0.15),
                      child: Text(
                        Helper.initial(member.givenName),
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      '${member.surname} ${member.givenName}'.trim(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(member.email),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        buildTag(Role.label(member.roleName), color),
                        PopupMenuButton<String>(
                          onSelected: (val) {
                            if (val == 'role') {
                              _onRole(member);
                            } else {
                              _onDelete(member);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'role',
                              child: Row(
                                spacing: 8,
                                children: [
                                  Icon(Icons.manage_accounts),
                                  Text('Đổi vai trò'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                spacing: 8,
                                children: [
                                  Icon(Icons.delete_outline, color: Colors.red),
                                  Text(
                                    'Xóa',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _onRole(Member obj) async {
    _memberId = obj.id;
    _roleId = obj.roleId;
    var result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Đổi vai trò'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(obj.email),
              SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: _roleId,
                decoration: InputDecoration(
                  labelText: 'Vai trò',
                  prefixIcon: Icon(Icons.manage_accounts),
                ),
                items: _roles.map((Role item) {
                  return DropdownMenuItem(
                    value: item.id,
                    child: Text(Role.label(item.name)),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _roleId = val;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: _onCancel, child: Text('Hủy')),
            ElevatedButton.icon(
              onPressed: _onSave,
              label: Text('Lưu'),
              icon: Icon(Icons.save),
            ),
          ],
        );
      },
    );
    if (result == true) {
      _loadMembers();
    }
  }

  void _onCancel() {
    Navigator.pop(context, false);
  }

  void _onSave() async {
    int ret = await MemberRepository.updateRole(_memberId!, _roleId!);
    if (!mounted) return;
    if (ret > 0) {
      showMessage(context, 'Cập nhật vai trò thành công');
      Navigator.pop(context, true);
    } else {
      showMessage(context, 'Cập nhật vai trò thất bại');
    }
  }

  void _onDelete(Member obj) async {
    var result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: Icon(Icons.warning_amber, color: Colors.red, size: 40),
          title: Text('Xóa thành viên'),
          content: Text('Bạn có chắc muốn xóa ${obj.email}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Hủy'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              label: Text('Xóa'),
              icon: Icon(Icons.delete),
            ),
          ],
        );
      },
    );
    if (result != true) return;
    int ret = await MemberRepository.delete(obj.id);
    if (!mounted) return;
    if (ret > 0) {
      showMessage(context, 'Xóa thành công');
      _loadMembers();
    } else {
      showMessage(context, 'Xóa thất bại');
    }
  }
}
