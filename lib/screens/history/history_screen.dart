import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/providers.dart';
import '../../core/localization/app_localizations.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyRecords = ref.watch(historyRecordsProvider);
    final loc = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.get('history')),
        centerTitle: true,
      ),
      body: historyRecords.isEmpty
          ? Center(
              child: Text(
                'No history available',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: historyRecords.length,
              itemBuilder: (context, index) {
                final record = historyRecords[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat.MMMMd(locale).format(record.date),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildPrayerHistoryRow(loc.get('fajr'), record.isFajrCompleted, context),
                        _buildPrayerHistoryRow(loc.get('dhuhr'), record.isDhuhrCompleted, context),
                        _buildPrayerHistoryRow(loc.get('asr'), record.isAsrCompleted, context),
                        _buildPrayerHistoryRow(loc.get('maghrib'), record.isMaghribCompleted, context),
                        _buildPrayerHistoryRow(loc.get('isha'), record.isIshaCompleted, context),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildPrayerHistoryRow(String name, bool isCompleted, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(fontSize: 16)),
          Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isCompleted ? Theme.of(context).primaryColor : Colors.grey,
            size: 20,
          ),
        ],
      ),
    );
  }
}
