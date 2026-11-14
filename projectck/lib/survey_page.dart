import 'package:flutter/material.dart';
import 'package:projectck/helper.dart';
import 'package:projectck/session_helper.dart';
import 'package:projectck/survey.dart';
import 'package:projectck/survey_repository.dart';
import 'package:projectck/topic.dart';
import 'package:projectck/topic_repository.dart';

class SurveyPage extends StatefulWidget {
  final String _title;
  const SurveyPage({super.key, required this._title});

  @override
  State<StatefulWidget> createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  int? _id;
  Survey? _survey;
  List<Topic> _topics = [];
  int? _topicId;
  bool _isOpen = true;
  bool _loaded = false;
  String? _error;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _loadData();
    }
  }

  void _loadTopics() async {
    var data = await TopicRepository.getTopics();
    if (!mounted) return;
    setState(() {
      _topics = data;
    });
  }

  void _loadData() async {
    _id = ModalRoute.of(context)!.settings.arguments as int?;
    if (_id != null) {
      Survey? obj = await SurveyRepository.getSurveyById(_id!);
      if (obj != null) {
        if (!mounted) return;
        setState(() {
          _survey = obj;
          _topicId = obj.topicId;
          _isOpen = obj.isOpen == 1;
          _titleController.text = obj.title;
          _descriptionController.text = obj.description;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _id == null ? 'Tạo ${widget._title}' : 'Sửa ${widget._title}',
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.assignment,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Thông tin khảo sát',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Tiêu đề',
                          prefixIcon: Icon(Icons.title),
                        ),
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Mô tả',
                          alignLabelWithHint: true,
                          prefixIcon: Icon(Icons.notes),
                        ),
                      ),
                      SizedBox(height: 12),
                      InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Chủ đề',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            isExpanded: true,
                            isDense: true,
                            value: _topicId,
                            hint: Text('Chọn chủ đề'),
                            items: _topics.map((Topic item) {
                              return DropdownMenuItem(
                                value: item.id,
                                child: Row(
                                  children: [
                                    Icon(
                                      Helper.topicIcon(item.id),
                                      color: Helper.topicColor(item.id),
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Flexible(child: Text(item.name)),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                _topicId = val;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('Mở cho trả lời'),
                        subtitle: Text('Mọi người có thể thấy và làm khảo sát'),
                        value: _isOpen,
                        onChanged: (val) {
                          setState(() {
                            _isOpen = val;
                          });
                        },
                      ),
                      if (_error != null)
                        Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            _error!,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      SizedBox(height: 16),
                      Row(
                        spacing: 12,
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _onCancel,
                              label: Text('Hủy'),
                              icon: Icon(Icons.close),
                            ),
                          ),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _onSave,
                              label: Text('Lưu'),
                              icon: Icon(Icons.save),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onCancel() {
    Navigator.pop(context, false);
  }

  void _onSave() async {
    String title = _titleController.text.trim();
    if (title.isEmpty || _topicId == null) {
      setState(() {
        _error = 'Vui lòng nhập Tiêu đề và chọn Chủ đề';
      });
      return;
    }
    String? memberId = await SessionHelper.memberId;
    if (memberId == null) {
      setState(() {
        _error = 'Vui lòng đăng nhập';
      });
      return;
    }
    Survey obj = Survey(
      id: _id,
      topicId: _topicId!,
      topicName: null,
      memberId: _survey?.memberId ?? memberId,
      title: title,
      description: _descriptionController.text.trim(),
      isOpen: _isOpen ? 1 : 0,
      createdDate: _survey?.createdDate,
    );
    if (_id == null) {
      int ret = await SurveyRepository.add(obj);
      if (!mounted) return;
      if (ret > 0) {
        showMessage(context, 'Tạo khảo sát thành công');
        await Navigator.popAndPushNamed(context, '/question', arguments: ret);
      } else {
        setState(() {
          _error = 'Tạo khảo sát thất bại';
        });
      }
    } else {
      int ret = await SurveyRepository.update(obj);
      if (!mounted) return;
      if (ret > 0) {
        showMessage(context, 'Cập nhật khảo sát thành công');
        Navigator.pop(context, true);
      } else {
        setState(() {
          _error = 'Cập nhật khảo sát thất bại';
        });
      }
    }
  }
}
