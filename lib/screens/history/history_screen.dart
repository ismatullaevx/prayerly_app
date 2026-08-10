import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/providers.dart';
import '../../core/localization/app_localizations.dart';


class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final historyRecords = ref.watch(historyRecordsProvider);
    final loc = AppLocalizations.of(context);
    
    // Create a lookup map for faster access
    final Map<DateTime, int> completedCountMap = {};
    for (var record in historyRecords) {
      int count = 0;
      if (record.isFajrCompleted) count++;
      if (record.isDhuhrCompleted) count++;
      if (record.isAsrCompleted) count++;
      if (record.isMaghribCompleted) count++;
      if (record.isIshaCompleted) count++;
      
      // Normalize date to remove time part for table_calendar comparison
      final date = DateTime(record.date.year, record.date.month, record.date.day);
      completedCountMap[date] = count;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.get('history')),
        centerTitle: true,
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 10, 16),
            lastDay: DateTime.now(),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                final normalizedDay = DateTime(day.year, day.month, day.day);
                final count = completedCountMap[normalizedDay];
                
                if (count != null && count > 0) {
                  return Positioned(
                    bottom: 1,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        5,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1.0),
                          width: 5.0,
                          height: 5.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index < count
                                ? Theme.of(context).primaryColor
                                : Colors.grey.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
          const SizedBox(height: 16),
          if (_selectedDay != null && completedCountMap.containsKey(DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)))
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '${completedCountMap[DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)]} / 5 Prayers Completed',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            )
          else if (_selectedDay != null)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No records for this day',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }
}
