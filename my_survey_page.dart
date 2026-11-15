import 'package:flutter/material.dart';
import 'package:projectck/helper.dart';
import 'package:projectck/response_repository.dart';
import 'package:projectck/session_helper.dart';
import 'package:projectck/survey.dart';
import 'package:projectck/survey_repository.dart';

class MySurveyPage extends StatefulWidget {
  final String _title;
  const MySurveyPage({super.key, required this._title});

  @override
  State<StatefulWidget> createState() => _MySurveyPageState();
}

class _MySurveyPageState extends State<MySurveyPage> {
  List<Survey> _surveys = [];
  Map<int, int> _totals = {};

  @override
  void initState() {
    super.initState();
    _loadSurveys();
  }

  void _loadSurveys() async {
    String? memberId = await SessionHelper.memberId;
    String? role = await SessionHelper.role;
    if (memberId == null) return;
    var data = role == 'admin'
        ? await SurveyRepository.getSurveys()
        : await SurveyRepository.getSurveysByMember(memberId);
    Map<int, int> totals = {};
    for (Survey item in data) {
      totals[item.id!] = await ResponseRepository.countBySurvey(item.id!);
    }
    if (!mounted) return;
    setState(() {
      _surveys = data;
      _totals = totals;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget._title)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onAdd,
        icon: Icon(Icons.add),
        label: Text('Tạo khảo sát'),
      ),
      body: _surveys.isEmpty
          ? buildEmpty(Icons.assignment_outlined, 'Bạn chưa có khảo sát nào')
          : ListView.builder(
              padding: EdgeInsets.fromLTRB(12, 12, 12, 88),
              itemCount: _surveys.length,
              itemBuilder: (context, index) {
                return _buildSurvey(_surveys[index]);
              },
            ),
    );
  }

  Widget _buildSurvey(Survey p) {
    Color color = Helper.topicColor(p.topicId);
    bool isOpen = p.isOpen == 1;
    return Card(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Helper.topicIcon(p.topicId), color: color),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          buildTag(p.topicName ?? '', color),
                          buildTag(
                            isOpen ? 'Đang mở' : 'Đã đóng',
                            isOpen ? Colors.green : Colors.grey,
                          ),
                          buildTag(
                            '${_totals[p.id] ?? 0} lượt trả lời',
                            Colors.indigo,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAction(Icons.edit_outlined, 'Sửa', () => _onEdit(p.id!)),
                _buildAction(
                  Icons.quiz_outlined,
                  'Câu hỏi',
                  () => _onQuestion(p.id!),
                ),
                _buildAction(
                  Icons.bar_chart,
                  'Kết quả',
                  () => _onResult(p.id!),
                ),
                _buildAction(
                  isOpen ? Icons.lock_outline : Icons.lock_open,
                  isOpen ? 'Đóng' : 'Mở',
                  () => _onStatus(p),
                ),
                _buildAction(
                  Icons.delete_outline,
                  'Xóa',
                  () => _onDelete(p),
                  Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAction(
    IconData icon,
    String label,
    VoidCallback onTap, [
    Color? color,
  ]) {
    Color itemColor = color ?? Theme.of(context).colorScheme.primary;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              Icon(icon, color: itemColor),
              SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: itemColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onAdd() async {
    await Navigator.pushNamed(context, '/survey');
    _loadSurveys();
  }

  void _onEdit(int id) async {
    await Navigator.pushNamed(context, '/survey', arguments: id);
    _loadSurveys();
  }

  void _onQuestion(int id) async {
    await Navigator.pushNamed(context, '/question', arguments: id);
  }

  void _onResult(int id) async {
    await Navigator.pushNamed(context, '/result', arguments: id);
  }

  void _onStatus(Survey obj) async {
    int ret = await SurveyRepository.updateStatus(
      obj.id!,
      obj.isOpen == 1 ? 0 : 1,
    );
    if (!mounted) return;
    if (ret > 0) {
      showMessage(context, 'Cập nhật trạng thái thành công');
      _loadSurveys();
    } else {
      showMessage(context, 'Cập nhật trạng thái thất bại');
    }
  }

  void _onDelete(Survey obj) async {
    var result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: Icon(Icons.warning_amber, color: Colors.red, size: 40),
          title: Text('Xóa khảo sát'),
          content: Text(
            'Xóa "${obj.title}" cùng toàn bộ câu hỏi và câu trả lời?',
          ),
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
    int ret = await SurveyRepository.delete(obj.id!);
    if (!mounted) return;
    if (ret > 0) {
      showMessage(context, 'Xóa thành công');
      _loadSurveys();
    } else {
      showMessage(context, 'Xóa thất bại');
    }
  }
}
