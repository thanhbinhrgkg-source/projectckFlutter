import 'package:flutter/material.dart';
import 'package:projectck/answer.dart';
import 'package:projectck/answer_repository.dart';
import 'package:projectck/choice.dart';
import 'package:projectck/choice_repository.dart';
import 'package:projectck/helper.dart';
import 'package:projectck/question.dart';
import 'package:projectck/question_repository.dart';
import 'package:projectck/response.dart';
import 'package:projectck/response_repository.dart';
import 'package:projectck/session_helper.dart';
import 'package:projectck/survey.dart';
import 'package:projectck/survey_repository.dart';

class TakePage extends StatefulWidget {
  final String _title;
  const TakePage({super.key, required this._title});

  @override
  State<StatefulWidget> createState() => _TakePageState();
}

class _TakePageState extends State<TakePage> {
  static const List<String> _ratingLabels = [
    'Rất tệ',
    'Tệ',
    'Bình thường',
    'Tốt',
    'Rất tốt',
  ];
  int? _surveyId;
  Survey? _survey;
  List<Question> _questions = [];
  Map<int, List<Choice>> _choices = {};
  final Map<int, int> _singles = {};
  final Map<int, Set<int>> _multiples = {};
  final Map<int, int> _ratings = {};
  final Map<int, TextEditingController> _texts = {};
  bool _done = false;
  bool _loaded = false;
  String? _error;

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
      if (item.type == 'text') {
        _texts[item.id!] = TextEditingController();
      }
    }
    String? memberId = await SessionHelper.memberId;
    bool done = memberId != null
        ? await ResponseRepository.isExisted(_surveyId!, memberId)
        : false;
    if (!mounted) return;
    setState(() {
      _survey = survey;
      _questions = questions;
      _choices = choices;
      _done = done;
    });
  }

  int get _answeredCount {
    int count = 0;
    for (Question q in _questions) {
      if (q.type == 'text') {
        if ((_texts[q.id]?.text ?? '').trim().isNotEmpty) count++;
      } else if (_isAnswered(q)) {
        count++;
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    double progress = _questions.isEmpty
        ? 0
        : _answeredCount / _questions.length;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget._title),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: Colors.white24,
            color: Colors.amber,
          ),
        ),
      ),
      body: _survey == null
          ? buildEmpty(Icons.search_off, 'Không tìm thấy dữ liệu')
          : ListView(
              padding: EdgeInsets.all(12),
              children: [
                _buildHeader(),
                for (int i = 0; i < _questions.length; i++)
                  _buildQuestion(i, _questions[i]),
                SizedBox(height: 8),
                if (_done)
                  Card(
                    color: Colors.green.shade50,
                    child: ListTile(
                      leading: Icon(Icons.verified, color: Colors.green),
                      title: Text(
                        'Bạn đã làm khảo sát này rồi. Cảm ơn bạn!',
                        style: TextStyle(color: Colors.green.shade800),
                      ),
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: _onSubmit,
                    label: Text('Gửi khảo sát'),
                    icon: Icon(Icons.send),
                  ),
                if (_error != null)
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                SizedBox(height: 24),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    Color color = Helper.topicColor(_survey!.topicId);
    return Card(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.15), Colors.white],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Helper.topicIcon(_survey!.topicId), color: color),
                SizedBox(width: 8),
                buildTag(_survey!.topicName ?? '', color),
              ],
            ),
            SizedBox(height: 12),
            Text(
              _survey!.title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              _survey!.description,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            SizedBox(height: 12),
            Text(
              'Đã trả lời $_answeredCount/${_questions.length} câu',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestion(int index, Question q) {
    ColorScheme color = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: color.primary,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 3),
                    child: Text(
                      q.content,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            _buildAnswer(q),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswer(Question q) {
    List<Choice> choices = _choices[q.id] ?? [];
    if (q.type == 'single') {
      return Column(
        children: choices.map((c) {
          return _buildOption(c.content, _singles[q.id] == c.id, false, () {
            setState(() {
              _singles[q.id!] = c.id!;
            });
          });
        }).toList(),
      );
    } else if (q.type == 'multiple') {
      Set<int> selected = _multiples[q.id] ?? {};
      return Column(
        children: choices.map((c) {
          return _buildOption(c.content, selected.contains(c.id), true, () {
            setState(() {
              if (selected.contains(c.id)) {
                selected.remove(c.id);
              } else {
                selected.add(c.id!);
              }
              _multiples[q.id!] = selected;
            });
          });
        }).toList(),
      );
    } else if (q.type == 'rating') {
      int rating = _ratings[q.id] ?? 0;
      return Row(
        children: [
          ...[1, 2, 3, 4, 5].map((r) {
            return IconButton(
              onPressed: _done
                  ? null
                  : () {
                      setState(() {
                        _ratings[q.id!] = r;
                      });
                    },
              icon: Icon(
                r <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
                color: Colors.amber,
                size: 36,
              ),
            );
          }),
          SizedBox(width: 8),
          if (rating > 0)
            Text(
              _ratingLabels[rating - 1],
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
        ],
      );
    } else {
      return TextFormField(
        controller: _texts[q.id],
        enabled: !_done,
        maxLines: 3,
        decoration: InputDecoration(hintText: 'Nhập câu trả lời của bạn...'),
        onChanged: (val) => setState(() {}),
      );
    }
  }

  Widget _buildOption(
    String text,
    bool selected,
    bool multiple,
    VoidCallback onTap,
  ) {
    ColorScheme color = Theme.of(context).colorScheme;
    IconData icon = multiple
        ? (selected ? Icons.check_box : Icons.check_box_outline_blank)
        : (selected
              ? Icons.radio_button_checked
              : Icons.radio_button_unchecked);
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: _done ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? color.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? color.primary : Colors.grey.shade300,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: selected ? color.primary : Colors.grey),
              SizedBox(width: 10),
              Expanded(child: Text(text)),
            ],
          ),
        ),
      ),
    );
  }

  bool _isAnswered(Question q) {
    if (q.type == 'single') return _singles.containsKey(q.id);
    if (q.type == 'multiple') return (_multiples[q.id] ?? {}).isNotEmpty;
    if (q.type == 'rating') return _ratings.containsKey(q.id);
    return true;
  }

  void _onSubmit() async {
    String? memberId = await SessionHelper.memberId;
    if (memberId == null) {
      setState(() {
        _error = 'Vui lòng đăng nhập để làm khảo sát';
      });
      return;
    }
    if (await ResponseRepository.isExisted(_surveyId!, memberId)) {
      setState(() {
        _done = true;
        _error = null;
      });
      return;
    }
    for (int i = 0; i < _questions.length; i++) {
      if (!_isAnswered(_questions[i])) {
        setState(() {
          _error = 'Vui lòng trả lời câu ${i + 1}';
        });
        return;
      }
    }
    Response response = Response(
      id: null,
      surveyId: _surveyId!,
      surveyTitle: null,
      memberId: memberId,
      date: null,
    );
    int responseId = await ResponseRepository.add(response);
    if (responseId <= 0) {
      setState(() {
        _error = 'Gửi thất bại';
      });
      return;
    }
    for (Question q in _questions) {
      if (q.type == 'single') {
        await _addAnswer(responseId, q.id!, _singles[q.id], null);
      } else if (q.type == 'multiple') {
        for (int choiceId in _multiples[q.id]!) {
          await _addAnswer(responseId, q.id!, choiceId, null);
        }
      } else if (q.type == 'rating') {
        await _addAnswer(responseId, q.id!, null, _ratings[q.id].toString());
      } else {
        String text = _texts[q.id]!.text.trim();
        if (text.isNotEmpty) {
          await _addAnswer(responseId, q.id!, null, text);
        }
      }
    }
    if (!mounted) return;
    showMessage(context, 'Gửi thành công. Cảm ơn bạn!');
    Navigator.pop(context, true);
  }

  Future<int> _addAnswer(
    int responseId,
    int questionId,
    int? choiceId,
    String? content,
  ) async {
    Answer obj = Answer(
      id: null,
      responseId: responseId,
      questionId: questionId,
      choiceId: choiceId,
      content: content,
    );
    return await AnswerRepository.add(obj);
  }
}
