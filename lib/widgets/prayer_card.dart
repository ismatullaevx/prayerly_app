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

    return InkWell(
      onTap: isCompleted ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                prayerName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isCompleted ? FontWeight.normal : FontWeight.w600,
                  color: isCompleted ? Colors.grey : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                prayer.time,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isCompleted ? FontWeight.normal : FontWeight.w500,
                  color: isCompleted ? Colors.grey : Theme.of(context).textTheme.bodyLarge?.color,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              tween: Tween<double>(
                begin: isCompleted ? 1.0 : 0.0, 
                end: isCompleted ? 1.0 : 0.0
              ),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: isCompleted ? (0.8 + (0.2 * value)) : 1.0,
                  child: Icon(
                    isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isCompleted 
                      ? Theme.of(context).primaryColor 
                      : Colors.grey.shade400,
                    size: 24,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
