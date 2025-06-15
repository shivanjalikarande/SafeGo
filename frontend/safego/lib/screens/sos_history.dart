import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // For date formatting

class SOSHistoryPage extends StatefulWidget {
  final String userId;

  const SOSHistoryPage({Key? key, required this.userId}) : super(key: key);

  @override
  _SOSHistoryPageState createState() => _SOSHistoryPageState();
}

class _SOSHistoryPageState extends State<SOSHistoryPage> {
  List<dynamic> sosList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSOSHistory();
  }

  Future<void> fetchSOSHistory() async {
    final response = await http.get(
      Uri.parse('http://192.168.221.129:5000/sos/${widget.userId}'),
    );

    if (response.statusCode == 200) {
      setState(() {
        sosList = jsonDecode(response.body)['data'];
        isLoading = false;
      });
    } else {
      print('Error fetching SOS history');
      setState(() => isLoading = false);
    }
  }

  String formatDateTime(String timestamp) {
    final DateTime dateTime = DateTime.parse(timestamp).toLocal();
    return "${DateFormat('MMM d, yyyy').format(dateTime)} • ${DateFormat('h:mm a').format(dateTime)}";
  }

  String extractAddress(dynamic addressField) {
    if (addressField is Map) {
      return addressField['address'] ?? 'Address not available';
    } else if (addressField is String) {
      return addressField;
    } else {
      return 'Address not available';
    }
  }

  IconData getAlertIcon(String reason) {
    if (reason == "Marked as Safe") {
      return Icons.check_circle_outline;
    } else if (reason.contains("Unresponsive")) {
      return Icons.warning_amber_outlined;
    } else {
      return Icons.error_outline;
    }
  }

  Color getAlertColor(String reason) {
    if (reason == "Marked as Safe") {
      return Colors.green;
    } else if (reason.contains("Unresponsive")) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alert History')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : sosList.isEmpty
              ? const Center(child: Text('No Alert History Found'))
              : ListView.builder(
                itemCount: sosList.length,
                itemBuilder: (context, index) {
                  final item = sosList[index];
                  final String reason = item['reason'] ?? 'No reason';
                  final String severity = item['severity'] ?? '';
                  final String timestamp = item['timestamp'] ?? '';
                  final String address = extractAddress(item['address']);

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                getAlertIcon(reason),
                                color: getAlertColor(reason),
                                size: 28,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      reason,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      formatDateTime(timestamp),
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.location_on_outlined,
                                          size: 18,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            address,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if (reason != "Marked as Safe") ...[
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.shield_outlined,
                                            size: 18,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              "Severity: $severity",
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
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
}
