import 'package:flutter/material.dart';
import '../models/prayer.dart';
import '../core/localization/app_localizations.dart';

class PrayerCard extends StatelessWidget {
  final Prayer prayer;
  final bool isCompleted;
  final VoidCallback onTap;

  const PrayerCard({
    super.key,
    required this.prayer,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final String prayerName = loc.get(prayer.name.toLowerCase());

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prayerName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      prayer.time,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isCompleted ? Theme.of(context).primaryColor : Colors.grey,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
