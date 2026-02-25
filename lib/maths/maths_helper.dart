import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bank_a_plus/maths/add_question.dart';
import 'package:bank_a_plus/advertisement/advertisement_carousel.dart';

class QandADto {
  final int id;
  final String? qname;
  final String? qdis;
  final String? aname;
  final String? adis;
  final String? qimagename;
  final String? aimagename;
  final bool read;
  final bool answered;

  QandADto({
    required this.id,
    this.qname,
    this.qdis,
    this.aname,
    this.adis,
    this.qimagename,
    this.aimagename,
    required this.read,
    required this.answered,
  });

  factory QandADto.fromJson(Map<String, dynamic> json) {
    return QandADto(
      id: json['id'] ?? 0,
      qname: json['qname'],
      qdis: json['qdis'],
      aname: json['aname'],
      adis: json['adis'],
      qimagename: json['qimagename'],
      aimagename: json['aimagename'],
      read: json['read'] ?? false,
      answered: json['answered'] ?? false,
    );
  }
}

class MathsHelper extends StatefulWidget {
  const MathsHelper({Key? key}) : super(key: key);

  @override
  State<MathsHelper> createState() => _MathsHelperState();
}

class _MathsHelperState extends State<MathsHelper> {
  final String _baseUrl = 'http://localhost:8081/api/v1/qanda';
  List<QandADto> _allQandA = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchQandA();
  }

  Future<void> _fetchQandA() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(Uri.parse('$_baseUrl/get_all'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _allQandA = data
              .map((json) => QandADto.fromJson(json))
              .where((q) => q.read == true)
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load Q&A entries (${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.deepPurple.shade50, Colors.white],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AdvertisementCarousel(),
            Padding(
              padding: const EdgeInsets.only(top: 32.0, bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddQuestionPage()),
                      );
                      if (result == true) {
                        _fetchQandA();
                      }
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('+Q'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? _buildErrorWidget()
                      : _allQandA.isEmpty
                          ? _buildEmptyWidget()
                          : _buildQandAList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchQandA,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.question_answer_outlined,
              size: 80, color: Colors.deepPurple.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            'No Q&A entries available yet.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.deepPurple.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQandAList() {
    return RefreshIndicator(
      onRefresh: _fetchQandA,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 32),
        itemCount: _allQandA.length,
        itemBuilder: (context, index) {
          return _buildQandACard(_allQandA[index]);
        },
      ),
    );
  }

  Widget _buildQandACard(QandADto qanda) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Question Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.deepPurple.shade100,
                      child: const Icon(Icons.person, color: Colors.deepPurple),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ask by: ${qanda.qname ?? "unknown user"}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const Text(
                            'Question',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Q: ${qanda.qdis ?? ""}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (qanda.qimagename != null && qanda.qimagename!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'http://localhost:8081/QandA/${qanda.qimagename}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 100,
                        color: Colors.grey.shade200,
                        child: const Center(child: Icon(Icons.image_not_supported)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Answer Section
          if (qanda.answered) ...[
            const Divider(height: 1),
            Container(
              color: Colors.deepPurple.withOpacity(0.05),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'A: answered by: ${qanda.aname ?? ""}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    qanda.adis ?? "",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  if (qanda.aimagename != null && qanda.aimagename!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        'http://localhost:8081/QandA/${qanda.aimagename}',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 100,
                          color: Colors.grey.shade200,
                          child: const Center(child: Icon(Icons.image_not_supported)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
