import 'package:flutter/material.dart';
import 'package:projectck/answer_repository.dart';
import 'package:projectck/choice_stat.dart';
import 'package:projectck/helper.dart';
import 'package:projectck/question.dart';
import 'package:projectck/question_repository.dart';
import 'package:projectck/response_repository.dart';
import 'package:projectck/survey.dart';
import 'package:projectck/survey_repository.dart';

class ResultPage extends StatefulWidget {
  final String _title;
  const ResultPage({super.key, required this._title});

  @override
  State<StatefulWidget> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  int? _surveyId;
  Survey? _survey;
  int _total = 0;
  List<Question> _questions = [];
  Map<int, List<ChoiceStat>> _stats = {};
  Map<int, double> _averages = {};
  Map<int, List<String>> _texts = {};
  bool _loaded = false;

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
    int total = await ResponseRepository.countBySurvey(_surveyId!);
    var questions = await QuestionRepository.getQuestionsBySurvey(_surveyId!);
    Map<int, List<ChoiceStat>> stats = {};
    Map<int, double> averages = {};
    Map<int, List<String>> texts = {};
    for (Question item in questions) {
      if (item.type == 'single' || item.type == 'multiple') {
        stats[item.id!] = await AnswerRepository.getChoiceStats(item.id!);
      } else if (item.type == 'rating') {
        averages[item.id!] = await AnswerRepository.getAverageRating(item.id!);
      } else {
        texts[item.id!] = await AnswerRepository.getTextAnswers(item.id!);
      }
    }
    if (!mounted) return;
    setState(() {
      _survey = survey;
      _total = total;
      _questions = questions;
      _stats = stats;
      _averages = averages;
      _texts = texts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget._title)),
      body: _survey == null
          ? buildEmpty(Icons.search_off, 'Không tìm thấy dữ liệu')
          : ListView(
              padding: EdgeInsets.all(12),
              children: [
                _buildHeader(),
                for (int i = 0; i < _questions.length; i++)
                  _buildResult(i, _questions[i]),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    ColorScheme color = Theme.of(context).colorScheme;
    return Card(
      color: color.primary,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _survey!.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Chủ đề: ${_survey!.topicName}',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Text(
                  '$_total',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('lượt trả lời', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResult(int index, Question q) {
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
                  backgroundColor: color.primaryContainer,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(color: color.primary, fontSize: 13),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 3),
                    child: Text(
                      q.content,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                buildTag(Question.types[q.type]!, color.primary),
              ],
            ),
            SizedBox(height: 16),
            ..._buildDetails(q),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDetails(Question q) {
    ColorScheme color = Theme.of(context).colorScheme;
    if (q.type == 'single' || q.type == 'multiple') {
      List<ChoiceStat> stats = _stats[q.id] ?? [];
      return stats.map((s) {
        double percent = _total == 0 ? 0 : s.total / _total;
        return Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(s.content)),
                  Text(
                    '${s.total}  (${(percent * 100).toStringAsFixed(1)}%)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 6),
              LinearProgressIndicator(
                value: percent,
                minHeight: 10,
                borderRadius: BorderRadius.circular(8),
                backgroundColor: Colors.grey.shade200,
                color: color.primary,
              ),
            ],
          ),
        );
      }).toList();
    } else if (q.type == 'rating') {
      double average = _averages[q.id] ?? 0;
      return [
        Row(
          children: [
            Text(
              average.toStringAsFixed(1),
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [1, 2, 3, 4, 5].map((r) {
                    return Icon(
                      r <= average.round()
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: Colors.amber,
                    );
                  }).toList(),
                ),
                Text(
                  'Điểm trung bình trên 5',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ];
    } else {
      List<String> texts = _texts[q.id] ?? [];
      if (texts.isEmpty) {
        return [
          Text(
            'Chưa có câu trả lời',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ];
      }
      return texts.map((t) {
        return Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 8),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.format_quote, color: Colors.grey),
              SizedBox(width: 8),
              Expanded(child: Text(t)),
            ],
          ),
        );
      }).toList();
    }
  }
}
