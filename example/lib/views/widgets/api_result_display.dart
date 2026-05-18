import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ApiResultDisplay extends StatelessWidget {
  final String title;
  final dynamic data; // Changed from Map<String, dynamic> to dynamic
  final bool isLoading;
  final String? errorMessage;

  const ApiResultDisplay({
    Key? key,
    required this.title,
    required this.data,
    this.isLoading = false,
    this.errorMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (errorMessage != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red[900]),
                ),
              )
            else
              Expanded(
                child: _buildResultData(context),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultData(BuildContext context) {
    if (data == null) {
      return const Text('No data available');
    }

    // Handle List<Map<String, dynamic>>
    if (data is List) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('List containing ${data.length} items:'),
          const SizedBox(height: 8),
          ...List.generate(data.length, (index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Item #${index + 1}:',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (data[index] is Map)
                        ..._buildMapEntries(data[index], context)
                      else
                        Text('${data[index]}'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            );
          }),
          const SizedBox(height: 16),
          const Text(
            'Full JSON Response:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Clipboard.setData(
                  ClipboardData(text: jsonEncode(data)),
                );
              },
              child: Text(
                const JsonEncoder.withIndent('  ').convert(data),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Handle Map<String, dynamic>
    if (data is Map) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._buildMapEntries(data, context),
          const SizedBox(height: 16),
          const Text(
            'Full JSON Response:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Material(
            color: Colors.transparent,

            child: InkWell(
              onTap: () {
                Clipboard.setData(
                  ClipboardData(text: jsonEncode(data)),
                );
              },
              child: Text(
                const JsonEncoder.withIndent('  ').convert(data),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Handle other types
    return Text('Data type: ${data.runtimeType}\nValue: $data');
  }

  List<Widget> _buildMapEntries(Map map, BuildContext context) {
    return map.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${entry.key}:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: entry.value is Map
                  ? Material(
                      color: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildMapEntries(entry.value, context),
                      ),
                    )
                  : entry.value is List
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('List with ${entry.value.length} items'),
                            const SizedBox(height: 4),
                            ...List.generate(
                              entry.value.length > 5 ? 5 : entry.value.length,
                              (i) => Padding(
                                padding: const EdgeInsets.only(left: 8, top: 4),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                      onTap: () {
                                        Clipboard.setData(
                                          ClipboardData(text: jsonEncode(entry.value[i]).toString()),
                                        );
                                      },
                                      child: Text('- ${entry.value[i]}')),
                                ),
                              ),
                            ),
                            if (entry.value.length > 5)
                              Padding(
                                padding: const EdgeInsets.only(left: 8, top: 4),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(

                                    onTap: () {
                                      // Handle tap to show more items
                                      showBottomSheet(
                                          context: context,
                                          builder: (context) {
                                            return Container(
                                              padding: const EdgeInsets.all(16),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    'More items (${entry.value.length - 5}):',
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  ...List.generate(
                                                    entry.value.length - 5,
                                                    (i) => Padding(
                                                      padding: const EdgeInsets.only(left: 8, top: 4),
                                                      child: InkWell(
                                                          onTap: () {
                                                            Clipboard.setData(
                                                              ClipboardData(text: jsonEncode(entry.value[i + 5])),
                                                            );
                                                          },
                                                          child: Text('- ${entry.value[i + 5]}')),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          });
                                    },
                                    child: Text(
                                      '... and ${entry.value.length - 5} more items',
                                      style: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        )
                      : Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(text: jsonEncode(entry.value).toString().replaceAll(RegExp(r'^"|"$'), ''))
                              );
                            },
                            child: Text(
                              '${entry.value}',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      );
    }).toList();
  }
}