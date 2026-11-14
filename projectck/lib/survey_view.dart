import 'package:flutter/material.dart';
import 'package:projectck/helper.dart';
import 'package:projectck/survey.dart';
import 'package:projectck/survey_repository.dart';
import 'package:projectck/topic.dart';
import 'package:projectck/topic_repository.dart';

class SurveyView extends StatefulWidget {
  const SurveyView({super.key});

  @override
  State<StatefulWidget> createState() => _SurveyViewState();
}

class _SurveyViewState extends State<SurveyView> {
  List<Topic> _topics = [];
  List<Survey> _surveys = [];
  int? _topicId;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTopics();
    _loadSurveys();
  }

  void _loadTopics() async {
    var data = await TopicRepository.getTopics();
    if (!mounted) return;
    setState(() {
      _topics = data;
    });
  }

  void _loadSurveys() async {
    String keyword = _searchController.text.trim();
    var data = _topicId == null
        ? await SurveyRepository.getOpenSurveys(keyword)
        : await SurveyRepository.getOpenSurveysByTopic(_topicId!, keyword);
    if (!mounted) return;
    setState(() {
      _surveys = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildSearchHeader(
          context,
          title: 'Khảo sát đang mở',
          subtitle: 'Có ${_surveys.length} khảo sát đang chờ ý kiến của bạn',
          controller: _searchController,
          hint: 'Tìm khảo sát...',
          onChanged: (val) => _loadSurveys(),
        ),
        SizedBox(
          height: 56,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              Padding(
                padding: EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text('Tất cả'),
                  selected: _topicId == null,
                  onSelected: (val) {
                    setState(() {
                      _topicId = null;
                    });
                    _loadSurveys();
                  },
                ),
              ),
              ..._topics.map((p) {
                return Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    avatar: Icon(
                      Helper.topicIcon(p.id),
                      color: Helper.topicColor(p.id),
                    ),
                    label: Text(p.name),
                    selected: _topicId == p.id,
                    onSelected: (val) {
                      setState(() {
                        _topicId = val ? p.id : null;
                      });
                      _loadSurveys();
                    },
                  ),
                );
              }),
            ],
          ),
        ),
        Expanded(
          child: _surveys.isEmpty
              ? buildEmpty(Icons.search_off, 'Không có khảo sát nào')
              : ListView.builder(
                  padding: EdgeInsets.fromLTRB(12, 0, 12, 88),
                  itemCount: _surveys.length,
                  itemBuilder: (context, index) {
                    return _buildSurvey(_surveys[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSurvey(Survey item) {
    Color color = Helper.topicColor(item.topicId);
    Color primary = Theme.of(context).colorScheme.primary;
    return Card(
      child: InkWell(
        onTap: () => _onTake(item.id!),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Helper.topicIcon(item.topicId), color: color),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        buildTag(item.topicName ?? '', color),
                        Spacer(),
                        Text(
                          'Làm ngay',
                          style: TextStyle(
                            color: primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(Icons.chevron_right, color: primary),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTake(int id) async {
    await Navigator.pushNamed(context, '/take', arguments: id);
  }
}
