import 'package:flutter/material.dart';
import 'package:projectck/choice.dart';
import 'package:projectck/choice_repository.dart';
import 'package:projectck/helper.dart';
import 'package:projectck/question.dart';
import 'package:projectck/question_repository.dart';
import 'package:projectck/survey.dart';
import 'package:projectck/survey_repository.dart';

class QuestionPage extends StatefulWidget {
  final String _title;
  const QuestionPage({super.key, required this._title});

  @override
  State<StatefulWidget> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  int? _surveyId;
  Survey? _survey;
  List<Question> _questions = [];
  Map<int, List<Choice>> _choices = {};
  String _type = 'single';
  bool _loaded = false;
  String? _error;
  final _contentController = TextEditingController();
  final _choiceController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _surveyId = ModalRoute.of(context)!.settings.arguments as int;
      _loadData();
    }
  }

  void _loadData() async {
    Survey? survey = await SurveyRepository.getSurveyById(_surveyId!);
    var questions = await QuestionRepository.getQuestionsBySurvey(_surveyId!);
    Map<int, List<Choice>> choices = {};
    for (Question item in questions) {
      choices[item.id!] = await ChoiceRepository.getChoicesByQuestion(item.id!);
    }
    if (!mounted) return;
    setState(() {
      _survey = survey;
      _questions = questions;
      _choices = choices;
    });
  }

  bool get _hasChoice => _type == 'single' || _type == 'multiple';

  IconData _typeIcon(String type) {
    switch (type) {
      case 'single':
        return Icons.radio_button_checked;
      case 'multiple':
        return Icons.check_box;
      case 'rating':
        return Icons.star;
      default:
        return Icons.short_text;
    }
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme color = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(widget._title)),
      body: ListView(
        padding: EdgeInsets.all(12),
        children: [
          if (_survey != null)
            Padding(
              padding: EdgeInsets.fromLTRB(4, 4, 4, 8),
              child: Text(
                _survey!.title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.add_circle, color: color.primary),
                      SizedBox(width: 8),
                      Text(
                        'Thêm câu hỏi mới',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _contentController,
                    decoration: InputDecoration(
                      labelText: 'Câu hỏi',
                      prefixIcon: Icon(Icons.help_outline),
                    ),
                  ),
                  SizedBox(height: 12),
                  InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Loại câu hỏi',
                      prefixIcon: Icon(Icons.tune),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        isDense: true,
                        value: _type,
                        items: Question.types.entries.map((p) {
                          return DropdownMenuItem(
                            value: p.key,
                            child: Row(
                              children: [
                                Icon(
                                  _typeIcon(p.key),
                                  size: 20,
                                  color: color.primary,
                                ),
                                SizedBox(width: 8),
                                Text(p.value),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _type = val!;
                          });
                        },
                      ),
                    ),
                  ),
                  if (_hasChoice) ...[
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _choiceController,
                      decoration: InputDecoration(
                        labelText: 'Các lựa chọn',
                        prefixIcon: Icon(Icons.checklist),
                        helperText:
                            'Phân cách bằng dấu ;  Vd: Có;Không;Chưa rõ',
                      ),
                    ),
                  ],
                  if (_error != null)
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(_error!, style: TextStyle(color: Colors.red)),
                    ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _onAdd,
                    label: Text('Thêm câu hỏi'),
                    icon: Icon(Icons.add),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Danh sách câu hỏi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              buildTag('${_questions.length} câu', color.primary),
            ],
          ),
          SizedBox(height: 4),
          if (_questions.isEmpty)
            buildEmpty(Icons.quiz_outlined, 'Chưa có câu hỏi nào')
          else
            for (int i = 0; i < _questions.length; i++)
              _buildQuestion(i, _questions[i]),
        ],
      ),
    );
  }

  Widget _buildQuestion(int index, Question item) {
    ColorScheme color = Theme.of(context).colorScheme;
    List<Choice> choices = _choices[item.id] ?? [];
    return Card(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 12, 4, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: color.primaryContainer,
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: color.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.content,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  buildTag(Question.types[item.type]!, color.primary),
                  if (choices.isNotEmpty) ...[
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: choices.map((c) {
                        return Chip(
                          label: Text(c.content),
                          visualDensity: VisualDensity.compact,
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              onPressed: () => _onDelete(item.id!),
              icon: Icon(Icons.delete_outline, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  void _onAdd() async {
    String content = _contentController.text.trim();
    List<String> choices = _choiceController.text
        .split(';')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
    if (content.isEmpty) {
      setState(() {
        _error = 'Vui lòng nhập câu hỏi';
      });
      return;
    }
    if (_hasChoice && choices.length < 2) {
      setState(() {
        _error = 'Vui lòng nhập ít nhất 2 lựa chọn';
      });
      return;
    }
    Question obj = Question(
      id: null,
      surveyId: _surveyId!,
      content: content,
      type: _type,
    );
    int questionId = await QuestionRepository.add(obj);
    if (questionId > 0 && _hasChoice) {
      for (String item in choices) {
        await ChoiceRepository.add(
          Choice(id: null, questionId: questionId, content: item),
        );
      }
    }
    if (!mounted) return;
    if (questionId > 0) {
      showMessage(context, 'Thêm câu hỏi thành công');
      _contentController.clear();
      _choiceController.clear();
      setState(() {
        _error = null;
      });
      _loadData();
    } else {
      setState(() {
        _error = 'Thêm câu hỏi thất bại';
      });
    }
  }

  void _onDelete(int id) async {
    int ret = await QuestionRepository.delete(id);
    if (!mounted) return;
    if (ret > 0) {
      showMessage(context, 'Xóa thành công');
      _loadData();
    } else {
      showMessage(context, 'Xóa thất bại');
    }
  }
}
