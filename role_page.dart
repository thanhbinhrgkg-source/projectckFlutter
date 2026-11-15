import 'package:flutter/material.dart';
import 'package:projectck/api_result.dart';
import 'package:projectck/helper.dart';
import 'package:projectck/role.dart';
import 'package:projectck/role_repository.dart';

class RolePage extends StatefulWidget {
  final String _title;
  const RolePage({super.key, required this._title});

  @override
  State<StatefulWidget> createState() => _RolePageState();
}

class _RolePageState extends State<RolePage> {
  List<Role> _roles = [];

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  void _loadRoles() async {
    var data = await RoleRepository.getRoles();
    if (!mounted) return;
    setState(() {
      _roles = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget._title)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _onForm(null),
        icon: Icon(Icons.add),
        label: Text('Thêm vai trò'),
      ),
      body: ListView.builder(
        padding: EdgeInsets.fromLTRB(12, 12, 12, 88),
        itemCount: _roles.length,
        itemBuilder: (context, index) {
          Role item = _roles[index];
          Color color = Helper.roleColor(item.name);
          bool system = Role.systemRoles.contains(item.name);
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(Icons.admin_panel_settings, color: color),
              ),
              title: Text(
                Role.label(item.name),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Mã: ${item.name} • ${item.memberCount} thành viên',
              ),
              trailing: system
                  ? buildTag('Hệ thống', Colors.grey)
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _onForm(item),
                          icon: Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          onPressed: () => _onDelete(item),
                          icon: Icon(Icons.delete_outline, color: Colors.red),
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }

  void _onForm(Role? item) async {
    final nameController = TextEditingController(text: item?.name ?? '');
    String? error;
    var result = await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(item == null ? 'Thêm vai trò' : 'Sửa vai trò'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Tên vai trò',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                  ),
                  buildMessage(error, null),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Hủy'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    ApiResult ret = item == null
                        ? await RoleRepository.add(nameController.text)
                        : await RoleRepository.update(
                            item.id,
                            nameController.text,
                          );
                    if (!context.mounted) return;
                    if (ret.success) {
                      Navigator.pop(context, ret.message);
                    } else {
                      setDialogState(() {
                        error = ret.message;
                      });
                    }
                  },
                  icon: Icon(Icons.save),
                  label: Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    );
    if (!mounted) return;
    if (result is String) {
      showMessage(context, result);
      _loadRoles();
    }
  }

  void _onDelete(Role item) async {
    var confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Xóa vai trò'),
          content: Text('Bạn có chắc muốn xóa vai trò "${item.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: Text('Xóa'),
            ),
          ],
        );
      },
    );
    if (confirm != true) return;
    ApiResult result = await RoleRepository.delete(item.id);
    if (!mounted) return;
    showMessage(context, result.message);
    if (result.success) _loadRoles();
  }
}
