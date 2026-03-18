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
  MathsHelperState createState() => MathsHelperState();
}

class MathsHelperState extends State<MathsHelper> {
  final String _baseUrl = 'http://192.168.8.117:8081/api/v1/qanda';
  static const String _imageBaseUrl = 'http://192.168.8.117:8081/QandA/';
  List<QandADto> _allQandA = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchQandA();
  }

  void refresh() {
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
          _errorMessage = 'Failed to load Q&A entries. Please try again later.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Unable to connect to the server. Please check your network and try again.';
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
          colors: [const Color.fromARGB(255, 63, 232, 94), Colors.white],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
      elevation: 6,
      shadowColor: Colors.deepPurple.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: const Color.fromARGB(255, 99, 21, 234), width: 1.5),
      ),
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
                      backgroundColor: const Color.fromARGB(255, 78, 29, 167),
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
                      Uri.encodeFull('$_imageBaseUrl${qanda.qimagename}'),
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 140,
                          color: Colors.black.withOpacity(0.05),
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(strokeWidth: 2),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 100,
                        color: const Color.fromARGB(255, 223, 137, 137),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.image_not_supported),
                              const SizedBox(height: 6),
                              Text(
                                '$error',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
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
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.green.shade100,
                        child: const Icon(Icons.person, color: Colors.green, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'answered by: ${qanda.aname ?? ""}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.green,
                              ),
                            ),
                            const Text(
                              'Answer',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
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
                        Uri.encodeFull('$_imageBaseUrl${qanda.aimagename}'),
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 140,
                            color: Colors.black.withOpacity(0.05),
                            alignment: Alignment.center,
                            child: const CircularProgressIndicator(strokeWidth: 2),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 100,
                          color: const Color.fromARGB(255, 37, 7, 7),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.image_not_supported, color: Colors.white),
                                const SizedBox(height: 6),
                                Text(
                                  '$error',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 11, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
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
